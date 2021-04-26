#!/bin/bash

mkdir -p ${FOLDER_TO_SCAN}

echo "-> [$(date '+%Y-%m-%d %H:%M:%S')] - Scanning $FOLDER_TO_SCAN"
clamscan --recursive=yes --allmatch=yes ${FOLDER_TO_SCAN} | tee /tmp/clamscan.log

grep "Infected files: 0" /tmp/clamscan.log >/dev/null
SOMETHING_IS_INFECTED=$?
if [ "$SOMETHING_IS_INFECTED" != "0" ]; then
  if [ "$SMTP_HOST" != "" ]; then
  echo "-> Infected: send an alert email to ${ALERT_MAILTO}"
  echo "To: ${ALERT_MAILTO}
From: noreply@${SMTP_MAILDOMAIN}
Subject: ${ALERT_SUBJECT}

$(cat /tmp/clamscan.log)" \
  | msmtp ${ALERT_MAILTO}
  else
    echo "-> Infected: but do not send any alert email because SMTP_HOST is empty"    
  fi
fi
