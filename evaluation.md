# Born 2 be Root - Evaluation

## VM Signature

compare the signature.txt to the .vd file
```
diff signature.txt *.vdi
```

## Simple Setup

check if ufw & ssh services are started and which operation system is installed
```
systemctl status ufw
systemctl status ssh
head -n 2 /etc/os-release
```

## User

check if *user_name* belongs to *sudo* and *user42* groups
```
id user_name
```

password policies:
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

test password policies
```
sudo adduser user_name
```
- How to enforce these rules?
- Advantages of this policy?
- Advantages and disadvantages of its implementation?

create group *evaluating* and add *user_name* to it:
```
sudo groupadd evaluating
sudo usermod -aG evaluating user_name
getent groups
```

## Hostname and partitions

hostname should be login42:
```
hostnamectl
```

change hostname:
```
su -
hostnamectl set-hostname <hostname>
vim /etc/hosts
reboot
hostnamectl
```

view partitions
```
lsblk
```

## SUDO

assign user_name to sudo group
```
sudo usermod -aG sudo user_name
getent group sudo
```

## UFW

check UFW
```
sudo /usr/sbin/ufw status
```

open port 8080
```
sudo ufw allow port 8080
sudo ufw status
```

Delete rule
```
sudo ufw status numered
sudo ufw delete <number>
```

## SSH

check status and port config
```
sudo systemctl status ssh
sudo grep Port /etc/ssh/sshd_config
```

login user_name via ssh
```
ssh user_name@localhost -p 4242
```
