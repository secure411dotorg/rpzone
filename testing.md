/opt/rpzone/scripts/nsupdate_zone.sh add example2.com alexa5000
Outgoing update query:
;; ->>HEADER<<- opcode: UPDATE, status: NOERROR, id:      0
;; flags:; ZONE: 0, PREREQ: 0, UPDATE: 0, ADDITIONAL: 0
;; ZONE SECTION:
;alexa5000.			IN	SOA

;; UPDATE SECTION:
example2.com.alexa5000.	60	IN	A	127.0.0.2

Answer:
;; ->>HEADER<<- opcode: UPDATE, status: NOERROR, id:  34413
;; flags: qr ra; ZONE: 1, PREREQ: 0, UPDATE: 0, ADDITIONAL: 1
;; ZONE SECTION:
;alexa5000.			IN	SOA

;; TSIG PSEUDOSECTION:
local-ddns.		0	ANY	TSIG	hmac-sha256. 1364843113 300 32 vX4w9LSFjOLNNRj6nYvxpK3U4iLAotIQRWpcA4Eoi2c= 34413 NOERROR 0 

ubuntu@ip-10-122-247-156:/opt/rpzone/scripts$ dig @localhost example2.com.alexa5000 A

; <<>> DiG 9.9.2-rpz2+rl.072.23-P1 <<>> @localhost example2.com.alexa5000 A
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50384
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;example2.com.alexa5000.		IN	A

;; ANSWER SECTION:
example2.com.alexa5000.	60	IN	A	127.0.0.2

;; AUTHORITY SECTION:
alexa5000.		120	IN	NS	ns.alexa5000.

;; ADDITIONAL SECTION:
ns.alexa5000.		120	IN	A	127.0.0.1

;; Query time: 2 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Mon Apr  1 19:05:22 2013
;; MSG SIZE  rcvd: 100

ubuntu@ip-10-122-247-156:/opt/rpzone/scripts$ /opt/rpzone/scripts/nsupdate_zone.sh delete example2.com alexa5000
Outgoing update query:
;; ->>HEADER<<- opcode: UPDATE, status: NOERROR, id:      0
;; flags:; ZONE: 0, PREREQ: 0, UPDATE: 0, ADDITIONAL: 0
;; ZONE SECTION:
;alexa5000.			IN	SOA

;; UPDATE SECTION:
example2.com.alexa5000.	0	NONE	A	127.0.0.2

Answer:
;; ->>HEADER<<- opcode: UPDATE, status: NOERROR, id:  25518
;; flags: qr ra; ZONE: 1, PREREQ: 0, UPDATE: 0, ADDITIONAL: 1
;; ZONE SECTION:
;alexa5000.			IN	SOA

;; TSIG PSEUDOSECTION:
local-ddns.		0	ANY	TSIG	hmac-sha256. 1364843133 300 32 UdE9xBz7Kh7qOZYK/u6YW32pb5l20yg6QOhBRlhG8MI= 25518 NOERROR 0 

ubuntu@ip-10-122-247-156:/opt/rpzone/scripts$ dig @localhost example2.com.alexa5000 A

; <<>> DiG 9.9.2-rpz2+rl.072.23-P1 <<>> @localhost example2.com.alexa5000 A
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 61212
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;example2.com.alexa5000.		IN	A

;; AUTHORITY SECTION:
alexa5000.		60	IN	SOA	. hostmaster.ns.alexa5000. 1364586292 3600 1200 604800 60

;; Query time: 2 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Mon Apr  1 19:05:37 2013
;; MSG SIZE  rcvd: 100
