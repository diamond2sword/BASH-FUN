main () {
	class del
	set
	return 0
}

declare -a OBJECTS

class () {
	local fun=$1; shift
	local args="$@"; shift
	(eval "$class_fun;$fun $args")
}

class_fun=$(cat <<- "EOF"
new () {
	local class=$1; shift
	local name=$1; shift
	local args="$@"
	OBJECTS[$class$name]=$(cat << EOF2
		$(eval "echo \"s)
	EOF2
	)
}
del () {
	echo ho
}
var () {
	echo hey
}
fun () {
	echo wa
}
EOF
)

ttt_fun=$(cat << "EOF"
init () {
	class var board=$(new_board)
}

new_board () {
	for i in {0..8}; {
		echo -n $i
	}
}
EOF
)



main "$@"
