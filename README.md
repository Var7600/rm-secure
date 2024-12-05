# secure-rm 

   _________ ___        ________  _______  __________    _____/ /_ 
  / ___/ __ `__ \______/ ___/ _ \/ ___/ / / / ___/ _ \  / ___/ __ \
 / /  / / / / / /_____(__  )  __/ /__/ /_/ / /  /  __/ (__  ) / / /
/_/  /_/ /_/ /_/     /____/\___/\___/\__,_/_/   \___(_)____/_/ /_/ 

yet Another alternative for the `Evil /bin/rm` command in Linux that provides
options for backup, retention, and restoration of deleted file(s) or
directory/ies.

## Installation

1.Clone the Repository

```bash
git clone https://github.com/Var7600/rm-secure.git
cd rm-secure/
```

## Install Dependencies

2.Ensure you have the following installed:

- `shellcheck` for linting (optional for users but required for contributing)
- `Bats` for testing (optional for users but required for contributors)

For Debian/Ubuntu:
```bash
 sudo apt install shellcheck bats
```
For macOS (via Homebrew):
```bash
brew install shellcheck bats
```

3.Make the Script Executable
```bash
chmod +x rm-secure.sh
```

4.add script path to `.bashrc`
```bash
source path/to/file/rm-secure.sh
```

5.Add rm-secure.sh Path to `.bashrc`
```bash
export PATH="$PATH:path/to/file/"
```
- or rather than replacing built in `rm` you can use `rm-secure.sh`
```bash
sudo cp rm-secure.sh /usr/local/bin/rm-secure
```
Now, you can use rm-secure as a command instead of rm.

## Usages
```bash

rm_secure: A safer alternative to GNU rm
Usage: rm [OPTIONS] FILE...
Options:
  -d <days>      Set retention period in days (default: 60 days)
  -e, --empty    Empty the trash folder
  -l, --list     List files in the trash folder
  -s, --restore  Restore files or directory from trash
  -r/-R, --delete delete a directory 
  -v, --verbose  Verbose output
  --help         Show this help message
```

- delete file

```bash
 >$ rm test.cpp
renamed 'test.cpp' -> '/home/var7600-unix/rm_saved/2024_12_03_22h08m_test.cpp'
saved for 60 days
```

- list deleted file(s)

```bash
 >$ rm -l
total 0
-rw-r--r-- 1 var7600-unix var7600-unix 337 Dec  3 22:09 2024_12_03_22h08m_test.cpp
```

- restore file(s)

```bash
 >$ rm -s test.cpp
renamed '/home/var7600-unix/rm_saved/2024_12_03_22h08m_test.cpp' -> './2024_12_03_22h08m_test.cpp'
```

- empty trash definitively

```bash
 >$ rm -e
```

- deleting a directory use `-r` or `-R` option 

```bash
 >$ rm -r Scripts
deleting Scripts/ (Saved in ~/home/var7600/rm_saved/)
saved for 60
```

- restore directory

```bash
 >$ rm -s Scripts
```

## Notes
- Ensure that the `sauvegarde_rm` directory is accessible and writable (default is `~/rm-saved/`).
- This script overrides `rm` behavior and moves files to a temporary location instead of deleting them permanently.

## Contributions
all Contributions bug/reports/issues/pull request are welcome.
Clone the repository and set up dependencies.

    1.write your features or fix or ...

    2.Run ShellCheck to lint the script:
    ```bash
        shellcheck rm-secure.sh
    ```
    3. add yours tests and Run Bats to test
    ```
        bats tests/
    ```

## License
    MIT License.