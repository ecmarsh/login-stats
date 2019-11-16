# COMSC171 Assignment 1: login-stats

Write a bash program to calculate login statistics from output of the last command.

Sample `last` output:

```sh
USER     TTY          IP ADDR          DAY DATE   LOGIN   LOGOUT TIME
fa19u99  pts/0        1.2.3.4          Fri Nov  8 22:00 - 23:30  (01:29)
```

## Specs

### Inputs

- output from last command on STDIN
- one option on command line: `-c` for count or `-t` for time
- example usage: `last | bash script.bash -c`

### Outputs

- lines with user and login count, sorted by login count (with -c option)
- lines with user and login time, sorted by login time (with -t option)

### Conditions

- last output contains only printing characters, spaces, and newlines.
- Ignore lines beginning with reboot or ending with still logged in.

## Requirements

- Use only bash and standard UNIX test utilities
  - Single lines of sed or awk are OK.
  - Do not use ac or other UNIX accounting tools.
- Read from standard input, write to standard output.
  - Do not use disk files for input or output.
  - Do not output prompts or read interactive input.
- Do not check for invalid input.

## Documentation

- Comments
  - Include name, date, assignment.
  - Include brief instructions for using the program.
  - Include brief explanations of algorithms.
  - Include brief explanations of data structures.
- Use descriptive names for variables and functions.
- Use a consistent style to indent code blocks.

## Due Date

This assignment is due **Dec 02 at 11:10 AM**.

Email your program (where script.bash is the name of your file) with this command:

```sh
mail -s 'assignment' stuart < script.bash
```

### Hints

- Start early, this may take longer than you expect.
- Think about the structure of your data and logic before you write any code.
- With each revision add the smallest possible amount of code.
- Test your code with a variety of inputs.
- Add comments as necessary.
- Save your code with another name.
