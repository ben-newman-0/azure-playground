apt-get update && apt-get upgrade -y
apt-get install -y bind9

cat > /etc/bind/named.conf.options << EOF
options {
  directory "/var/cache/bind";

  recursion yes;
  allow-query {
    10.0.0.0/8;
    172.16.0.0/12;
    192.168.0.0/16;
    127.0.0.1;
  };

  forwarders { 168.63.129.16; };
  forward only;
};
EOF

service bind9 restart
