#! /bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
STUBBYCFG="/etc/stubby/stubby.yml"
STUBBYPID=$(pgrep stubby)
PINCHG="0"

if  ! command -v dig &> /dev/null || ! command -v openssl &> /dev/null; then
echo -e "${RED}Sorry, either dig or openssl is missing - please install it first!${NC}"
exit 0
fi

if [ ! -f ${STUBBYCFG} ] || [ ! -w ${STUBBYCFG} ]; then
echo -e "${RED}Sorry, your stubby-config could not be found or is not writeable, please check!${NC}"
exit 0
fi

if [ "$(dig @8.8.8.8 +short +time=5 +tries=2 google.com. | grep -v [0-9.])" ]; then
echo -e "${RED}ERROR - exiting due to DNS-resolving problem!${NC}"
exit 0
fi

DNSSRV=$(cat ${STUBBYCFG} | grep -v "#" | grep address | awk '{print $3}' | grep -v ^$)

for IP in ${DNSSRV}; do
OLDVALUE=$(grep -A4 $IP ${STUBBYCFG} | grep value | awk '{print $2}')
NOWVALUE=$(echo | openssl s_client -connect ${IP}:853 2>/dev/null | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64)

if [ "$OLDVALUE" != "$NOWVALUE" ]; then
sed -i "s|$OLDVALUE|$NOWVALUE|g" $STUBBYCFG
echo -e "${GREEN}OK - Changed tls_pinset for DNS-Server: $IP${NC}"
PINCHG="1"
fi

done

if [ "$PINCHG" == "0" ]; then
exit 0
fi

echo -e "${GREEN}Restarting stubby, as some pinset changed${NC}"
/usr/sbin/service stubby restart
sleep 2
STUBBYNEWPID=$(pgrep stubby)

if [ "$STUBBYNEWPID" == "" ]; then
echo -e "${RED}Sorry, restart not successfull"
elif [ "$STUBBYNEWPID" != "$STUBBYPID" ]; then
echo -e "${GREEN}Restarting sucessful! - new PID $STUBBYNEWPID ${NC}"
elif [ "$STUBBYNEWPID" == "" ]; then
echo -e "${RED}Sorry, restart not successful - try manual restart!${NC}"
fi
