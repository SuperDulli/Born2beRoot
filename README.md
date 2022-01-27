
# Born 2 be root

## installation

1. choose guided partitioning
2. separate locations
3. deselect ssh and standard software install

## install sudo

login as root
```
su-
```

```
apt install sudo
usermod -aG sudo chelmerd
```

check if user in sudo group
```
getent group sudo
```

give privilege as a super user (su)
```
sudo visudo
```
add this line
```
chelmerd	ALL=(ALL) ALL
```
```
Defaults	env_reset
Defaults	mail_badpass
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults	passwd_tries=3
Defaults	badpass_message="You entered the wrong password! Please try again."
Defaults	log_input, log_output, logfile="/var/log/sudo/sudo.log"
Defaults	requiretty
```


## install software

- git
- wget
- vim

## install and configure ssh

```
sudo apt install openssh-server
```

Check the SSH server status
```
sudo systemctl status ssh
```
Restart the SSH service
```
service ssh restart
```
Changing default port (22) to 4242
```
sudo nano /etc/ssh/sshd_config
```
change the line #Port22 to Port 4242
```
Port 4242
```
forbid to connect as root over ssh
```
PermitRootLogin no
```
Check if settings are right
```
sudo grep Port /etc/ssh/sshd_config
sudo grep RootLogin /etc/ssh/sshd_config
```
Restart the SSH service
```
sudo service ssh restart
```

`ssh` is the client that lets you connect to to a server, `sshd`is the daemon that listen for incoming connections

## Install and configure UFW (Uncomplicated Firewall)

```
apt-get install ufw
sudo ufw enable
sudo ufw status numered
sudo ufw allow 4242
```

Delete rule
```
sudo ufw status numered
sudo ufw delete <number>
```

## Connect SSH

Add forward rule for VirtualBox
1. Go to VirtualBox-> Choose the VM->Select Settings
2. Choose Network-> Adapter 1-> Advanced -> Port Forwarding
3. Protocol=TCP Host Port=4242 Guest Port=4242
4. restart SSH server (on the VM)
```
sudo systemctl restart ssh
sudo service sshd status
```
5. connect host to VM
```
ssh chelmerd@127.0.0.1 -p 4242
```

## password policies

- Your password has to expire every 30 days.
- The minimum number of days allowed before the modification of a password will
be set to 2.
- The user has to receive a warning message 7 days before their password expires.
- Your password must be at least 10 characters long. It must contain an uppercase
letter and a number. Also, it must not contain more than 3 consecutive identical
characters.
- The password must not include the name of the user.
- The following rule does not apply to the root password: The password must have
at least 7 characters that are not part of the former password.
- Of course, your root password has to comply with this policy.

```
sudo apt-get install libpam-pwquality
sudo vim /etc/security/pwquality.conf
```

uncomment and change lines
```
minlen = 10
lcredit = -1
ucredit = -1
dcredit = -1
maxrepeat = 3
usercheck = 1
difok=7
enforce_for_root
```
found at: https://www.server-world.info/en/note?os=Debian_10&p=password

password expiration
```
sudo vim /etc/login.defs
PASS_MAX_DAYS 30
PASS_MIN_DAYS 2
PASS_WARN_AGE 7
````

this only affects new user created

change for existing users (chelmerd and root)
```
sudo chage -M 30 chelmerd
sudo chage -m 2 chelmerd
sudo chage -W 7 chelmerd
sudo chage -l chelmerd
```

## user groups

create groups
```
sudo groupadd user42
sudo groupadd evaluating
```

add user to group
```
sudo usermod -aG <group> <username>
getent group <groupname>
```

## monitoring script

install netstat tools
```
sudo apt-get install -y net-tools
```

schedule script with cron (remember to make it executable with `chmod +x`)
```
crontab -e
```

add line to execute script every 10 minutes
```
*/10 *  * * * /usr/local/bin/moitoring
```

this line waits 10 Minutes (600 seconds) after the server started and run the script ONCE
```
@reboot sleep 600; /usr/local/bin/monitoring.sh
```
disable/stopping it by commenting it out

### CPU Cores

```
grep 'cpu cores' /proc/cpuinfo` | cut -d ':' -f 2
```
cuts at the delimiter ':' and only outputs whats in field 2 (i.e. the part after the delimiter)

```
nproc
```

```
grep 'processor' /proc/cpuinfo | wc -l
```
counts the lines with the virtual processor ids

### Memory Usage

```
free -m | grep 'Mem' | awk '{ printf "%s/%sMB (%.2f%%)", $3,$2,($3/$2)*100 }'
```
`free` displays the RAM usage in Megabytes,
awk takes care of the format (taking the 3rd word in the output as the first thing to print)

### Disk Usage

```
df -h | awk '$NF=="/"{ printf "%.2f/%.2fGB (%s)",$3,$2,$5 }'
```
display free disk space in human-readable output than look for the root ("/") at the last position of the line (that's what $NF is for) and rearrange


### CPU Load

```
uptime | awk '{ printf "%.1f%%",$(NF-2)*100 }'
```
`uptime` contains info about the (CPU) load averages for 1, 5 and 15 minutes (equal to the first line of `top`). Take the second to last value from it and display it as a percentage

test with:
```
sudo apt-get install stress
stress --cpu 4
```

### Last boot

```
who --boot | awk '{ printf "%s %s",$(NF-1),$NF }'
```

### LVM use

<!-- ```
lvm pvdisplay | grep -- '--- Physical volume ---' | awk '{ if ($1) { print "yes";exit; } else { print "no" } }'
````
`lvm pvdisplay` shows all drives that are setup with LVM with the heading "--- Physical volumes---". The -- (double dash) is used to separate options from the pattern -->

```
lsblk | grep lvm | awk '{ if ($1) { print "yes";exit; } else { print "no" } }'
```
look for a partition annotated with lvm
```
cat /proc/misc
```
should list *device-mapper* (but not sure if this is enough)

### Active Connections

```
netstat --numeric --all --tcp | grep ESTABLISHED | wc -l
```
counts the number of active TCP connections. Established connection means there is a connection, Listen means it is waiting for a partner to connect to.

### Number of users

```
users | wc -w
```
counts the words (i.e. users) active on the server

### IPv4-Adress & MAC

```
hostname --all-ip-address
ip address | grep link/ether | awk '{ print $2 }
```

### Numbers of commands executed with the `sudo` program

```
grep -c COMMAND /var/log/auth.log
```
the file records logins and as `sudo` has to login as the super user each invocation of `sudo` will be logged there
Problem: sometimes the count get reset (probably the auth.log resets)

```
grep -c COMMAND /var/log/sudo/sudo.log
```

### Submission

MacOS:
```
shasum /goinfre/chelmerd/<name>/*.vdi > signature.txt
```
remove name at the end