# Shell Command Cheat Sheet

This reference guide provides a quick overview of essential shell commands organized by category.

## Navigation Commands

| Command | Description | Example |
|---------|-------------|---------|
| `pwd` | Print working directory | `pwd` |
| `ls` | List directory contents | `ls -la` |
| `cd` | Change directory | `cd /home/user/Documents` |
| `find` | Search for files | `find . -name "*.txt"` |
| `which` | Locate a command | `which python` |

## File Operations

| Command | Description | Example |
|---------|-------------|---------|
| `touch` | Create empty file | `touch newfile.txt` |
| `mkdir` | Create directory | `mkdir -p path/to/dir` |
| `cp` | Copy files/directories | `cp -r source/ dest/` |
| `mv` | Move/rename files | `mv oldname.txt newname.txt` |
| `rm` | Remove files/directories | `rm -rf directory/` |
| `chmod` | Change file permissions | `chmod 755 script.sh` |
| `chown` | Change file owner | `chown user:group file.txt` |

## Text Processing

| Command | Description | Example |
|---------|-------------|---------|
| `cat` | Display file contents | `cat file.txt` |
| `grep` | Search text patterns | `grep "pattern" file.txt` |
| `head` | Show first lines | `head -n 10 file.txt` |
| `tail` | Show last lines | `tail -f logfile.log` |
| `sed` | Stream editor | `sed 's/old/new/g' file.txt` |
| `awk` | Text processing | `awk '{print $1}' file.txt` |
| `sort` | Sort lines | `sort -n numbers.txt` |
| `uniq` | Remove duplicates | `sort file.txt | uniq` |
| `wc` | Count lines/words/chars | `wc -l file.txt` |

## Pipes and Redirection

| Symbol | Description | Example |
|--------|-------------|---------|
| `|` | Pipe output to another command | `ls -l | grep ".txt"` |
| `>` | Redirect output to a file (overwrite) | `echo "text" > file.txt` |
| `>>` | Redirect output to a file (append) | `echo "more text" >> file.txt` |
| `<` | Use file as input | `sort < unsorted.txt` |
| `2>` | Redirect error output | `command 2> errors.log` |
| `&>` | Redirect all output | `command &> all.log` |

## Process Management

| Command | Description | Example |
|---------|-------------|---------|
| `ps` | List processes | `ps aux` |
| `top` | Monitor processes | `top` |
| `htop` | Interactive process viewer | `htop` |
| `kill` | Terminate process | `kill -9 1234` |
| `bg` | Run process in background | `command & bg` |
| `fg` | Bring to foreground | `fg %1` |
| `jobs` | List background jobs | `jobs` |
| `nohup` | Run immune to hangups | `nohup command &` |

## Scripting Basics

| Construct | Description | Example |
|-----------|-------------|---------|
| `#!/bin/bash` | Shebang line | First line of script |
| `$variable` | Variable reference | `echo $HOME` |
| `$1, $2, ...` | Script arguments | `script.sh arg1 arg2` |
| `$?` | Exit status of last command | `echo $?` |
| `if...fi` | Conditional statement | `if [ $a -eq $b ]; then ... fi` |
| `for...done` | Loop construct | `for i in {1..5}; do ... done` |
| `while...done` | While loop | `while [ $i -lt 10 ]; do ... done` |
| `function` | Define function | `function name() { commands; }` |

## System Information

| Command | Description | Example |
|---------|-------------|---------|
| `uname` | System information | `uname -a` |
| `df` | Disk space usage | `df -h` |
| `du` | Directory space usage | `du -sh *` |
| `free` | Memory usage | `free -h` |
| `ifconfig`/`ip` | Network configuration | `ip addr show` |
| `whoami` | Current user | `whoami` |
| `date` | Current date/time | `date +"%Y-%m-%d %H:%M:%S"` |

## Networking

| Command | Description | Example |
|---------|-------------|---------|
| `ping` | Test connectivity | `ping google.com` |
| `curl` | Transfer data | `curl -O https://example.com/file` |
| `wget` | Download files | `wget https://example.com/file` |
| `ssh` | Secure shell | `ssh user@hostname` |
| `scp` | Secure copy | `scp file.txt user@host:/path` |
| `netstat` | Network statistics | `netstat -tuln` |
| `nslookup`/`dig` | DNS lookup | `dig example.com` |

## Archive and Compression

| Command | Description | Example |
|---------|-------------|---------|
| `tar` | Archive files | `tar -czvf archive.tar.gz directory/` |
| `gzip` | Compress files | `gzip file.txt` |
| `gunzip` | Decompress gzip files | `gunzip file.txt.gz` |
| `zip` | Create zip archive | `zip -r archive.zip directory/` |
| `unzip` | Extract zip archive | `unzip archive.zip` |

## Package Management

### For Debian/Ubuntu
| Command | Description | Example |
|---------|-------------|---------|
| `apt update` | Update package lists | `sudo apt update` |
| `apt install` | Install package | `sudo apt install packagename` |
| `apt remove` | Remove package | `sudo apt remove packagename` |
| `apt search` | Search for packages | `apt search keyword` |

### For RedHat/CentOS/Fedora
| Command | Description | Example |
|---------|-------------|---------|
| `yum update` | Update package lists | `sudo yum update` |
| `yum install` | Install package | `sudo yum install packagename` |
| `yum remove` | Remove package | `sudo yum remove packagename` |
| `yum search` | Search for packages | `yum search keyword` |

## Special Shell Features

| Feature | Description | Example |
|---------|-------------|---------|
| `!!` | Repeat last command | `sudo !!` |
| `history` | Command history | `history | grep "apt"` |
| `alias` | Create command shortcut | `alias ll='ls -la'` |
| `ctrl+r` | Search command history | Press Ctrl+R, then type |
| `ctrl+c` | Interrupt running process | Press Ctrl+C |
| `ctrl+z` | Suspend process | Press Ctrl+Z |
| `tab` | Auto-complete | Type part of command, press Tab |
