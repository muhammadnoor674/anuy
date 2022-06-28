#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
CITY=$(curl -s ipinfo.io/city )
MYIP=$(wget -qO- ipinfo.io/ip);
echo "Checking VPS"
clear
source /var/lib/premium-script/ipvps.conf
if [[ "$IP" = "" ]]; then
clear
domain=$(cat /etc/v2ray/domain)
tls="$(cat ~/log-install.txt | grep -w "Vmess TLS" | cut -d: -f2|sed 's/ //g')"
nontls="$(cat ~/log-install.txt | grep -w "Vmess None TLS" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "Username : " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/v2ray/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo -e "Username ${RED}${CLIENT_NAME}${NC} Already On VPS Please Choose Another"
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (Days) : " masaaktif
hariini=`date -d "0 days" +"%Y-%m-%d"`
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#v2ray-vmess-tls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'"' /etc/v2ray/config.json
sed -i '/#v2ray-vmess-nontls$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'"' /etc/v2ray/config.json
cat>/etc/v2ray/vmess-$user-tls.json<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "${tls}",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/MDXCloud",
      "type": "none",
      "host": "",
      "tls": "tls"
}
EOF
cat>/etc/v2ray/vmess-$user-nontls.json<<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": ".mdxcloud.net",
      "port": "${nontls}",
      "id": "${uuid}",
      "aid": "0",
      "net": "ws",
      "path": "/MDXCloud",
      "type": "none",
      "host": "${domain}",
      "tls": "none"
}
EOF
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
v2ray1="vmess://$(base64 -w 0 /etc/v2ray/vmess-$user-tls.json)"
v2ray2="vmess://$(base64 -w 0 /etc/v2ray/vmess-$user-nontls.json)"
rm -rf /etc/v2ray/vmess-$user-tls.json
rm -rf /etc/v2ray/vmess-$user-nontls.json
systemctl restart v2ray.service
service cron restart
clear
echo -e ""
echo -e "==========VMESS========="
echo -e "Remarks     : ${user}"
echo -e "IP/Host     : ${MYIP}"
echo -e "Address     : ${domain}"
echo -e "Port TLS    : ${tls}"
echo -e "Port No TLS : ${nontls}"
echo -e "User ID     : ${uuid}"
echo -e "Alter ID    : 0"
echo -e "Security    : auto"
echo -e "Network     : ws"
echo -e "Path        : /MDXCloud"
echo -e "Created     : $hariini"
echo -e "Expired     : $exp"
echo -e "========================="
echo -e "Link TLS    : ${v2ray1}"
echo -e "========================="
echo -e "Link No TLS : ${v2ray2}"
echo -e "========================="
echo -e "==Script By Mardhex 2022=="
