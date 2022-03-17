FROM ubuntu:20.04

# clamav: for the virus scanner
# cron: for running periodicaly scanning
# msmtp and ca-certificates: for sending alert emails
# gettext-base: for having envsubst command
# rsync: for SCAN_ONLY_NEW_FILES feature
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y cron clamav msmtp ca-certificates gettext-base rsync

# update virus database a first time
VOLUME /var/lib/clamav/
RUN freshclam -F

# script for running clamav scanning
COPY do-clamscan.sh /scripts/do-clamscan.sh

# template for crontabs
COPY tasks.tmpl /etc/cron.d/tasks.tmpl

# template for sending alter mail with msmtp
COPY msmtprc.notls.tmpl /etc/msmtprc.notls.tmpl
COPY msmtprc.tls.tmpl /etc/msmtprc.tls.tmpl

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cron", "-f"]


