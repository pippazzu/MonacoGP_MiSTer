// SPDX-License-Identifier: GPL-3.0-or-later
// 96597-P sheet I (manual 420-0358, PDF page 23): the high-score memory and
// the ranking, the part of the sheet that jtmonacogp_score.v (the score
// counter) leaves out. Pin-level reading: docs/trace/SHEET_I_TRACE.md,
// "Memory and ranking".
//
// - End of a game. 11A (74390, first half) counts H5 while GAME is low and
//   stops at 8; 12A (7442) decodes its odd counts: 1 ADR INC. (9F, the
//   memory address, steps on), 3 192 LD. (7H..10H load 9999), 5 RAM R/W
//   (the score P, driven onto the memory bus by the 8216s while 11A's QC is
//   high, is written into the 2111s), 7 "256 CL." (13F: the search starts,
//   unless 12C's second half still holds the power-up clear; 10B..10D's
//   first halves, N, the players to date, count one).
// - The search. 12B (74107) gates the 14 MHz clock into 12C, which steps
//   the memory address (9F) and 12D together once every eight clocks. The
//   four 74192s count down from 9999 once every 256 addresses, so every
//   stored score is compared with every value from 9999 to 0000; their
//   borrow stops the search after 0000. 12C's count 5 (J2's Q2) strobes the
//   comparison of the memory output (D bus) with the down-counter (6F..3F),
//   count 7 (Q3) that of the score with it (6H..3H).
// - A memory match counts 11A's second half (up to 8) and, through 10A
//   (74259 as a demultiplexer), clocks the next of sheet K's five latches:
//   1ST..5TH get the five highest stored scores, in order.
// - Until the score itself is reached (12B's second half, F), every match
//   counts R (10B..10D's second halves): R is the score's rank. 14H flashes
//   row R of the display (1ST..5TH) with Vs/16 once the score is reached;
//   13E switches it off from rank 8 on.
// - 12C's second half counts V2 for eight periods after /INI. RESET: until
//   then it holds N and sheet K cleared (LATCH CL.) and blocks 13F.
//
// One correction to the drawing (docs/SHEET_I_LOGIC.md): the down-counter's
// DOWN clock (7H pin 4) is drawn straight from 12D's QD (pin 6). As drawn,
// every pass over the memory but the first starts 128 addresses after the
// score just written, which is then never counted: a new best score would
// get R = 0 and no row would flash. The real panel flashes 1ST for a new
// best score (the maintainer's photo, 1 November 2026), as it does when DOWN is the
// inverse of 12D's QD: every pass then starts at the new score. DOWN_INV = 1
// (the default) takes that reading; DOWN_INV = 0 is the drawing.
//
// Timing. The circuit runs on the 14 MHz clock (cen14): at each enable the
// inputs (taken as they are, they change between enables) and their
// consequences settle first, then 12C counts with the 12B state that
// results, then the consequences of that count settle. The 2111s are read
// through a register: the D bus shows the address set at the previous
// enable, at least four enables before any strobe uses it. While 11A's QC is
// high the 8216s' outputs are off and the D bus floats high (all ones).
//
// Memory. The 2111s are a block RAM outside this module (mem.yaml, "score"),
// read without a register of its own: ram_dout must be valid before the next
// enable. KEEP = 1 (the core, not original circuitry) keeps the scores across
// power-offs through JTFRAME's NVRAM file:
// - On the board /INI. RESET lets 11A run freely, so it clears the memory:
//   every address gets the score, 0000. That would wipe the restored file, so
//   with KEEP no write and no ADR INC. happen until GAME has risen.
// - 9F is not in the 2111s, and a restart at address 0 would overwrite the
//   oldest scores first. The file also holds it (mem.yaml, "scoreptr"), saved
//   when a search ends and read back during /INI. RESET.
// - The rank latches start empty on the board, and would stay so until a game
//   ended. With KEEP one search runs when 12C's power-up delay ends, for the
//   five ranks only: N does not count, and R and FLASH read zero until a game.
// KEEP = 0 is the board as drawn; the pin-wired reference tests use it.
module jtmonacogp_rank #(
    parameter integer DOWN_INV = 1,
    parameter integer KEEP = 0
)(
    input             clk, rst,
    input             cen14,
    input             h5, v2,         // (E) pads d, c
    input             vs16,           // (H) pad f
    input             game,           // (A) pad e
    input             coin_test_n,    // (A) pad b
    input             ini_reset_n,    // (A) pad 24
    input      [15:0] p,              // the score {P-4 .. P-1}, jtmonacogp_score.v
    output     [15:0] d,              // D bus {D-4 .. D-1} (to K)
    output      [4:0] rank_ck,        // 1ST..5TH (to K), 10A Q0..Q4
    output            latch_cl,       // LATCH CL. (to K)
    output     [11:0] n,              // players to date {N-3, N-2, N-1} (to J)
    output     [11:0] r,              // rank {R-3, R-2, R-1} (to J)
    output      [5:1] flash,          // 1ST..5TH FLASH (to J), 14H Q1..Q5
    output            searching,      // 12B Q (not a board line)
    // the 2111s, one read and write address (9F)
    output      [7:0] ram_addr,
    output     [15:0] ram_din,
    output reg        ram_we,
    input      [15:0] ram_dout,
    // 9F's value when the last search ended (KEEP)
    output      [7:0] ptr_din,
    output reg        ptr_we,
    input       [7:0] ptr_dout
);
    // ---------------------------------------------------------------- state
    reg  [3:0] pc;                    // 12C second half (power-up delay)
    reg        pc_ck_l;               // 2E pin 1
    reg  [3:0] seq;                   // 11A first half, BCD
    reg        seq_ck_l;              // 13F pin 1
    reg  [7:0] adr;                   // 9F
    reg        adr_ck_l;              // 11C pin 6
    reg [15:0] cnt;                   // 7H..10H, BCD
    reg        down_l;                // 7H pin 4
    reg        q12b;                  // 12B first half Q
    reg        t11c3_l;               // 11C pin 3
    reg  [3:0] c12;                   // 12C first half
    reg  [7:0] d12;                   // 12D
    reg        f_q;                   // 12B second half Q (F = its /Q)
    reg        own_l, match_l, rp_l, rr_l;
    reg  [3:0] rc;                    // 11A second half, BCD
    reg [11:0] rk;                    // R
    reg [11:0] nk;                    // N
    reg        n_ck_l;                // 13F pin 4
    reg        e13;                   // 13E latch 1 Q
    reg  [7:0] h14;                   // 14H Q0..Q7
    reg        qc_seq;                // 11A first half QC (8216 /DIEN = its inverse)
    reg        armed;                 // KEEP: GAME has risen since /INI. RESET
    reg        boot_done, boot_view;  // KEEP: the search after power-up

    function [3:0] inc10(input [3:0] x); inc10 = x == 4'd9 ? 4'd0 : x + 4'd1; endfunction
    function [11:0] inc3(input [11:0] x);       // three cascaded decades
        begin
            inc3 = x;
            inc3[3:0] = inc10(x[3:0]);
            if (x[3:0] == 4'd9) begin
                inc3[7:4] = inc10(x[7:4]);
                if (x[7:4] == 4'd9) inc3[11:8] = inc10(x[11:8]);
            end
        end
    endfunction
    function [15:0] dec4(input [15:0] x);       // 74192 chain counting down
        integer k;
        reg b;
        begin
            dec4 = x; b = 1;
            for (k = 0; k < 4; k = k + 1)
                if (b) begin
                    if (x[4*k +: 4] == 4'd0) dec4[4*k +: 4] = 4'd9;
                    else begin dec4[4*k +: 4] = x[4*k +: 4] - 4'd1; b = 0; end
                end
        end
    endfunction

    // ---------------------------------------------------------------- outputs
    wire rst_t = ~(coin_test_n & ini_reset_n);          // 13H
    wire pwr   = ~pc[3];                                // 11D 5 -> 6
    wire q2    = c12[2:0] == 3'd5;                      // J2 Q2
    wire rp    = ~rc[3] & match_l;                      // 11B 4, 5 -> 6
    assign d        = qc_seq ? 16'hffff : ram_dout;
    assign ram_addr = adr;
    assign ram_din  = p;
    assign ptr_din  = adr;
    assign rank_ck  = {5{rp}} & (5'd1 << rc[2:0]);
    assign latch_cl = pwr;
    assign n        = nk;
    assign r        = boot_view ? 12'd0 : rk;
    assign flash    = boot_view ? 5'd0 : h14[5:1];
    assign searching = q12b;

    // ---------------------------------------------------------------- one 14 MHz step
    reg  [3:0] s_pc, s_seq, s_c12, s_rc;
    reg  [7:0] s_adr, s_d12, s_h14;
    reg [15:0] s_cnt, s_d;
    reg [11:0] s_rk, s_nk;
    reg        s_q12b, s_f, s_e13, s_pwr, s_ck, s_ld, s_wr, s_f13, s_bo_n, s_t3, s_down;
    reg        s_match, s_own, s_rp, s_rr, s_dh, s_qc;
    reg        s_armed, s_allow, s_inc, s_boot, s_nck;
    reg        s_pc_ck_l, s_seq_ck_l, s_adr_ck_l, s_t11c3_l, s_down_l, s_n_ck_l;
    reg  [3:0] s_dec;

    task automatic settle_counter;      // 192 DOWN edge, borrow, 12B toggle
        begin
            s_down = DOWN_INV ? ~s_d12[7] : s_d12[7];
            if (s_down && !s_down_l) s_cnt = dec4(s_cnt);
            s_down_l = s_down;
            if (s_ld) s_cnt = 16'h9999;
            s_bo_n = ~(s_cnt == 16'h0000 && !s_down);
            s_t3   = s_f13 | ~s_bo_n;                  // 11C 1, 2 -> 3
            if (rst_t) s_q12b = 1'b0;                  // 12B CL = /RST
            else if (s_t11c3_l && !s_t3) s_q12b = ~s_q12b;
            s_t11c3_l = s_t3;
        end
    endtask

    always @(posedge clk) begin
        if (rst) begin
            pc <= 0; pc_ck_l <= 0; seq <= 0; seq_ck_l <= 0; adr <= 0; adr_ck_l <= 0;
            cnt <= 16'h9999; down_l <= DOWN_INV ? 1'b1 : 1'b0; q12b <= 0; t11c3_l <= 0;
            c12 <= 0; d12 <= 0; f_q <= 0; own_l <= 0; match_l <= 0; rp_l <= 0; rr_l <= 0;
            rc <= 0; rk <= 0; nk <= 0; n_ck_l <= 0; e13 <= 0; h14 <= 0; qc_seq <= 0;
            ram_we <= 0; ptr_we <= 0; armed <= 0; boot_done <= 0; boot_view <= 0;
        end else if (cen14) begin
            {s_pc, s_seq, s_c12, s_rc, s_adr, s_d12, s_h14} = {pc, seq, c12, rc, adr, d12, h14};
            {s_cnt, s_rk, s_nk, s_q12b, s_f, s_e13} = {cnt, rk, nk, q12b, f_q, e13};
            {s_pc_ck_l, s_seq_ck_l, s_adr_ck_l, s_t11c3_l, s_down_l, s_n_ck_l} =
                {pc_ck_l, seq_ck_l, adr_ck_l, t11c3_l, down_l, n_ck_l};

            // ------------------------------------------------ inputs settle
            // 12C second half: CP = 2E 1 = NOR(QD, V2), MR = 13A 10 = INI. RESET
            s_ck = ~(s_pc[3] | v2);
            if (!ini_reset_n) s_pc = 0;
            else if (s_pc_ck_l && !s_ck) s_pc = s_pc + 4'd1;
            s_pc_ck_l = ~(s_pc[3] | v2);
            s_pwr = ~s_pc[3];
            // 11A first half: CP = 13F 1 = NOR(11B 11, H5), 11B 11 = QD & /INI. RESET;
            // MR = 2H 8 = /INI. RESET & GAME
            s_ck = ~((s_seq[3] & ini_reset_n) | h5);
            if (ini_reset_n && game) s_seq = 0;
            else if (s_seq_ck_l && !s_ck) s_seq = inc10(s_seq);
            s_seq_ck_l = ~((s_seq[3] & ini_reset_n) | h5);
            // 12A (A = QB, B = QC, C = QD, D = NOT QA through 13A 9 -> 8)
            s_armed = (armed | game) & ini_reset_n;
            s_allow = KEEP == 0 || s_armed;
            s_inc = s_seq == 4'd1 && s_allow;          // ADR INC.
            s_boot = KEEP != 0 && !s_pwr && !boot_done;
            s_qc  = s_seq[2];
            s_ld  = s_seq == 4'd3;                     // 192 LD.
            s_wr  = s_seq == 4'd5 && s_allow;          // RAM R/W low
            s_nck = s_seq == 4'd7 && !s_pwr;           // 13F 5, 6 -> 4
            s_f13 = s_nck | s_boot;
            // the RST trunk clears 12C, 12D, 11A's second half, R, F and 13E
            if (rst_t) begin s_c12 = 0; s_d12 = 0; s_rc = 0; s_rk = 0; s_f = 0; end
            // 9F: CP = 11C 6 = OR(12C QC, 13D 6 = ADR INC.)
            s_ck = s_c12[2] | s_inc;
            if (s_adr_ck_l && !s_ck) s_adr = s_adr + 8'd1;
            s_adr_ck_l = s_ck;
            if (KEEP != 0 && !ini_reset_n) s_adr = ptr_dout;
            // N: 10B..10D first halves, CP = 13F 4, MR = 11D 6
            if (s_pwr) s_nk = 0;
            else if (s_n_ck_l && !s_nck) s_nk = inc3(s_nk);
            s_n_ck_l = s_nck;
            settle_counter;

            // ------------------------------------------------ 14 MHz edge
            if (s_q12b && !rst_t) begin
                s_c12 = s_c12 + 4'd1;
                if (s_c12[2:0] == 3'd0) begin           // QC fell
                    s_d12 = s_d12 + 8'd1;
                    if (!s_inc) s_adr = s_adr + 8'd1;
                end
                s_adr_ck_l = s_c12[2] | s_inc;
                settle_counter;
            end

            // ------------------------------------------------ comparisons
            s_dh    = s_qc;                            // 8216 outputs off
            s_d     = s_dh ? 16'hffff : ram_dout;
            s_match = s_c12[2:0] == 3'd5 && s_d == s_cnt;      // 6F..3F, J2 Q2
            s_own   = s_c12[2:0] == 3'd7 && p == s_cnt;        // 6H..3H, J2 Q3
            // 12B second half: J high, K low, CK = 3H 6, CL = /RST
            if (!rst_t && own_l && !s_own) s_f = 1'b1;
            // 11A second half counts 11B 6 = NOT QD & match; R counts 11B 8 = match & F
            s_rp = ~s_rc[3] & s_match;
            s_rr = s_match & ~s_f;
            if (!rst_t && rp_l && !s_rp) s_rc = inc10(s_rc);
            if (!rst_t && rr_l && !s_rr) s_rk = inc3(s_rk);
            // 13E latch 1: /S = 13F 12 = NOT R-1D, /R = /RST
            if (s_rk[3]) s_e13 = 1'b1;
            else if (rst_t) s_e13 = 1'b0;
            // 14H (74259): D = 12E 13 = NOR(F, Vs/16), A..C = R-1A..C,
            // /E = 13E Q, /CL = 11A second half QD
            case ({s_rc[3], s_e13})
            2'b00: begin s_h14 = 0; s_h14[s_rk[2:0]] = s_f & ~vs16; end
            2'b01: s_h14 = 0;
            2'b10: s_h14[s_rk[2:0]] = s_f & ~vs16;
            default: ;
            endcase

            // ------------------------------------------------ KEEP
            // the search after power-up leaves the address where it found it
            if (boot_view && q12b && !s_q12b) s_adr = ptr_dout;
            ptr_we <= KEEP != 0 && s_armed && q12b && !s_q12b;
            armed <= s_armed;
            boot_done <= !s_pwr;
            if (s_boot) boot_view <= 1'b1;
            else if (s_armed || rst_t) boot_view <= 1'b0;

            // ------------------------------------------------ store
            {pc, seq, c12, rc, adr, d12, h14} <= {s_pc, s_seq, s_c12, s_rc, s_adr, s_d12, s_h14};
            {cnt, rk, nk, q12b, f_q, e13} <= {s_cnt, s_rk, s_nk, s_q12b, s_f, s_e13};
            {pc_ck_l, seq_ck_l, adr_ck_l, t11c3_l, down_l, n_ck_l} <=
                {s_pc_ck_l, s_seq_ck_l, s_adr_ck_l, s_t11c3_l, s_down_l, s_n_ck_l};
            {own_l, match_l, rp_l, rr_l} <= {s_own, s_match, s_rp, s_rr};
            qc_seq <= s_qc;
            ram_we <= s_wr;
        end
    end
endmodule
