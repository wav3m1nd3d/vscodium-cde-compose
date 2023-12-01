source_compose_env() {
	local env_file="$1"
	local var_names=()
	while read line; do
		if [[ "$line" =~ ^[[:blank:]]*[[:alnum:]_.]+\= ]]; then 
			[[ "$line" =~ ^[[:blank:]]+ ]] && line="${line#* }"
			if [[ "$line" = "HOST_CDE_DIR="* ]]; then
				var_names+=("HOST_CDE_DIR")
				HOST_CDE_DIR="$CDE_BAREBOOT_ROOT_DIR"
			else
				var_names+=("${line%%=*}")
				eval "$line"
			fi
			# TODO: perform checks to deny code execution from .env with graceful fail
		fi
	done <"$env_file"

	for var_name in ${var_names[@]}; do
		declare -g "CDE_$var_name"="$(eval echo \"\$$var_name\")"
		unset "$var_name"
	done
}