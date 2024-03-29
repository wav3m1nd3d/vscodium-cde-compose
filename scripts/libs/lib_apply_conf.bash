apply_conf() {
	user="$1"
	name="$2"
	dest="$3"
	if [[ -f "$TEMP_CONFIGS_DIR/${name}_${user}.conf" ]]; then
		cat "$TEMP_CONFIGS_DIR/${name}_${user}.conf" | tee "$dest"
	elif [[ -f "$TEMP_CONFIGS_DIR/${name}_e${user}.conf" ]]; then
		_done=false
		until $_done; do
			read line || _done=true
			eval "echo ${line}"
		done <"$TEMP_CONFIGS_DIR/${name}_e${user}.conf" > "$dest"
	else
		die 1 "Missing configuration files for $name in \"$TEMP_CONFIGS_DIR\" directory, should be named in format ${name}_$user.conf or ${name}_e$user.conf to evaluate variables"
	fi
}