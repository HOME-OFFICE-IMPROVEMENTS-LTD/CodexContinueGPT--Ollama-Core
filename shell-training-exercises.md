# Shell Training Exercise Examples

This document contains sample exercises for each shell training lesson. These exercises serve as a reference for what might be generated for each lesson by the shell training guide.

## Lesson 1: Basic Navigation

### Exercise 1.1
**Task**: Find your current directory path.
**Hint**: Use the print working directory command.
**Solution**: `pwd`
**Explanation**: The `pwd` command displays the full path to your current working directory, helping you understand where you are in the file system.

### Exercise 1.2
**Task**: List all files in the current directory, including hidden files.
**Hint**: Use the list command with options for long format and showing all files.
**Solution**: `ls -la`
**Explanation**: The `ls` command lists directory contents. The `-l` flag shows details in long format, and `-a` includes hidden files (those starting with a dot).

### Exercise 1.3
**Task**: Navigate to your home directory.
**Hint**: Use the change directory command with a special shortcut.
**Solution**: `cd ~` or simply `cd`
**Explanation**: The `cd` command changes your current directory. The tilde (~) represents your home directory, and `cd` without arguments defaults to your home directory.

### Exercise 1.4
**Task**: Navigate up one level from your current directory.
**Hint**: Use the change directory command with a special notation for the parent directory.
**Solution**: `cd ..`
**Explanation**: The double dots `..` represent the parent directory, so this command moves you up one level in the directory structure.

### Exercise 1.5
**Task**: Navigate to the root directory and then back to your previous location.
**Hint**: Use the change directory command with the root path, then use a special notation to return.
**Solution**: `cd /` followed by `cd -`
**Explanation**: The `/` represents the root directory. The `cd -` command returns you to your previous directory location.

## Lesson 2: File Operations

### Exercise 2.1
**Task**: Create a new empty file named "myfile.txt".
**Hint**: Use the command that "touches" a file to create it.
**Solution**: `touch myfile.txt`
**Explanation**: The `touch` command creates an empty file if it doesn't exist, or updates its timestamp if it already exists.

### Exercise 2.2
**Task**: Create a new directory named "mydir" and a subdirectory inside it called "subdir".
**Hint**: Use the make directory command with the option to create parent directories as needed.
**Solution**: `mkdir -p mydir/subdir`
**Explanation**: The `mkdir` command creates directories. The `-p` option allows it to create the parent directory first if needed.

### Exercise 2.3
**Task**: Copy "myfile.txt" to the "mydir" directory with a new name "copy.txt".
**Hint**: Use the copy command with source and destination paths.
**Solution**: `cp myfile.txt mydir/copy.txt`
**Explanation**: The `cp` command copies files. The first argument is the source file, and the second is the destination.

### Exercise 2.4
**Task**: Move "myfile.txt" into the "mydir" directory.
**Hint**: Use the move command with source and destination paths.
**Solution**: `mv myfile.txt mydir/`
**Explanation**: The `mv` command moves files or directories from one location to another.

### Exercise 2.5
**Task**: Remove the "mydir" directory and all its contents.
**Hint**: Use the remove command with options for recursive and force.
**Solution**: `rm -rf mydir`
**Explanation**: The `rm` command removes files. The `-r` option is for recursive deletion (for directories and their contents), and `-f` forces deletion without prompting.

## Lesson 3: Text Processing

### Exercise 3.1
**Task**: Display the contents of a file named "sample.txt".
**Hint**: Use the command that concatenates and displays file contents.
**Solution**: `cat sample.txt`
**Explanation**: The `cat` command reads files and outputs their contents to the standard output.

### Exercise 3.2
**Task**: Search for the word "example" in "sample.txt".
**Hint**: Use the global regular expression print command.
**Solution**: `grep "example" sample.txt`
**Explanation**: The `grep` command searches for patterns in files. It displays the lines containing matches.

### Exercise 3.3
**Task**: Display the first 5 lines of "sample.txt".
**Hint**: Use the command that shows the beginning of a file.
**Solution**: `head -n 5 sample.txt`
**Explanation**: The `head` command outputs the first part of files. The `-n 5` option specifies to show the first 5 lines.

