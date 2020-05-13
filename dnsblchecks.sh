#!/bin/bash
#part of the code comes from https://www.saotn.org/bash-check-ip-address-blacklist-status/
#checks ipv6 and ipv4 against dnsbls in BLISTS

domains=(mxext1.hxix.de mxext2.hxix.de)
BLISTS=(
all.s5h.net	
b.barracudacentral.org	
bl.spamcop.net
blacklist.woody.ch	
bogons.cymru.com	
cbl.abuseat.org
combined.abuse.ch	
db.wpbl.info	
dnsbl-1.uceprotect.net
dnsbl-2.uceprotect.net	
dnsbl-3.uceprotect.net	
dnsbl.anticaptcha.net
dnsbl.dronebl.org	
dnsbl.inps.de	
dnsbl.sorbs.net
dnsbl.spfbl.net	
drone.abuse.ch	
duinv.aupads.org
dul.dnsbl.sorbs.net	
dyna.spamrats.com
dynip.rothen.com
http.dnsbl.sorbs.net	
ips.backscatterer.org	
ix.dnsbl.manitu.net
korea.services.net	
misc.dnsbl.sorbs.net	
noptr.spamrats.com
orvedb.aupads.org	
pbl.spamhaus.org	
proxy.bl.gweep.ca
psbl.surriel.com	
relays.bl.gweep.ca	
relays.nether.net
sbl.spamhaus.org	
singular.ttk.pte.hu	
smtp.dnsbl.sorbs.net
socks.dnsbl.sorbs.net	
spam.abuse.ch	
spam.dnsbl.anonmails.de
spam.dnsbl.sorbs.net	
spam.spamrats.com	
spambot.bls.digibase.ca
spamrbl.imp.ch	
spamsources.fabel.dk	
ubl.lashback.com
ubl.unsubscore.com	
virus.rbl.jp	
web.dnsbl.sorbs.net
wormrbl.imp.ch	
xbl.spamhaus.org	
z.mailspike.net
zen.spamhaus.org	
zombie.dnsbl.sorbs.net
)

for domain in "${domains[@]}" ; do
	#echo $domain
	ip=$(dig +short $domain)
	ipv6=$(sipcalc $(dig +short AAAA $domain) | grep Expanded | cut -d "-" -f2 | cut -d " " -f2)

len=${#ipv6}
for((i=$len-1;i>=0;i--)); do 
          
	revipv6="$revipv6${ipv6:$i:1}.";
done
revipv6=$(echo $revipv6 | sed -e 's|:.||g')


echo $domain goes as $ip and $ipv6 
reverse=$(echo $ip |
sed -ne "s~^\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)$~\4.\3.\2.\1~p")

# -- cycle through all the blacklists
for BL in "${BLISTS[@]}" ; do
    # print the UTC date (without linefeed)
    # show the reversed IP and append the name of the blacklist
    if [ "${reverse}" != "" ] ; then
      LISTED="$(dig +short -t a ${reverse}.${BL}.)"
      if [ "${LISTED}" != "" ] ; then
	      echo "$(date "+%Y-%m-%d_%H:%M:%S") $domain listed in $BL"
	      dig +short -t txt ${reverse}.${BL}.
	 fi
   fi

   if [ "${revipv6}" != "" ] ; then
#	 echo ipv6cmd: dig +short -t a ${revipv6}${BL}.
	      LISTED="$(dig +short -t a ${revipv6}${BL}.)"

      if [ "${LISTED}" != "" ] ; then
	      echo "$(date "+%Y-%m-%d_%H:%M:%S") $domain (ipv6) listed in $BL"
              dig +short -t txt ${revipv6}${BL}.
         fi
  fi
done

done
