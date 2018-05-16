![sample graph](https://github.com/tomlobato/munin_iptables_funnel/blob/master/sample.png)

# Install

As root, run:
 
```bash
wget https://raw.githubusercontent.com/tomlobato/munin_iptables_stat/master/iptables_stat_
chmod 755 iptables_stat_
mv iptables_stat_ /usr/local/sbin/
```

# Configure

```
# sample: dns
iptables_stat_ install dns 'Firewall DNS' 'DNS_ALL DNS_BR DNS_BL DNS_OVERRATE DNS_ACCEPT'
```

Then add custom user chains to iptables. Example:

```bash
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
```

Reload your firewall, then test:

```bash
munin-run iptables_stat_dns config
```

> graph_category Firewall DNS  
> graph_title Packets/s  
> graph_vlabel packets/s  
> graph_args --base 1000 -l 0  
>  
> dns_all.label dns_all  
> dns_all.type DERIVE  
> dns_all.min 0  
> dns_br.label dns_br  
> dns_br.type DERIVE  
> dns_br.min 0  
> dns_bl.label dns_bl  
> dns_bl.type DERIVE  
> dns_bl.min 0  
> dns_overrate.label dns_overrate  
> dns_overrate.type DERIVE  
> dns_overrate.min 0  
> dns_accept.label dns_accept  
> dns_accept.type DERIVE  
> dns_accept.min 0  

```
munin-run iptables_stat_dns
```

> dns_accept.value 128046  
> dns_all.value 6232044  
> dns_bl.value 5841360  
> dns_br.value 8401  
> dns_overrate.value 262638  

And Finally:

```bash
/etc/init.d/munin-node restart
```
