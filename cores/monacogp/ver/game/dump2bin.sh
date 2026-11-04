#!/bin/bash -e

DUMP=dump.bin
DELETE=

main() {
	parse_args "$@"
	if [ -n "$DELETE" ]; then
		delete_parts
		return
	fi
	require_input_file
	split_into_parts
	run_core_specific_script
}

parse_args() {
	while [ $# -gt 0 ]; do
		case "$1" in
			--delete) DELETE=1;;
			*) DUMP="$1";;
		esac
		shift
	done
}

require_input_file() {
	if [ ! -e "$DUMP" ]; then
		echo "Cannot find $DUMP"
		return 1
	fi
}

split_into_parts() {
	# score 512 bytes (0 kB)
	rm -f score.bin
	dd if="$DUMP" of=score.bin bs=64 count=8 skip=0
	jtutil drop1    < score.bin > score_hi.bin
	jtutil drop1 -l < score.bin > score_lo.bin
	
	# scoreptr 2 bytes (0 kB)
	rm -f scoreptr.bin
	dd if="$DUMP" of=scoreptr.bin bs=64 count=0 skip=8
	
	
	make_rest
}

delete_parts() {
	rm -f score.bin
	rm -f score_hi.bin score_lo.bin
	
	rm -f scoreptr.bin
	
	
	rm -f rest.bin
	run_core_specific_script --delete
}

make_rest() {
	dd if="$DUMP" of=rest.bin bs=64 skip=8
}

run_core_specific_script() {
	local script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	for path in $script_path/. $script_path/..; do
		if [ -x $path/rest2bin.sh ]; then
			echo $path/rest2bin.sh
			$path/rest2bin.sh "$@"
			return
		fi
	done
}

main "$@"