### Exercise 3.4
**Task**: Replace all occurrences of "old" with "new" in "sample.txt".
**Hint**: Use the stream editor command.
**Solution**: `sed 's/old/new/g' sample.txt`
**Explanation**: The `sed` command is a stream editor for filtering and transforming text. The 's/old/new/g' syntax substitutes "old" with "new" globally in each line.

### Exercise 3.5
**Task**: Count the number of lines in "sample.txt".
**Hint**: Use the word count command with an option for lines.
**Solution**: `wc -l sample.txt`
**Explanation**: The `wc` command counts lines, words, and characters. The `-l` option indicates to count only lines.

## Lesson 4: Pipes and Redirection

### Exercise 4.1
**Task**: Redirect the output of `ls -l` to a file named "directory_contents.txt".
**Hint**: Use the redirection operator to save command output to a file.
**Solution**: `ls -l > directory_contents.txt`
**Explanation**: The `>` operator redirects standard output to a file, overwriting its contents if the file already exists.

### Exercise 4.2
**Task**: Append the text "New line" to the end of "directory_contents.txt".
**Hint**: Use the append redirection operator.
**Solution**: `echo "New line" >> directory_contents.txt`
**Explanation**: The `>>` operator appends standard output to a file without overwriting existing content.

### Exercise 4.3
**Task**: List all files in the current directory that end with ".txt".
**Hint**: Use a pipe to combine listing and filtering commands.
**Solution**: `ls | grep "\.txt$"`
**Explanation**: The pipe (`|`) sends the output of `ls` as input to `grep`, which filters for filenames ending with ".txt".

### Exercise 4.4
**Task**: Count the number of files in the current directory.
**Hint**: Use pipes to combine listing and counting.
**Solution**: `ls | wc -l`
**Explanation**: This pipes the output of `ls` to `wc -l`, which counts the number of lines in the output, effectively counting the files.

### Exercise 4.5
**Task**: Sort the lines in "sample.txt" and save the unique lines to "unique.txt".
**Hint**: Use pipes to combine sort and unique operations.
**Solution**: `sort sample.txt | uniq > unique.txt`
**Explanation**: The `sort` command arranges lines in order, `uniq` removes duplicate adjacent lines, and `>` redirects the result to a new file.

## Lesson 5: Shell Scripting Basics

### Exercise 5.1
**Task**: Create a simple shell script that prints "Hello, World!".
**Hint**: Use a text editor to create a script with a shebang and an echo command.
**Solution**:
```bash
#!/bin/bash
echo "Hello, World!"
```
**Explanation**: The first line (shebang) tells the system to use the bash interpreter. The second line uses `echo` to print the text.

### Exercise 5.2
**Task**: Make your script executable and run it.
**Hint**: Use chmod to add execute permissions, then run with ./
**Solution**:
```bash
chmod +x hello.sh
./hello.sh
```
**Explanation**: The `chmod +x` adds executable permission, and `./hello.sh` runs the script from the current directory.

### Exercise 5.3
**Task**: Create a script that accepts a name as an argument and greets that name.
**Hint**: Use a variable to reference the first command-line argument.
**Solution**:
```bash
#!/bin/bash
echo "Hello, $1!"
```
**Explanation**: The `$1` variable refers to the first command-line argument provided to the script.

### Exercise 5.4
**Task**: Write a script that checks if a file exists.
**Hint**: Use an if statement with the -f condition.
**Solution**:
```bash
#!/bin/bash
if [ -f "$1" ]; then
    echo "File exists."
else
    echo "File does not exist."
fi
```
**Explanation**: The `-f` test operator checks if a file exists and is a regular file. The script uses an if-else structure for conditional execution.

### Exercise 5.5
**Task**: Create a script that counts from 1 to 10.
**Hint**: Use a for loop with a sequence.
**Solution**:
```bash
#!/bin/bash
for i in {1..10}; do
    echo $i
done
```
**Explanation**: The for loop iterates through each value in the range from 1 to 10, and `echo $i` prints the current value.

## Lesson 6: Process Management

### Exercise 6.1
**Task**: List all running processes.
**Hint**: Use the process status command.
**Solution**: `ps aux`
**Explanation**: The `ps` command shows process information. The options `a` (all with terminals), `u` (user-oriented format), and `x` (processes without terminals) show a comprehensive list.

### Exercise 6.2
**Task**: Start a process in the background.
**Hint**: Append an ampersand to the command.
**Solution**: `sleep 100 &`
**Explanation**: The `&` at the end of a command runs it in the background, allowing you to continue using the terminal.

