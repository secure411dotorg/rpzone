AWS AMI for easy experimenting with RPZ2
======

The purpose of this git repository is to encourage the use of Response Policy Zones feature of BIND by making it easy to start up your own instance on your own AWS account and immediately test and use RPZ2 with an already-working config.

Helper scripts to assist in maintaining white and block zones will be included in this repository.

The following steps have already been completed on the instance, which requires no extra configuration. For reasons of security, in the following section we detail how the instance was created.

***
How the AWS instance was created
---

AMI: ubuntu/images/ebs/ubuntu-precise-12.04-i386-server-20130124 (ami-3bec7952)

apt-get dependencies, wget bind and patch, compile

```
sudo apt-get update
sudo apt-get install unzip libssl-dev build-essential

wget ftp://ftp.isc.org/isc/bind9/9.9.2-P1/bind-9.9.2-P1.tar.gz

tar zxf bind-9.9.2-P1.tar.gz

wget http://ss.vix.su/~vjs/rpz2+rl-9.9.2-P1.patch

cd bind-9.9.2-P1/

patch -s -p0 -i rpz2+rl-9.9.2-P1.patch

cd into the resulting dir

sudo ./configure

sudo make

sudo make install
```

I could not find a guide to creating the user for bind, so I did adduser bind, blank password and rm /home/bind, edited /etc/passwd to be similar to my working older RPZ instance:

FIXME: user creation, chroot dirs set up
/etc/passwd has a line like this:

```
bind:x:1001:1001::/var/cache/bind:/bin/false
```

The following I adapted from an older chroot walk through for bind on ubuntu, and this has been done on the instance:

```
mkdir -p /var/lib/named/etc/bind
mkdir /var/lib/named/dev
mkdir -p /var/lib/named/var/cache/bind
mkdir -p /var/lib/named/var/run/bind/run

ln -s /var/lib/named/etc/bind /etc/bind

mknod /var/lib/named/dev/null c 1 3
mknod /var/lib/named/dev/random c 1 8
chmod 666 /var/lib/named/dev/null /var/lib/named/dev/random
chown -R bind:bind /var/lib/named/var/*
chown -R bind:bind /var/lib/named/etc/bind
```

FIXME: initial conf files for bind (I could copy from my existing RPZ master but want to be sure I use clean and correct initial conf files)

FIXME: start and stop control (I have this working on my existing RPZ master with a modified /etc/init.d/bind9)

FIXME: logging configuration (I have logging working fine on my existing RPZ master - might need need some tips later if I have trouble getting it working on this new one)
