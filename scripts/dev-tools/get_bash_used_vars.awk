#!/usr/bin/gawk -f

function push_back(arr, elem) {arr[length(arr)+1] = elem} 

function get_used_var_name(str, var_names) {
	pos = match(str, "[$]([[:alnum:]_]+|[{][[:alnum:]_]+[}])")
	if(pos != 0) {
		# print("match")
		push_back(var_names, substr(str, pos, RLENGTH))
	}
	return substr(str, 1, pos - 1) substr(str, pos + RLENGTH + 1, length(str) - RLENGTH - pos)
}

function get_used_var_names(str, var_names) {
	str_old = ""
	while(str_old != str) {
		str_old = str
		str = get_used_var_name(str, var_names)
	}
}

{
	delete var_names[0]
	get_used_var_names($0, var_names)
	for(i in var_names) {
		if(!seen[var_names[i]]++) {
			print(var_names[i])
		}
	}
}