### Exercise 6.3
**Task**: Find the process ID (PID) of a running program.
**Hint**: Use the ps command with grep.
**Solution**: `ps aux | grep "program_name"`
**Explanation**: This pipes the output of `ps aux` to `grep`, which filters for lines containing the program name, showing its PID and other details.

### Exercise 6.4
**Task**: Terminate a process using its PID.
**Hint**: Use the kill command.
**Solution**: `kill PID` or for force `kill -9 PID`
**Explanation**: The `kill` command sends a signal to a process. By default, it sends the TERM signal, while `-9` sends the KILL signal, which forces termination.

### Exercise 6.5
**Task**: Monitor system resources in real-time.
**Hint**: Use the table of processes command.
**Solution**: `top` or `htop` if available
**Explanation**: The `top` command provides a dynamic real-time view of running processes. `htop` is an enhanced version with more features and a better interface.

## Lesson 7: User and Permissions

### Exercise 7.1
**Task**: Check who you are currently logged in as.
**Hint**: Use the "who am I" command.
**Solution**: `whoami`
**Explanation**: The `whoami` command displays the effective username of the current user.

### Exercise 7.2
**Task**: Check the permissions of a file.
**Hint**: Use the list command with the long format.
**Solution**: `ls -l filename`
**Explanation**: The `-l` option shows detailed information including permissions, owner, group, size, and modification time.

### Exercise 7.3
**Task**: Change a script to be executable for the owner only.
**Hint**: Use chmod with octal notation.
**Solution**: `chmod 700 script.sh`
**Explanation**: In octal notation, 7 (4+2+1) means read, write, and execute permissions. 700 gives full permissions to the owner and none to group or others.

### Exercise 7.4
**Task**: Make a file readable and writable by everyone.
**Hint**: Use chmod with symbolic notation.
**Solution**: `chmod a+rw file.txt`
**Explanation**: The symbolic notation `a+rw` adds read and write permissions for all users (owner, group, and others).

### Exercise 7.5
**Task**: Change the owner of a file.
**Hint**: Use the change owner command.
**Solution**: `sudo chown newowner file.txt`
**Explanation**: The `chown` command changes file ownership. `sudo` is needed because changing ownership typically requires administrative privileges.

## Lesson 8: Environment Variables

### Exercise 8.1
**Task**: Display all environment variables.
**Hint**: Use the command that prints environment.
**Solution**: `env` or `printenv`
**Explanation**: Both commands display all environment variables and their values.

### Exercise 8.2
**Task**: Check the value of the PATH environment variable.
**Hint**: Use echo with the variable name.
**Solution**: `echo $PATH`
**Explanation**: This displays the value of the PATH variable, which contains directories where executable programs are located.

### Exercise 8.3
**Task**: Create a new environment variable called MY_VAR with value "hello".
**Hint**: Use the export command.
**Solution**: `export MY_VAR="hello"`
**Explanation**: The `export` command makes a variable available to child processes. This creates a new environment variable that persists for the current session.

### Exercise 8.4
**Task**: Add a directory to your PATH temporarily.
**Hint**: Use export with the PATH variable.
**Solution**: `export PATH=$PATH:/new/directory`
**Explanation**: This appends a new directory to the existing PATH, separating it with a colon.

### Exercise 8.5
**Task**: Create a permanent environment variable by adding it to your shell profile.
**Hint**: Edit your .bashrc or .bash_profile file.
**Solution**: `echo 'export MY_VAR="hello"' >> ~/.bashrc`
**Explanation**: This adds the export command to your bash configuration file, making the variable available in all future sessions.

## Lesson 9: Regular Expressions

### Exercise 9.1
**Task**: Find all lines containing a date in format "YYYY-MM-DD" in a file.
**Hint**: Use grep with a regular expression.
**Solution**: `grep -E "[0-9]{4}-[0-9]{2}-[0-9]{2}" filename.txt`
**Explanation**: The `-E` option enables extended regular expressions. The pattern matches 4 digits, followed by a dash, 2 digits, dash, and 2 more digits.

### Exercise 9.2
**Task**: Extract all email addresses from a file.
**Hint**: Use grep with a more complex regular expression.
**Solution**: `grep -Eo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' filename.txt`
**Explanation**: The `-o` option shows only the matching part. The pattern matches the structure of an email address.

