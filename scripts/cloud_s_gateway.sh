#!/usr/bin/env bash

## Traffic going to the internet
route add default gw 172.30.30.1

## Configure IPsec VPN to gateway-s
cat >> /etc/ipsec.secrets << EOF
# source     destination
172.30.30.30 172.16.16.16 : PSK "LTG2h9OEa+NKlMag29uUluK/AyPJfBST2Ao0bN8F9WbpEYX0aUui44aJTl7QBCofb2RcD0r0KP3m0lVn2mF7lQ=="
172.30.30.30 172.18.18.18 : PSK "LTG2h9OEa+NKlMag29uUluK/AyPJfBST2Ao0bN8F9WbpEYX0aUui44aJTl7QBCofb2RcD0r0KP3m0lVn2mF7lQ=="
EOF

sysctl -p /etc/sysctl.conf

cat >> /etc/ipsec.conf << EOF
# basic configuration
config setup
        charondebug="all"
        uniqueids=yes
        strictcrlpolicy=no

# connection to cloud-a
conn s-to-a
  authby=secret
  left=%defaultroute
  leftid=172.30.30.30
  leftsubnet=172.30.30.30/32
  right=172.16.16.16
  rightsubnet=172.16.16.16/32
  ike=aes256-sha2_256-modp1024!
  esp=aes256-sha2_256!
  keyingtries=0
  ikelifetime=1h
  lifetime=8h
  dpddelay=30
  dpdtimeout=120
  dpdaction=restart
  auto=start

# connection to cloud-b
conn s-to-b
  authby=secret
  left=%defaultroute
  leftid=172.30.30.30
  leftsubnet=172.30.30.30/32
  right=172.18.18.18
  rightsubnet=172.18.18.18/32
  ike=aes256-sha2_256-modp1024!
  esp=aes256-sha2_256!
  keyingtries=0
  ikelifetime=1h
  lifetime=8h
  dpddelay=30
  dpdtimeout=120
  dpdaction=restart
  auto=start
EOF

## NAT
# A
#iptables -t nat -A POSTROUTING -o enp0s8 -s 10.1.0.0/16 -d 10.2.0.0/16 -j MASQUERADE
# B
#iptables -t nat -A POSTROUTING -o enp0s8 -s 10.3.0.0/16 -d 10.2.0.0/16 -j MASQUERADE
# other than tunnel internet conneciton:

# TÄHÄN SE RANDOM OSOTE, esim:
# iptables -t nat -A PREROUTING -s 172.16.16.16 -d 47.47.47.4 -j DNAT --to-destination 10.2.1.1

iptables -t nat -A PREROUTING -s 172.16.16.16 -j DNAT --to-destination 10.2.1.1
iptables -t nat -A PREROUTING -s 172.18.18.18 -j DNAT --to-destination 10.2.1.2
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Restart IPSec VPN
ipsec restart