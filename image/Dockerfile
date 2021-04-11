FROM ubuntu

# clamav: for the virus scanner
# cron: for running periodicaly scanning
# msmtp and ca-certificates: for sending alert emails
# gettext-base: for having envsubst command
RUN apt update && apt install -y cron clamav msmtp ca-certificates gettext-base

# update virus database a first time
RUN freshclam

# script for running clamav scanning
COPY do-clamscan.sh /scripts/do-clamscan.sh

# template for crontabs
COPY tasks.tmpl /etc/cron.d/tasks.tmpl

# template for sending alter mail with msmtp
COPY msmtprc.notls.tmpl /etc/msmtprc.notls.tmpl
COPY msmtprc.tls.tmpl /etc/msmtprc.tls.tmpl

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]