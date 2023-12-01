#!/usr/bin/gawk -f

function push_back(arr, elem) {arr[length(arr)+1] = elem} 

# includes comment and blank lines
function skip_nonrelevant_lines(line) {
	pos = match(line, "^[:blank:]*([#]+.*)?$")
	if(pos != 0) { next }
}

BEGIN {
	FS = "="
	delete var_names[0]
	max_var_name_len = 0
}

{
	skip_nonrelevant_lines($0)
	push_back(var_names, $1)
	var_name_len = length($1)
	if(max_var_name_len < var_name_len) { max_var_name_len = var_name_len }
}

END {
	if(mode == "") {
		for(i in var_names) {
			if(!seen[var_names[i]]++) {
				pad = sprintf("%" max_var_name_len + 1 - length(var_names[i]) "s", " ")
				printf("%1$s:%2$s\"$%1$s\"\n", var_names[i], pad)
			}
		}
	}
	if(mode == "raw") {
		for(i in var_names) {
			if (!seen[var_names[i]]++) {
				print(var_names[i])
			}
		}
	}
}