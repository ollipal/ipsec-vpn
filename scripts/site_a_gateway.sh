#!/usr/bin/env bash

## Traffic going to the internet
route add default gw 172.16.16.1

## Configure IPsec VPN to gateway-a
cat >> /etc/ipsec.secrets << EOF
# source     destination
172.16.16.16 172.30.30.30 : PSK "LTG2h9OEa+NKlMag29uUluK/AyPJfBST2Ao0bN8F9WbpEYX0aUui44aJTl7QBCofb2RcD0r0KP3m0lVn2mF7lQ=="
EOF

sysctl -p /etc/sysctl.conf

cat >> /etc/ipsec.conf << EOF
# basic configuration
config setup
        charondebug="all"
        uniqueids=yes
        strictcrlpolicy=no

# connection to cloud-s
conn a-to-s
  authby=secret
  left=%defaultroute
  leftid=172.16.16.16
  leftsubnet=172.16.16.16/32
  right=172.30.30.30
  rightsubnet=172.30.30.30/32
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
#This is not working, would be nice to not need to configure the server_ip
#iptables -t nat -A OUTPUT -p tcp --dport 8080 -j DNAT --to-destination 10.2.1.1:8080
#iptables -t nat -A POSTROUTING -o enp0s8 -s 10.2.0.0/16 -d 10.1.0.0/16 -j MASQUERADE
# Internet connection before Gateway-S is up:
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

## Save the iptables rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

## Restart IPSec VPN
ipsec restart