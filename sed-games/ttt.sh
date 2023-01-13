#!/bin/bash
main () {
	class ttt game
	class ttt game echo
	class ttt game mark 0 2
	class ttt game echo
	return 0
}

class () {
	local class=$1; shift
	local name=$1; shift
	local class_fun=$(eval "echo \"\$${class}_fun\"")
	eval "$(echo "$class_fun" | sed -r "s/class/${class}_${name}/g")"
	#set	
	#echo "$class_fun" | sed -r "s/class/${class}_${name}/g"
}

ttt_fun=$(cat << "EOF"
init () {
	class_board=($(new_board))
}

mark () {
	key=$1; shift
	val=$1; shift
	class_board[$key]=$val
}

echo () (
	echo ---
	for i in {0..8};{
		echo -n ${board[$i]}
		((i%3 == 2)) && echo
	}
	echo ---
)

eval () (
	return 0	
)

board () (
	for i in {0..8}; {
		echo $i
	}
)

init
EOF
)

main "$@"
