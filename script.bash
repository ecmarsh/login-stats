#! /bin/bash

# Reads output from last command on on STDIN.

# If -c is given, program outputs lines with user and login count,
# sorted by login count.

# If -t option is given, program outputs user and login time,
# sorted by login time.

# If no flag is given, entire last command is passed.

# USAGE: last | bash script.bash [-ct]


declare -A user_login_map  # { ["username"]: login_counts || total_minutes }

function print_map() {
  # Prints key and value of user_login_map sorted in descending order.
  local TITLE=$1
  local UNIT=$2
  
  echo -e "\n\033[1;33m ${TITLE}: \033[0m"

  { for user in "${!user_login_map[@]}"; do
    printf "  %7s:  %'d %s\n" "$user" "${user_login_map["$user"]}" "$UNIT"
  done; } | sort -nrk2

  echo

  return
}


function print_login_counts() {

  # Outputs lines with username and total login count.

  while read -r line; do

    # Ignore users still logged in and that aren't 'fa19u##' or 'stuart'.
    [[ "$line" =~ in$ || (! "$line" =~ ^[fs]) ]] && continue

    # Increment count of the user.
    user=$(awk '{print $1}' <<<"$line")
    ((user_login_map["$user"]++))

  done

  # Print each username and their total number of sessions.
  print_map 'TOTAL USER LOGIN COUNTS' 'logins'


  return
}


function print_login_time() {

  # Outputs lines with user and total login time.

  while read -r line; do

    # Ignore users still logged in and that aren't 'fa19u##' or 'stuart'.
    [[ "$line" =~ in$ || (! "$line" =~ ^[fs]) ]] && continue

    # Store username and the last field, session time, stripped of parens.
    user=$(awk '{ print $1 }' <<<"$line")
    sess_time=$(echo "$line" | awk '{ print $NF }' | sed 's/[()]//g')

    # Convert days and hours to total minutes for session.
    # Note: Using 1-line awk statements for arithmetic to handle leading zeros.
    typeset -i minutes=0

    # If session has a day, add converted days as minutes (days * 60 * 24),
    # to total session and update session_time to only HH:MM portion.
    if [[ $sess_time =~ \+ ]]; then
      # A[0] = days converted to minutes, A[1] = HH:MM
      # TODO: replace with mapfile
      A=($(awk -F+ '{ print $1 * 60 * 24 ; print $2 }' <<<"$sess_time"))
      ((minutes += A[0]))
      sess_time=${A[1]}
    fi

    # Parse HH:MM by converting hours to minutes and summing.
    ((minutes += $(awk -F: '{ print $1 * 60 + $2 }' <<<"$sess_time")))

    # Add total minutes for current session to user login total time.
    ((user_login_map["$user"] += minutes))

  done

  # Print each username and their total login minutes.
  print_map 'TOTAL LOGGED IN TIME PER USER' 'minutes'


  return
}

function print_all_stdin() {

  # Simply echo every line of STDIN as received.

  while read -r line
    do echo "$line"
  done

}

# MAIN: call appropriate handler according to flag.
case $1 in
  -c) print_login_counts ;;
  -t) print_login_time   ;;
   *) print_all_stdin    ;;
esac


exit 0
