find_compose_root_dir() {
	local -n find_compose_root_dir_ref="$1"
	local start_dir="$2"
	local -i search_depth=$3
	
	# Find root cde directory by locating docker-compose.yml in parent directories
	start_pwd="$PWD"
	prev_pwd=''
	local -i found_f=0
	local -i rel_depth=0
	entry=''
	if ! cd "$start_dir" 2>/dev/null; then
		printf "${0##*/}: E: Couldn't find a cde root directory, cannot cd to start directory \"$start_dir\"\n"
		cd "$start_pwd"
		return 1
	fi
	while [[ "$prev_pwd" != "$PWD" && $rel_depth -le $search_depth ]]; do
		for entry in "$PWD"/*; do
			if [[ -f "$entry" && "${entry##*/}" =~ (docker-|podman-)?compose\.ym[a]?l ]]; then
				found_f=1
				break 2
			fi
		done
		rel_depth+=1
		if ! cd .. 2>/dev/null; then
			printf "${0##*/}: E: Couldn't find a cde root directory, access denied to $rel_depth level deep parent directory \n"
			cd "$start_pwd"
			return 1
		fi
	done
	if [[ $found_f -ne 1 ]]; then
		printf "${0##*/}: E: Couldn't find a cde root directory, maximum search depth reached\n"
		cd "$start_pwd"
		return 1
	fi
	find_compose_root_dir_ref="${entry%/*}"
	cd "$start_pwd"
}

find_compose_env() {
	local -n find_compose_env_ref="$1"
	local start_dir="$2"
	local -i search_depth=$3

	# Search in current and child directories for *.env file
	start_pwd="$PWD"
	prev_entry=''
	found_entries=()
	child_dirs=()
	local -i rel_depth=0
	local -i min_depth=0
	if ! cd "$start_dir" 2>/dev/null; then
		printf "${0##*/}: E: Couldn't find a \"*.env\" file, cannot cd to start directory \"$start_dir\"\n"
		cd "$start_pwd"
		return 1
	fi
	while [[ $rel_depth -le $search_depth ]]; do
		for entry in "$PWD"/.* "$PWD"/*; do
			if [[ -f "$entry" ]]; then
				if [[ ${#found_entries[@]} -eq 0 ]]; then
					if [[ "$entry" == ".env" ]]; then
						find_compose_env_ref="$entry"
						cd "$start_pwd"
						return 0
					elif [[ "$entry" == *".env" ]]; then
						min_depth=$rel_depth
						found_entries+=("$entry")
					fi
				else
					if [[ "$entry" == ".env" ]]; then
						find_compose_env_ref="$found_entries"
						cd "$start_pwd"
						return 0
					elif [[ "$entry" == *".env" ]]; then
						if [[ $min_depth -eq $rel_depth ]]; then
							printf "${0##*/}: E: Found multiple \"*.env\" files at same search depth level, can't decide\n"
							cd "$start_pwd"
							return 1
						else
							find_compose_env_ref="$entry"
							cd "$start_pwd"
							return 0
						fi
					fi
				fi
			elif [[ -d "$entry" ]]; then
				child_dirs+=("$entry")
			fi
			if [[ "${entry%/*}" != "${prev_entry%/*}" ]]; then
				rel_depth+=1
			fi
			prev_entry="$entry"
		done
		[[ ${#child_dirs[@]} -eq 0 ]] && break
		while ! cd $child_dirs 2>/dev/null && [[ ${#child_dirs[@]} -gt 1 ]]; do
			child_dirs=("${child_dirs[@]:1}")
		done
		child_dirs=("${child_dirs[@]:1}")
	done
	if [[ ${#found_entries[@]} -eq 0 ]]; then
		printf "${0##*/}: E: Couldn't find an \"*.env\" file, maximum search depth reached\n"
		cd "$start_pwd"
		return 1
	fi
	find_compose_env_ref="$found_entries"
	cd "$start_pwd"
	return 0
}