main () {
	class new "$@"
	return 0
}

class () {
	fun=$1; shift
	args="$@"
	class_$fun "$args"
}

class_new () {
	echo 
}

main "$@"
