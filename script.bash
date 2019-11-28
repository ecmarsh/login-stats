#!/usr/bin/env bash

# ASSIGNMENT
#   Title     COMSC171 Bash Program -- Login Stats
#   Author    Ethan Marsh
#   Date      Thu Nov 28 2019
#
# script.bash
#   Reports login statistics from the UNIX `last`
#   command, provided via standard input.
#   Accepts one (1) option: either '-c' for count or
#   '-t' for total time, displayed as total minutes. 
#
# SYNTAX
#   last | bash script.bash [-ct]
#
# OPTIONS
#   -c  Display total completed sessions for each valid user.
#   -t  Display total completed session time for each valid user.
#
# If no options are provided, the result of the previous command,
# assumably `last`, is printed with no modifications.
# 
# Completed sessions are those that are not 'still logged in'.
# 
# Valid users have a username taking the form of a student
# username, 'fa19u##', or the professor name, 'stuart'.
#
# The return status is always zero with valid syntax.
#


declare -A LOGIN_STATS  # {["username"]:login count||total minutes}


function print_results() {

  # Prints key and value of user_login_map, sorted by
  # value, either count or minutes, in descending order.

  local Report_Title=$1; local Unit_Label=$2

  echo -e "\n\033[1;33m ${Report_Title} \033[0m"

  { for user in "${!LOGIN_STATS[@]}"; do
      printf "   %7s:  %'d %s\n" "$user" "${LOGIN_STATS["$user"]}" "$Unit_Label"
    done; } | sort -nrk2

  echo
}


function display_login_count() {

  # Display the number of completed sessions for each valid user.

  while read -r line; do
    # Ignore users still logged in and that aren't 'fa19u##' or 'stuart'.
    [[ "$line" =~ in$ || (! "$line" =~ ^[fs]) ]] && continue
    # Increment count of the user in the associative array.
    user=$(cut -f1 -d' ' <<<"$line")
    ((LOGIN_STATS["$user"]++))
  done

  # Print each username and their total number of logins.
  print_results 'TOTAL LOGIN COUNT PER USER' 'logins'
}


function display_login_time() {

  # Display total login time in minutes for each valid user.

  while read -r line; do
    # Ignore users still logged in and that aren't 'fa19u##' or 'stuart'.
    [[ "$line" =~ in$ || (! "$line" =~ ^[fs]) ]] && continue

    # Store the username and the last field, session time, stripped of parens.
    IFS=" " read -r user sess_time <<<"$(awk '{gsub(/[()]/,"",$NF); print $1, $NF}' <<<"$line")"

    # Convert days and hours to total minutes for session.
    # Note: Using 1-line awk statements for arithmetic to handle leading zeros.

    declare -i minutes=0

    # If session has a day, add converted days as minutes (days * 60 * 24)
    # to total session, and update session time value to be only HH:MM portion.
    if [[ $sess_time =~ \+ ]]; then
      IFS=" " read -r minutes sess_time <<<"$(awk -F+ '{print $1 * 60 * 24, $2}' <<<"$sess_time")"
    fi

    # Parse HH:MM by converting hours to minutes and adding.
    ((minutes += $(awk -F: '{ print $1 * 60 + $2 }' <<<"$sess_time")))

    # Add total minutes for current session to user's total time.
    ((LOGIN_STATS["$user"] += minutes))
  done

  # Print each username and their total login minutes.
  print_results 'TOTAL LOGIN TIME PER USER' 'minutes'
}


function print_all_stdin() {
  # Simply echo every line of STDIN as received.
  while read -r line; do echo "$line"; done
}


# MAIN: call appropriate handler according to flag.
case "$1" in
  -c) display_login_count ;;
  -t) display_login_time  ;;
   *) print_all_stdin     ;;
esac


exit 0
