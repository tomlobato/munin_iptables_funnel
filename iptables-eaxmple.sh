#########
## DNS ##
#########

iptables -N DNS                 2> /dev/null
iptables -N DNS_ALL             2> /dev/null
iptables -N DNS_BL              2> /dev/null
iptables -N DNS_OVERRATE        2> /dev/null
iptables -N DNS_GLOBAL          2> /dev/null
iptables -N DNS_BR              2> /dev/null
iptables -N DNS_ACCEPT          2> /dev/null

ipset_lists bl                  > /dev/null
ipset_lists country_br          > /dev/null

iptables -A INPUT -p udp --dport 53 -i $IF0 -j DNS
iptables -A INPUT -p tcp --dport 53 -i $IF0 -j DNS

iptables -A DNS -j NFLOG
iptables -A DNS -j DNS_ALL
iptables -A DNS_ALL -j RETURN

# WHERE?
iptables -A DNS -j DNS_GLOBAL
iptables -A DNS_GLOBAL -j RETURN

iptables -A DNS -m set --match-set country_br src -j DNS_BR
iptables -A DNS_BR -j RETURN

# AWS
iptables -A DNS -m set --match-set aws src -j DNS_BL
iptables -A DNS_BL -j DROP

# RATE
iptables -A DNS -m state --state NEW -m recent --set
iptables -A DNS -m state --state NEW -m recent --update --seconds 20 --hitcount 6 -j DNS_OVERRATE
iptables -A DNS_OVERRATE -j DROP

# ALLOW
iptables -A DNS -j DNS_ACCEPT
iptables -A DNS_ACCEPT -j ACCEPT
