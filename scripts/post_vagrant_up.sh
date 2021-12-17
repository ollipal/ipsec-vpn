#!/usr/bin/env bash

# Remove temporary direct Internet access, that is required
# during "vagrant up" before Gateway-S has been started
echo "Fixing Gateway-A NAT"
vagrant ssh gateway-a -c "sudo iptables -t nat -D POSTROUTING -o enp0s8 -j MASQUERADE"
echo "Fixing Gateway-B NAT"
vagrant ssh gateway-b -c "sudo iptables -t nat -D POSTROUTING -o enp0s8 -j MASQUERADE"

# Re-configure client-a1 server-ip to 10.2.1.1
echo "Configuring Client-A1"
vagrant ssh client-a1 -c "rm /home/vagrant/client_app/config.json"
vagrant ssh client-a1 -c 'cat >> /home/vagrant/client_app/config.json << EOF
{
  "server_ip": "10.2.1.1",
  "server_port": "8080",
  "log_file": "/var/log/client.log"
}
EOF'

# Re-configure client-a2 server-ip to 10.2.1.1
echo "Configuring Client-A2"
vagrant ssh client-a2 -c "rm /home/vagrant/client_app/config.json"
vagrant ssh client-a2 -c 'cat >> /home/vagrant/client_app/config.json << EOF
{
  "server_ip": "10.2.1.1",
  "server_port": "8080",
  "log_file": "/var/log/client.log"
}
EOF'

# Re-configure client-b1 server-ip to 10.2.1.2
echo "Configuring Client-B1"
vagrant ssh client-b1 -c "rm /home/vagrant/client_app/config.json"
vagrant ssh client-b1 -c 'cat >> /home/vagrant/client_app/config.json << EOF
{
  "server_ip": "10.2.1.2",
  "server_port": "8080",
  "log_file": "/var/log/client.log"
}
EOF'

# Re-configure client-b2 server-ip to 10.2.1.2
echo "Configuring Client-B2"
vagrant ssh client-b2 -c "rm /home/vagrant/client_app/config.json"
vagrant ssh client-b2 -c 'cat >> /home/vagrant/client_app/config.json << EOF
{
  "server_ip": "10.2.1.2",
  "server_port": "8080",
  "log_file": "/var/log/client.log"
}
EOF'