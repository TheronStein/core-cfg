### 1. `ls` Command

The `ls` command with the `-lh` options provides a human-readable format for file sizes.

`ls -lh`

- `-l`: Use a long listing format.
- `-h`: Print sizes in human-readable format (e.g., 1K, 234M, 2G).

#### Example: Using `ls -lh`

```bash
$ ls -lh 
total 12K
-rw-r--r-- 1 user group  512 Dec  1 12:34 file1.txt
-rw-r--r-- 1 user group 1.0K Dec  1 12:34 file2.txt
drwxr-xr-x 2 user group 4.0K Dec  1 12:34 subdir
```

### 2. `du` Command

The `du` (disk usage) command is used to estimate file space usage.

- To display the sizes of all files and directories recursively:

    `du -ah`
    
    - `-a`: Write counts for all files, not just directories.
    - `-h`: Print sizes in human-readable format (e.g., 1K, 234M, 2G).

#### Example: Using `du -ah`

```bash
$ du -ah 
4.0K   ./subdir 
512	   ./file1.txt 
1.0K   ./file2.txt 
5.5K   .
```


- To display the sizes of all files and directories within the current directory, without recursion:
  
    `du -sh *`
    
    - `-s`: Display only the total for each argument.
    - `*`: Wildcard to include all contents within the directory.

#### Example: Using `du -sh *`

```bash
$ du -sh * 
512	file1.txt 
1.0K	file2.txt 
4.0K	subdir
```


### 3. `find` Command

The `find` command can be used to list files with their sizes.

`find . -type f -exec du -h {} +`

- `.`: Start the search in the current directory.
- `-type f`: Only find files.
- `-exec du -h {} +`: Execute the `du -h` command on each found file.

### Examples and Detailed Usage






#### Example: Using `find . -type f -exec du -h {} +`

```bash
$ find . -type f -exec du -h {} + 
512	    ./file1.txt 
1.0K	./file2.txt`
```