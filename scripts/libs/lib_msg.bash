err() {
	printf '%s: E: %s\n' "$SCRIPT_NAME" "$1" >&2
}

errn() {
	printf '%s: E: %s' "$SCRIPT_NAME" "$1" >&2
}


die() {
	err "$2"
	exit $1
}

msg() {
	printf '%s: %s\n' "$SCRIPT_NAME" "$1"
}

msgn() {
	printf '%s: %s' "$SCRIPT_NAME" "$1"
}