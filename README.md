# havei.sh
Tool (CLI) for using [haveibeenpwned](https://haveibeenpwned.com/Passwords) through its API (only passwords for now)


# Install

- Download the script [havei.sh](https://raw.githubusercontent.com/MrBlaise/haveibeenpwned/master/havei.sh) 
- Run `chmod +x havei.sh`

# Usage

- Check a single password: `./havei.sh password`
- Check a password in interactive mode: `./havei.sh -i`
- Check multiple passwords from a newline seperated file: `./havei.sh -f=passwords.txt`
- By default there is a 2 second delay, to prevent rate limiting, you can set this with the `-d` or `--delay` flag
- To read more about the flags run `./havei.sh --help`
- To write out plain passwords and their statuses use the `-p` or `--plain` flag

### Examples
```
./havei.sh password
1E4C9B93F3F0682250B6CF8331B7EE68FD8:3303003

./havei.sh -f=passwords.txt
37D0679CA88DB6464EAC60DA96345513964:2088998
1E4C9B93F3F0682250B6CF8331B7EE68FD8:3303003

./havei.sh -f=passwords.txt -p
FOUND: 12345 -- 37D0679CA88DB6464EAC60DA96345513964:2088998 
FOUND: password -- 1E4C9B93F3F0682250B6CF8331B7EE68FD8:3303003
```
