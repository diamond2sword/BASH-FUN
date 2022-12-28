#!/bin/bash

main () {
	run "$@"
}

MODES=(0 1 2 3 4 9)
COLORS=(32 92)
HEX_DGTS=(0 1 2 3 4 5 6 7 8 9 A B C D E F)
NOFMT="\e[m"

run () {
	while :; do {
		echo_rnd_str_fmt
		echo_rnd_hex_dgt
		echo -en $NOFMT
	} done
}

echo_rnd_str_fmt () {
	rnd=$(($RANDOM % 7))
	mode=${MODES[$rnd]}	
	rnd=$(($RANDOM % 2))
	color=${COLORS[$rnd]}
	fmt="\e[$mode;${color}m"
	echo -en $fmt
}

echo_rnd_hex_dgt () {
	rnd=$(($RANDOM % 16))
	dgt=${HEX_DGTS[$rnd]}
	echo -en $dgt
}

main "$@"
