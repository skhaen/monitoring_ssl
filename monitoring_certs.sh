#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
WARNING=""
CRITICAL=""

PATHCERT="/etc/ssl/private"
PATHCERT_LE="/etc/letsencrypt/live"

### CERTS IN /etc/ssl/private
if [ -d "$PATHCERT" ]; then

    for CERT in $(find "$PATHCERT" -iname "*.crt$");
    do
	CERT_END_DATE=$(openssl x509 -in "$PATHCERT/$CERT" -noout -enddate | sed -e "s/.*=//")
 
	DATE_TODAY=$(date +'%s')
	DATE_CERT=$(date -ud "$CERT_END_DATE" +'%s')
	
	DATE_JOURS_DIFF=$(( ( $DATE_CERT - $DATE_TODAY ) / (60*60*24) ))

	#CRITICAL - 7 jours
    if [[ $DATE_JOURS_DIFF -le 7 ]]; then
	CRITICAL="$CRITICAL Cert SSL $CERT a renouveler avant $DATE_JOURS_DIFF jour(s)"
    fi

	# WARNING - entre 15 et 7 jours
    if [[ $DATE_JOURS_DIFF -gt 7 &&  $DATE_JOURS_DIFF -le 15 ]]; then
	WARNING="$WARNING Cert SSL $CERT a renouveler avant $DATE_JOURS_DIFF jour(s)"
    fi

	done
fi

### CERTS IN /etc/letsencrypt/live
if [ -d "$PATHCERT_LE" ]; then

    for CERT in $(find "$PATHCERT_LE" -iname cert.pem);
    do
	    CERT_END_DATE=$(openssl x509 -in "$CERT" -noout -enddate | sed -e "s/.*=//")
 
	    DATE_TODAY=$(date +'%s')
	    DATE_CERT=$(date -ud "$CERT_END_DATE" +'%s')
	
	    DATE_JOURS_DIFF=$(( ( $DATE_CERT - $DATE_TODAY ) / (60*60*24) ))

		#CRITICAL - 7 jours
		if [[ $DATE_JOURS_DIFF -le 7 ]]; then
			CRITICAL="$CRITICAL Cert SSL $CERT a renouveler avant $DATE_JOURS_DIFF jour(s)"
		fi
		
		# WARNING - entre 15 et 7 jours
		if [[ $DATE_JOURS_DIFF -gt 7 &&  $DATE_JOURS_DIFF -le 15 ]]; then
			WARNING="$WARNING Cert SSL $CERT a renouveler avant $DATE_JOURS_DIFF jour(s)"
		fi

    done
fi


if [[ -n $CRITICAL ]];then
    echo "$CRITICAL"
    exit "$STATE_CRITICAL"
fi

if [[ -n $WARNING ]];then
    echo "$WARNING"
    exit "$STATE_WARNING" 
fi

echo "certificats à jour"
exit "$STATE_OK"
