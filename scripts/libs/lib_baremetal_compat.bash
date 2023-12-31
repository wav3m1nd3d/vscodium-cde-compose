# Setup for correct operation in baremetal and containerized modes

source_bareboot_deps() {
	source "$CDE_HOST_SCRIPTS_DIR/libs/lib_find_compose_files.bash"
	source "$CDE_HOST_SCRIPTS_DIR/libs/lib_source_compose_env.bash"
	# TODO: add libbsrc support
}

baremetal_compat_setup() {
	declare -g SCRIPT_NAME="${BASH_SOURCE[1]##*/}"

	if ! [[ -v $CDE_HOST_SCRIPTS_DIR ]]; then
		CDE_HOST_SCRIPTS_DIR="${BASH_SOURCE[1]%/*}/.."
		source_bareboot_deps
		find_compose 'CDE_BAREBOOT_COMPOSE' "$CDE_HOST_SCRIPTS_DIR" 3
		CDE_BAREBOOT_ROOT_DIR="${CDE_BAREBOOT_COMPOSE%/*}"
		find_compose_env 'CDE_BAREBOOT_COMPOSE_ENV' "$CDE_BAREBOOT_ROOT_DIR" 3
		source_compose_env "$CDE_BAREBOOT_COMPOSE_ENV"
	fi
}