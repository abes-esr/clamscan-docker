#!/bin/bash

mkdir -p ${FOLDER_TO_SCAN}


# copy not scanned files to tmp directory then scan it !
LAST_SCANNED_FILE=/tmp/clamscan-last-scanned-file
if [ ! -f ${LAST_SCANNED_FILE} ]; then
  touch --date "2000-01-01" ${LAST_SCANNED_FILE}
fi
rm -rf /tmp/new-files-to-scan/
mkdir -p /tmp/new-files-to-scan/
if [ "${SCAN_ONLY_NEW_FILES}" == "1" ]; then
  rsync -a \
    --files-from=<(find ${FOLDER_TO_SCAN} -newer ${LAST_SCANNED_FILE} -type f -exec basename {} \;) \
    ${FOLDER_TO_SCAN} \
    /tmp/new-files-to-scan
else
  rsync -a ${FOLDER_TO_SCAN} /tmp/new-files-to-scan
fi

if [ "$(ls /tmp/new-files-to-scan/)" == "" ]; then
  echo "-> Nothing new to scan in ${FOLDER_TO_SCAN}, skipping"
  exit 0
fi

echo "-> Scanning $(find /tmp/new-files-to-scan/ -type f | wc -l) (new) files from ${FOLDER_TO_SCAN} mounted docker volume"
clamscan $CLAMSCAN_OPTIONS /tmp/new-files-to-scan/ | tee /tmp/clamscan.log

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

# get the last modified file and copy it as a date flag for the next scan
cp -af \
  "$(find ${FOLDER_TO_SCAN} -type f -exec stat --format '%Y %n' "{}" \; | sort -nr | cut -d' ' -f2- | head -1)" \
  ${LAST_SCANNED_FILE}

