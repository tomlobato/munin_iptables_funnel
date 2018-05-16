#########
## DNS ##
#########

iptables -N DNS 2> /dev/null

iptables -A INPUT -p udp --dport 53 -i $IF0 -j DNS
iptables -A INPUT -p tcp --dport 53 -i $IF0 -j DNS
iptables -A DNS -m comment --comment 'DNS_ALL'

# WHERE?
ipset_lists country_br > /dev/null
iptables -A DNS -m set --match-set country_br src -m comment --comment 'DNS_BR'

# BL
ipset_lists bl > /dev/null
iptables -A DNS -m set --match-set bl src -j DROP -m comment --comment 'DNS_BL'

# RATE
iptables -A DNS -m state --state NEW -m recent --set
iptables -A DNS -m state --state NEW -m recent --update --seconds 20 --hitcount 6 -j DROP  -m comment --comment 'DNS_OVERRATE'

# ALLOW
iptables -A DNS -j ACCEPT  -m comment --comment 'DNS_ACCEPT'
