# Reads output from last command on on STDIN.
#
# If -c is given, program outputs lines with user and login count,
# sorted by login count.
#
# If -t option is given, program outputs user and login time,
# sorted by login time.
#
# If no flag is given, entire last command is passed.
#
# USAGE: last | bash script.bash [-ct]


print_login_counts () {

	# Outputs total login count for users "fa19u##" or "stuart"

	declare -A login_count_map  # { [username]: login_cnt }

	while read line
	do
		# Ignore users still logged in and that aren't 'fa19u##' or 'stuart'
		if [[ "$line" =~ in$ || ( ! "$line" =~ ^[fs] ) ]]; then
			continue
		fi
		# Increment count of the user
		user=$( echo $line | awk '{ print $1 }' )
		(( login_count_map["$user"]++ ))
	done

	# Print formatted key, value of map, sorted by login count.

	echo -e "\nUser Login Counts:"

	{ for user in "${!login_count_map[@]}"; do
		 printf "  %7s:  %d\n" "$user" "${login_count_map["$user"]}"
	done } | sort -nrk2

	echo 


	return
}

print_login_ttl_time () {

	# Outputs lines with user and total login time.

	declare -A login_time_map   # { [username]: DD:HH:MM  }
	declare -A login_days login_hrs login_mins

	while read line
	do
		# Ignore users still logged in and that aren't 'fa19u##' or 'stuart'
		if [[ "$line" =~ in$ || ( ! "$line" =~ ^[fs] ) ]]; then
			continue
		fi
		user=$( echo $line | awk '{ print $1 }' )
		unfmtd_time=$( echo $line | awk '{ print $NF }' | sed 's/[()]//g' )

		echo $unfmtd_time
	done

	# Print formatted key, value of map, sorted by login count.

	echo -e "\nTotal logged in time per user:"

	{ for user in "${!login_time_map[@]}"; do
		 printf "  %s:  %d\n" "$user" "${login_time_map["$user"]}"
	done } | sort -nrk2

	echo


	return
}

print_all_stdin () {

	# Simply echo every line of STDIN as received
	while read input_line 
		do echo "$input_line"
	done 

	return
}


# Call appropriate handler to print output according to arg option

FLAG=$1

if [[ $FLAG = '-c'  ]]; then
	print_login_counts
elif [[ $FLAG = '-t' ]]; then
	print_login_ttl_time
else 
	print_all_stdin
fi


exit 0