### Exercise 9.3
**Task**: Replace all occurrences of "color" with "colour" in a file.
**Hint**: Use sed with a basic substitution.
**Solution**: `sed 's/color/colour/g' filename.txt`
**Explanation**: The `s/` command in sed substitutes patterns. The `g` flag makes the substitution global (all occurrences).

### Exercise 9.4
**Task**: Remove all blank lines from a file.
**Hint**: Use sed with a pattern that matches empty lines.
**Solution**: `sed '/^$/d' filename.txt`
**Explanation**: The `d` command in sed deletes lines. The pattern `^$` matches lines that have nothing between the beginning (`^`) and end (`$`).

### Exercise 9.5
**Task**: Print only the second column from a space-separated file.
**Hint**: Use awk to select fields.
**Solution**: `awk '{print $2}' filename.txt`
**Explanation**: Awk automatically splits lines into fields. `$2` refers to the second field, and `print` outputs it.

## Lesson 10: Advanced Scripting

### Exercise 10.1
**Task**: Create a script that takes a directory as an argument and counts the files in it.
**Hint**: Use command substitution to capture the output of ls and wc.
**Solution**:
```bash
#!/bin/bash
if [ -d "$1" ]; then
    count=$(ls -l "$1" | grep -v "^total" | grep -v "^d" | wc -l)
    echo "The directory $1 contains $count files."
else
    echo "Error: $1 is not a directory."
    exit 1
fi
```
**Explanation**: The script checks if the argument is a directory, then uses command substitution `$()` to get the file count, excluding the "total" line and directories.

### Exercise 10.2
**Task**: Write a script that finds all .txt files in a directory and its subdirectories.
**Hint**: Use the find command with proper options.
**Solution**:
```bash
#!/bin/bash
if [ -d "$1" ]; then
    echo "Finding all .txt files in $1:"
    find "$1" -type f -name "*.txt"
else
    echo "Error: $1 is not a directory."
    exit 1
fi
```
**Explanation**: The `find` command searches for files. `-type f` specifies regular files, and `-name "*.txt"` filters for .txt files.

### Exercise 10.3
**Task**: Create a backup script that compresses a directory.
**Hint**: Use tar to create a compressed archive.
**Solution**:
```bash
#!/bin/bash
if [ -d "$1" ]; then
    backup_file="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    echo "Creating backup of $1 to $backup_file..."
    tar -czvf "$backup_file" "$1"
    echo "Backup completed."
else
    echo "Error: $1 is not a directory."
    exit 1
fi
```
**Explanation**: The script creates a unique filename using the current date and time, then uses `tar` with options for create (`-c`), gzip compression (`-z`), verbose (`-v`), and specifying the output file (`-f`).

### Exercise 10.4
**Task**: Write a script that monitors system load and alerts if it exceeds a threshold.
**Hint**: Use the uptime command and awk to extract the load average.
**Solution**:
```bash
#!/bin/bash
threshold=${1:-1.0}  # Default to 1.0 if no argument provided
while true; do
    load=$(uptime | awk '{print $(NF-2)}' | tr -d ',')
    if (( $(echo "$load > $threshold" | bc -l) )); then
        echo "WARNING: System load is $load (threshold: $threshold)"
    else
        echo "System load is $load (normal)"
    fi
    sleep 5
done
```
**Explanation**: The script extracts the 1-minute load average from the uptime command, compares it to the threshold using the `bc` calculator, and alerts if it's too high.

### Exercise 10.5
**Task**: Create a script that takes a filename and performs different actions based on its extension.
**Hint**: Use a case statement to handle different extensions.
**Solution**:
```bash
#!/bin/bash
if [ -f "$1" ]; then
    filename=$(basename "$1")
    extension="${filename##*.}"
    case "$extension" in
        txt|md)
            echo "Text file detected. Displaying contents:"
            cat "$1"
            ;;
        jpg|png|gif)
            echo "Image file detected. Checking file info:"
            file "$1"
            ;;
        sh)
            echo "Shell script detected. Checking syntax:"
            bash -n "$1" && echo "Syntax is valid."
            ;;
        *)
            echo "Unknown file type: $extension"
            ;;
    esac
else
    echo "Error: $1 is not a file."
    exit 1
fi
```
**Explanation**: The script extracts the file extension using parameter expansion, then uses a case statement to perform different actions based on the extension type.
