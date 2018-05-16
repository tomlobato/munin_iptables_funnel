![sample graph](https://github.com/tomlobato/munin_iptables_funnel/blob/master/sample.png)

# Install

As root, run:

```bash
wget https://raw.githubusercontent.com/tomlobato/munin_iptables_funnel/master/iptables_funnel
chmod 755 iptables_funnel
mv iptables_funnel /usr/local/sbin/
iptables_funnel install
```

Then add custom user chains to iptables. Example:

```bash
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

ipset_lists bl                  > /dev/null # https://github.com/tomlobato/ipset_lists
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

# BL
iptables -A DNS -m set --match-set bl src -j DNS_BL
iptables -A DNS_BL -j DROP

# RATE
iptables -A DNS -m state --state NEW -m recent --set
iptables -A DNS -m state --state NEW -m recent --update --seconds 20 --hitcount 6 -j DNS_OVERRATE
iptables -A DNS_OVERRATE -j DROP

# ALLOW
iptables -A DNS -j DNS_ACCEPT
iptables -A DNS_ACCEPT -j ACCEPT
```

Reload your firewall, then test:

```bash
munin-run iptables_funnel config
```

<sub><sup>
graph_category Firewall DNS  
graph_title Packets/s  
graph_vlabel packets/s  
graph_args --base 1000 -l 0  
</sup></sub>

<sub><sup>
dns_all.label dns_all  
dns_all.type DERIVE  
dns_all.min 0  
dns_global.label dns_global  
dns_global.type DERIVE  
dns_global.min 0  
dns_br.label dns_br  
dns_br.type DERIVE  
dns_br.min 0  
dns_bl.label dns_bl  
dns_bl.type DERIVE  
dns_bl.min 0  
dns_overrate.label dns_overrate  
dns_overrate.type DERIVE  
dns_overrate.min 0  
dns_accept.label dns_accept  
dns_accept.type DERIVE  
dns_accept.min 0  
</sup></sub>

```
munin-run iptables_funnel
```

<sub><sup>
dns_accept.value 128046  
dns_all.value 6232044  
dns_bl.value 5841360  
dns_br.value 8401  
dns_global.value 6232044  
dns_overrate.value 262638  
</sup></sub>

And Finally:

```bash
/etc/init.d/munin-node restart
```
