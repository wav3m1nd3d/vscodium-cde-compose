
is_git_in_list() {
	cont_pkgs=$1
	for pkg in $cont_pkgs; do
		[[ "$pkg" == 'git' ]] && return 0
	done
	return 1
}
