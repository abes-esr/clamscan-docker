#!/bin/bash

mkdir -p ${FOLDER_TO_SCAN}

echo -n "-> [$(date '+%Y-%m-%d %H:%M:%S')] - Scanning $FOLDER_TO_SCAN"
clamscan --recursive=yes --allmatch=yes ${FOLDER_TO_SCAN} | tee /tmp/clamscan.log

grep "Infected files: 0" /tmp/clamscan.log >/dev/null
SOMETHING_IS_INFECTED=$?
if [ "$SOMETHING_IS_INFECTED" != "0" ]; then
  echo "-> Infected: send an alert email to ${ALERT_MAILTO}"
  echo "To: ${ALERT_MAILTO}
From: noreply@${SMTP_MAILDOMAIN}
Subject: ${ALERT_SUBJECT}

$(cat /tmp/clamscan.log)" \
  | msmtp ${ALERT_MAILTO}
fi
