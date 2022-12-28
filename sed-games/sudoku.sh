#!/bin/bash
(


	


	main () {
		(exit
			create_array hi '$name$index=haha' 9 9
			Board sudoku 9 9
			print_variables "Board_sudoku"
			get_array Board_sudoku_array 3 3
			set_array Board_sudoku_array "Hi 123" 3 3
			get_array Board_sudoku_array 3 3	
		)
		(exit
			create_array hello '$name$index=' 9 9 9
			print_variables "hello"
			delete_array hello
			echo array hello is deleted, printing hello vars
			print_variables "hello"
		)
		(exit
			create_array hey '$name$index=' 3 5 6
			print_variables "hey"
			reduce_dim hey 2
			print_variables "hey"
		)
		(
			create_array hoo '$name$index=s' 2 4
			print_variables "hoo"
			expand_dim hoo 3 4 7
			reduce_dim hoo 0 0 0 0 0
			print_variables "hoo"
		)
		(
			exit	
		)
	}


	print_variables () {
		name=$1
		echo "$(set)" | sed -r '{
			/^'"$name"'(_([a-z]*|[0-9]*))*=/!d
		}'
	}

	Board () {
		local name=$1; shift
		eval Board_${name}_width=$1; shift
		eval Board_${name}_height=$1
		eval 'create_array Board_'"$name"'_array '"'"'$name$index=haha'"'"' $Board_'"$name"'_width $Board_'"$name"'_height'
	}

	expand_dim () {
		local name=$1; shift
		local args="$@"
		local vars=$(echo "$(set)" | sed -r '{
			/^'"$name"'(_([a-z]*|[0-9]*))*=/!d
		}')
		unset $(echo "$vars" | sed '{
			s/=.*$//g	
		}')
		local cell_vars=$(echo "$vars" | sed -r '{
			/^'"$name"'(_[0-9]*)*=/!d
			s/=/$index=/g
		}')
		for cell_var in $cell_vars; {
			create_array $name "$cell_var" $args
		}
		local shape=$(echo "$vars" | sed '{
			/'"$name"'_shape/!d
			s/'"'"'//g
			s/$/ '"$args"'/
			s/^.*=//
		}')
		eval "${name}_shape='$shape'"
		eval "${name}_total=$(reduce_list multiply 1 $shape)"
	}

	reduce_dim () {
		local name=$1; shift
		local args="$@"
		local spec_name=$name
		local n_args=0
		for arg in $args; {
			spec_name+=_$arg
			((n_args++))
		}
		local vars=$(echo "$(set)" | sed -r '{
			/^'"$name"'(_([a-z]*|[0-9]*))*=/!d
		}')
		local spec_vars=$(echo "$vars" | sed '{
			/'"$spec_name"'/!d
			s/'"$spec_name"'/'"$name"'/g
		}')
		! [ "$spec_vars" ] && {
			return 1
		}
		unset $(echo "$vars" | sed '{
			s/=.*$//g
		}')
		eval "$spec_vars"
		local shape=($(echo "$vars" | sed '{
			/'"$name"'_shape=/!d
			s/^.*=//
			s/'"'"'//g
		}'))
		local n_size=0
		for size in ${shape[@]}; {
			((n_size++))
		}
		local spec_shape=
		for ((i=0;i<$n_size;i++)); {
			! ((i+1 > $n_args)) && {
				continue
			}
			spec_shape+="${shape[$i]} "
		}
		eval "${name}_shape='$spec_shape'"
		eval "${name}_total=$(reduce_list multiply 1 $spec_shape)"
	}

	set_array () {
		local name=$1; shift
		local value="$1"; shift
		local args="$@"
		for arg in $args; {
			name+=_$arg
		}
		eval "$name='$value'"	
	}

	get_array () {
		local name=$1; shift
		local args="$@"
		for arg in $args; {
			name+=_$arg
		}
		echo "${!name}"
	}

	delete_array () {
		local name=$1
		unset $(echo "$(set)" | sed -r '{
		/^'"$name"'(_([a-z]*|[0-9]*))*=/!d
			s/=.*$//g
		}')
	}

	create_array () {
		local name=$1; shift
		local lambda="$1"; shift
		local args="$@"
		eval "${name}_shape='$args'"
		eval "${name}_total=$(reduce_list multiply $args)"
		create_array_loop $name "$lambda" "" $args
	}

	reduce_list () {
		local lambda=$1; shift
		local prev_arg=$1; shift
		local args="$@"
		for arg in $args; {
			prev_arg=$($lambda $prev_arg $arg)
		}
		echo $prev_arg
	}

	multiply () {
		echo $(($1 * $2))
	}
		
	create_array_loop () {
		local name=$1; shift
		local lambda="$1"; shift
		local index=$1; shift
		local size=$1; shift
		! [ $size ] && {
			local lambda=$(eval echo $lambda)
			eval $lambda
			return
		}
		local args="$@"
		local i=0
		for ((;i<$size;i++)); {
			create_array_loop $name "$lambda" ${index}_$i $args
		}
	}

	lambda () {
		echo 
	}
	
	main
)
