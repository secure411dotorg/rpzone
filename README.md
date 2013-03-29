AWS AMI for easy experimenting with RPZ2
======

The purpose of this git repository is to encourage the use of Response Policy Zones feature of BIND by making it easy to start up your own instance on your own AWS account and immediately test and use RPZ2 with an already-working config.

Helper scripts to assist in maintaining white and block zones will be included in this repository.

For reasons of security, we detail how the instance was created in the file named Ubuntu-Walkthrough.md.

***
###First time config

Request the AMI to be shared with your AWS account by sending your AWS account number to (contact)

Start the instance up on your own AWS account which will use your own ssh key and security group.

ssh into the instance

Generate an rndc.key

FIXME explain how and why: Generate ddns keys

grep -l CONFIGME /etc/bind/*named* will list the files you need to edit

To restart BIND: ```/etc/init.d/bind9 restart``` 

***
###NOTES

BIND is very picky about syntax. Always check the log file after altering a config file, restarting BIND, or using rndc reconfig. rndc reconfig will not show an error message for syntax issues with a config file. The log will show the error. Look at running processes such as by using ```ps auxfwww1``` to see if named is in the process list.

***

FIXME: what ports need to be open for IXFR and nsupdate

FIXME: initial conf files for bind

FIXME: logging configuration 
