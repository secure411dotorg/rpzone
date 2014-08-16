***
How the AWS instance was created
---

AMI: ubuntu-trusty-14.04-amd64-server-20140607.1 (ami-864d84ee)

apt-get dependencies, wget bind and patch, compile

```
sudo apt-get update
sudo apt-get install unzip libssl-dev build-essential bind9 bind9utils
```

At this point we only have an older default Ubuntu version of BIND installed. 

```named -V``` shows us the config, dirs, et al:

```
$ named -V
BIND 9.9.5-3-Ubuntu (Extended Support Version) <id:f9b8a50e> built by make with '--prefix=/usr' '--mandir=/usr/share/man' '--infodir=/usr/share/info' '--sysconfdir=/etc/bind' '--localstatedir=/var' '--enable-threads' '--enable-largefile' '--with-libtool' '--enable-shared' '--enable-static' '--with-openssl=/usr' '--with-gssapi=/usr' '--with-gnu-ld' '--with-geoip=/usr' '--with-atf=no' '--enable-ipv6' '--enable-rrl' '--enable-filter-aaaa' 'CFLAGS=-fno-strict-aliasing -DDIG_SIGCHASE -O2'
compiled by GCC 4.8.2
using OpenSSL version: OpenSSL 1.0.1f 6 Jan 2014
using libxml2 version: 2.9.1
```

Ubuntu apt-get installed BIND 9.9.5-3 and now we need the RPZ patch for 9.9.5:

```
wget http://ftp.isc.org/isc/bind9/9.9.5/bind-9.9.5.tar.gz

tar zxf bind-9.9.5.tar.gz

cd bind-9.9.5

wget http://ss.vix.su/%7Evjs/rpz2+rl-9.9.5.patch

patch -s -p0 -i rpz2+rl-9.9.5.patch 

```

```
    Response Rate Limiting (--enable-rrl)
    GSS-API (--with-gssapi)
    PKCS#11/Cryptoki support (--with-pkcs11)
    New statistics (--enable-newstats)
    Allow 'fixed' rrset-order (--enable-fixed-rrset)
    Automated Testing Framework (--with-atf)
    XML statistics (--with-libxml2)
```


```
./configure '--prefix=/usr' '--mandir=/usr/share/man' '--infodir=/usr/share/info' '--sysconfdir=/etc/bind' '--localstatedir=/var' '--enable-threads' '--enable-largefile' '--with-libtool' '--enable-shared' '--enable-static' '--enable-rrl' '--with-pkcs11' '--enable-newstats' '--enable-fixed-rrset' '--with-atf'  '--with-openssl=/usr' '--with-gnu-ld' '--with-geoip=/usr' '--enable-ipv6' 'CFLAGS=-fno-strict-aliasing -DDIG_SIGCHASE -O2 -g' 'LDFLAGS=-Wl,-Bsymbolic-functions -Wl,-z,relro' 'CPPFLAGS=-D_FORTIFY_SOURCE=2'
```

If the machine you are building on is low power, make can take a very long time:

```
make

sudo make install
```

On an AWS ec2 t2.micro, for make:

```
real	4m59.081s
user	4m32.221s
sys	0m22.056s
```


Run named -V again to verify that the newer patched version is now active:

```
named -V

BIND 9.9.5-rpz2+rl.14038.05 (Extended Support Version) <id:f9b8a50e> built by make with '--prefix=/usr' '--mandir=/usr/share/man' '--infodir=/usr/share/info' '--sysconfdir=/etc/bind' '--localstatedir=/var' '--enable-threads' '--enable-largefile' '--with-libtool' '--enable-shared' '--enable-static' '--enable-rrl' '--with-gssapi' '--with-pkcs11' '--enable-newstats' '--enable-fixed-rrset' '--with-atf' '--with-libxml2' '--with-openssl=/usr' '--with-gnu-ld' '--with-geoip=/usr' '--enable-ipv6' 'CFLAGS=-fno-strict-aliasing -DDIG_SIGCHASE -O2 -g' 'LDFLAGS=-Wl,-Bsymbolic-functions -Wl,-z,relro' 'CPPFLAGS=-D_FORTIFY_SOURCE=2'
compiled by GCC 4.8.2
using OpenSSL version: OpenSSL 1.0.1f 6 Jan 2014
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

###DEVIATIONS FROM DEFAULT INSTALL:

Each line of named.conf.options has been commented out because no views were required for this install and the options{} clause is located in the named.conf.local file.

```sudo vi /etc/apparmor.d/usr.sbin.named```

Add these lines:

```
  # RPZones
  /opt/rpz-deliverables/** rw,
  /opt/rpz-deliverables/ rw,
```

```sudo /etc/init.d/apparmor reload``

```sudo mkdir /var/log/named```
