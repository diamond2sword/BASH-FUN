#!/bin/bash


main () {
	run "$@"
}

run () {
	str="$@"
	spc_str=$(
		echo "$str" | sed -r '{
			s/(.)/\1\n/g
		}' | sed -r "{
			s/^(.*)$/\1/g	
		}" | tr "\n" " "
	)
	len=${#str}
	loop 0 $len "$spc_str"
}

loop () {
	local i=$1; shift
	len=$1; shift
	str=($@)
	for ((; i<$len; i++)); {
		echo -n "${str[$i]}"
		loop $((i+1)) $len "$@"
	}
}


main "$@"
