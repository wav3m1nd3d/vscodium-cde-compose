#!/bin/awk -f
BEGIN {
	open_quote = ""
	open_EOF=""
	FS=" |\t"
}

function push_back(arr, elem) {arr[length(arr)+1] = elem} 

function rm_leading_blank(str) {
	pos = match(str, "^[[:blank:]]+")
	if(pos != 0) {
		str = substr(str, RLENGTH+1, length(str))
	}
	return str
}

function _rm_first_squoted(str, pos) {
	str_crop = substr(str, pos+1, length(str) - pos)
	crop_pos = match(str_crop, "'")
	if(crop_pos == 0) {
		if(open_quote == "") {
			open_quote = "''"
		}
		else {
			open_quote = ""
		}
	}
	return substr(str, 1, pos-1) substr(str, crop_pos+pos+1, length()-crop_pos+pos)
}

function _rm_first_dquoted(str, pos) {
	str_crop = substr(str, pos+1, length(str) - pos)
	crop_pos = match(str_crop, "\"")
	if(crop_pos == 0) {
		if(open_quote == "") {
			open_quote = "\"\""
		}
		else {
			open_quote = ""
		}
	}
	return substr(str, 1, pos-1) substr(str, crop_pos+pos+1, length()-crop_pos+pos)
}

function rm_first_squoted(str) {
	if(open_quote == "") {
		sdquote_pos = match(str, "'[^\"']*\"?")
		if(sdquote_pos != 0) {
			return _rm_first_sdquoted(str, sdquote_pos)
		}
		return str
	}
	else if(open_quote == "\"\"" || open_quote == "''") {
		open_quote = substr(open_quote, 1, 1)
		return str
	}
	else if(open_quote == "'") {
		squote_pos = match(str, "'")
		if(squote_pos == 0) {
			next
		}
		open_quote = ""
		return substr(str, squote_pos+1, length(str))
	}
	dquote_pos = match(str, "\"")
	if(dquote_pos == 0) {
		next
	}
	open_quote = ""
	return substr(str, dquote_pos+1, length(str))
}

function rm_first_quoted(str) {
	if(open_quote == "") {
		squote_pos = match(str, "'")
		dquote_pos = match(str, "\"")
		if(squote_pos != 0) {
			if(dquote_pos != 0 && squote_pos > dquote_pos) {
				return _rm_first_dquoted(str, dquote_pos)
			}
			return _rm_first_squoted(str, squote_pos)
		}
		if(dquote_pos != 0) {
			return _rm_first_dquoted(str, dquote_pos)
		}
		return str
	}
	else if(open_quote == "\"\"" || open_quote == "''") {
		open_quote = substr(open_quote, 1, 1)
		return str
	}
	else if(open_quote == "'") {
		squote_pos = match(str, "'")
		if(squote_pos == 0) {
			next
		}
		open_quote = ""
		return substr(str, squote_pos+1, length(str))
	}
	dquote_pos = match(str, "\"")
	if(dquote_pos == 0) {
		next
	}
	open_quote = ""
	return substr(str, dquote_pos+1, length(str))
}

function rm_quoted(str) {
	while(str != str_old) {
		str_old = str
		str = rm_first_quoted(str)
	}
	return str
}

function rm_const_quoted(str) {
	while(str != str_old) {
		str_old = str
		str = rm_first_squoted(str)
	}
	return str
}

function rm_const_EOF(str) {
	if(open_EOF == "") {
		pos = match(str, "[[:blank:]]+<<[[:alnum:]]+[[:blank:]]+")
		if(pos != 0) {
			str_cropd = substr(str, 1, pos) substr(str, pos+RLENGTH, length(str))
			EOF_val = rm_leading_blank(substr(str, pos+1, RLENGTH-2))
			EOF_pos = match(EOF_val, "^<<[[:alnum:]]+")
			open_EOF = substr(EOF_val, EOF_pos+2, RLENGTH-2)
			return str_cropd
		}
		return str
	}
	if (str ~ "^"open_EOF"$") { open_EOF = "" }
	next
}

# function rm_const(str) {
# 	return rm_const_quoted(rm_const_EOF(str))
# }

# includes comment and blank lines
function skip_nonrelevant_lines(line) {
	pos = match(line, "^[:blank:]*([#]+.*)?$")
	if(pos != 0) { next }
}


# script == "bash" && search == "declared" {
# 	skip_nonrelevant_lines($0)
# 	line = rm_leading_blank($0) 
# 	pos = match($0, "^[:blank:]*[[:alnum:]_.]+=")
# 	if(pos != 0) {
# 		print(substr($0, pos, RLENGTH - 1))
# 	}
# 	else {
# 		pos = match($0, "^[:blank:]*declare[:blank:]*(-[aAfFgiIlnrtux])?[:blank:]*[[:alnum:]_.]+=")
# 		if(pos != 0) {
# 			print(substr($0, pos, RLENGTH - 1))
# 		}
# 	}
# }

script == "bash" && search == "used" {
	line = rm_quoted(rm_const_EOF($0))
	skip_nonrelevant_lines(line)
	line = rm_leading_blank(line)
	print(line)
}

# script == "Dockerfile" && search == "ARG" {
# 	pos = match($0, "^[[:blank:]]*ARG[[:blank:]]+")
# 	if(pos != 0) {
# 		print(substr($0, pos+RLENGTH, length($0)))
# 	}
# }

# script == "Dockerfile" && search == "ENV" {
# 	pos = match($0, "^[[:blank:]]*ENV[[:blank:]]+")
# 	if(pos != 0) {
# 		print(substr($0, pos+RLENGTH, length($0)))
# 	}
# }

# script == "Dockerfile" && search == "used" {

# }