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
sudo apt-get install unzip libssl-dev build-essential bind9 bind9utils
```

At this point we only have an older default Ubuntu version of BIND installed. 

```named -V``` shows us the config, dirs, et al:

```
$ named -V
BIND 9.8.1-P1 built with '--prefix=/usr' '--mandir=/usr/share/man' '--infodir=/usr/share/info' '--sysconfdir=/etc/bind' '--localstatedir=/var' '--enable-threads' '--enable-largefile' '--with-libtool' '--enable-shared' '--enable-static' '--with-openssl=/usr' '--with-gssapi=/usr' '--with-gnu-ld' '--with-geoip=/usr' '--enable-ipv6' 'CFLAGS=-fno-strict-aliasing -DDIG_SIGCHASE -O2' 'LDFLAGS=-Wl,-Bsymbolic-functions -Wl,-z,relro' 'CPPFLAGS=-D_FORTIFY_SOURCE=2'
using OpenSSL version: OpenSSL 1.0.1 14 Mar 2012
using libxml2 version: 2.7.8
```

Next we installed BIND 9.9.2-P1 and the RPZ2 patch:

```
wget ftp://ftp.isc.org/isc/bind9/9.9.2-P1/bind-9.9.2-P1.tar.gz

tar zxf bind-9.9.2-P1.tar.gz

cd bind-9.9.2-P1

wget http://ss.vix.su/~vjs/rpz2+rl-9.9.2-P1.patch

patch -s -p0 -i rpz2+rl-9.9.2-P1.patch

```

```
./configure '--prefix=/usr' '--mandir=/usr/share/man' '--infodir=/usr/share/info' '--sysconfdir=/etc/bind' '--localstatedir=/var' '--enable-threads' '--enable-largefile' '--with-libtool' '--enable-shared' '--enable-static' '--with-openssl=/usr' '--with-gnu-ld' '--with-geoip=/usr' '--enable-ipv6' 'CFLAGS=-fno-strict-aliasing -DDIG_SIGCHASE -O2 -g' 'LDFLAGS=-Wl,-Bsymbolic-functions -Wl,-z,relro' 'CPPFLAGS=-D_FORTIFY_SOURCE=2'
```

If the machine you are building on is low power, make can take a very long time:

```
make

sudo make install
```

Run named -V again to verify that the newer patched version is now active:

```
named -V

BIND 9.9.2-rpz2+rl.072.23-P1 built with '--prefix=/usr' '--mandir=/usr/share/man' '--infodir=/usr/share/info' '--sysconfdir=/etc/bind' '--localstatedir=/var' '--enable-threads' '--enable-largefile' '--with-libtool' '--enable-shared' '--enable-static' '--with-openssl=/usr' '--with-gnu-ld' '--with-geoip=/usr' '--enable-ipv6' 'CFLAGS=-fno-strict-aliasing -DDIG_SIGCHASE -O2 -g' 'LDFLAGS=-Wl,-Bsymbolic-functions -Wl,-z,relro' 'CPPFLAGS=-D_FORTIFY_SOURCE=2'
using OpenSSL version: OpenSSL 1.0.1 14 Mar 2012
```

The queryperf utility needs to be compiled:

```
cd contrib/queryperf
sh configure
make
cd ../..
```

In order to run the rpz tests, changes to /etc/network/interfaces are needed:

```
cd bin/tests/system
sudo ./ifconfig.sh up
```

Run the rpz tests:

```
~/bind-9.9.2-P1/bin/tests/system$ sh run.sh rpz

S:rpz:Fri Mar 22 15:46:50 UTC 2013
T:rpz:1:A
A:System test rpz
I:checking QNAME rewrites
I:checking IP rewrites
I:checking radix tree deletions
I:checking NSDNAME rewrites
I:checking NSIP rewrites
I:checking walled garden NSIP rewrites
I:checking policy overrides
I:checking crashes
I:checking performance with rpz
I:checking performance without rpz
I:1060 qps with rpz is 80% of 1321 qps without rpz
I:exit status: 0
R:PASS
E:rpz:Fri Mar 22 15:47:25 UTC 2013
```

The above "performance" was on a t1.micro, the smallest Amazon instance size. 

FIXME: what ports need to be open for IXFR and nsupdate

FIXME: initial conf files for bind

FIXME: logging configuration 
