# Minishell Project -- ENSEEIHT 1SN Operating System course

A simple UNIX shell implementation written in C. This project simulates the core functionalities of a standard command-line interface, including executing foreground and background processes, handling system signals, and working with built-in commands.

## Features

- **Command Execution:** Run standard UNIX commands by creating child processes.
- **Built-in Commands:** 
  - `cd <path>`: Changes the current working directory. Defaults to `$HOME` if no path is provided.
  - `dir <path>`: Lists the contents of a directory. Defaults to the current directory (`.`) if no path is provided.
  - `exit`: Safely exits the shell.
- **Signal Handling:** 
  - Prevents the shell from exiting when receiving `SIGINT` (Ctrl+C) or `SIGTSTP` (Ctrl+Z).
  - Forwards termination and suspension signals to running child processes properly.
  - Cleans up zombie processes using `SIGCHLD`.
- **Background Processes:** Supports executing processes in the background (using `&`).

## Project Structure

- `minishell.c`: Main program containing the shell loop, signal management, and command routing.
- `readcmd.c` & `readcmd.h`: Library parsing user input into a manageable command structure.
- `Makefile`: Script for compiling the project, cleaning build artifacts, and running tests.
- `test_readcmd.c`: Test file to verify command parsing behaviors.

## How to Compile

The project includes a `Makefile` to simplify the build process. To compile the minishell executable, open your terminal in the project directory and run:

```bash
make
```

To clear out generated compiled files and the executable, you can run:

```bash
make clean
```

*(Optional)* To compile the parsing test executable:

```bash
make test
```

## How to use
Once compiled, you can launch the minishell from your terminal:

```bash
./minishell
```

You will be greeted with the prompt `>`. You can now type your typical OS commands:

```bash
> dir #okay not actually typical to use dir instead of ls but whatever...
> echo "Hello World!"
```

### Built-in functionalities

- **Navigate directories** with `cd`
- **List contents** with `dir`
- **Background execution** by appending `&` to the end of your command.

To quit the shell, use:

```bash
exit
```