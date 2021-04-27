# clamscan-docker

[![Docker Pulls](https://img.shields.io/docker/pulls/abesesr/clamscan-docker.svg)](https://hub.docker.com/r/abesesr/clamscan-docker/)
[![Build Status](https://travis-ci.com/abes-esr/clamscan-docker.svg?branch=main)](https://travis-ci.com/abes-esr/clamscan-docker)

Dockerization of [ClamAV](https://www.clamav.net/) and specifically `clamscan` command used to scan periodicaly a specific folder for detecting trojans, viruses, malware & other malicious threats. If something bad is detected, an email is sent.

![](https://docs.google.com/drawings/d/e/2PACX-1vQEDK9TB6PJMLF1HA_Js9b36rVfaByUg8Z-9MWk0atfRWWl4DBop_wq8_phRzM82_y6R39iMoreE0vD/pub?w=200)

## Parameters

- `SCAN_AT_STARTUP`: if 1, then start with a scan when the container is created (default is `1`)
- `FOLDER_TO_SCAN`: this is the folder to scan with clamscan (default is `/folder-to-scan/`)
- `CRON_CLAMSCAN`: crontab parameters to run the clamscan command which is used to scan the `FOLDER_TO_SCAN` (default is `*/5 * * * *` - it means each 5 minutes)
- `CRON_FRESHCLAM`: crontab parameters to run the freshclam command which is used to update virus databases (default is `0 * * * * *` - it means each hours)
- `ALERT_MAILTO`: email address to send the alerts to (empty value as default so nothing is sent as)
- `ALERT_SUBJECT`: email subject for sending alerts to (`Alert from clamscan !` is the default value)
- `SMTP_TLS`: to enable TLS, set the value to `on` (default is `off`)
- `SMTP_HOST`: host or ip of the smtp server used to send the alerts (default is `127.0.0.1`)
- `SMTP_PORT`: port of the smtp server used to send the alerts (default is` 25`)
- `SMTP_USER`: smtp server login (empty value as default)
- `SMTP_PASSWORD`: smtp server password (empty value as default)

## Usage

Here is a basic usecase.
You have a folder (`/var/www/html/uploads/`) where anonymous users can upload attachment thanks to a web form. You want to be sure there is no malicious uploaded files. So you decide to deploy `clamscan-docker` to scan this folder each 15 minutes and to be alerted to `mymail@mydomain.fr` if a virus is uploaded. Here is the docker commande you will run:

```
docker run -d
  -v /var/www/html/uploads/:/folder-to-scan/ \
  -e SCAN_AT_STARTUP="1"
  -e CRON_CLAMSCAN="*/15 * * * *" \
  -e ALERT_SUBJECT="Alert from clamscan !" \
  -e ALERT_MAILTO="mymail@mydomain.fr" \
  -e SMTP_HOST="smtp.mydomain.fr" \
  -e SMTP_PORT="25" \
  abesesr/clamscan-docker:1.0.3
```

## Developement

### Debugging and testing

Firstly, download a virus and put it into `./volumes/folder-to-scan/`:
```
cd ./clamscan-docker/
mkdir -p volumes/folder-to-scan/ && cd volumes/folder-to-scan/ 
curl https://raw.githubusercontent.com/ytisf/theZoo/master/malwares/Binaries/Win32.LuckyCat/Win32.LuckyCat.zip > ./Win32.LuckyCat.zip
unzip -P infected ./Win32.LuckyCat.zip 
```

Then run the docker-compose.yml to scan this folder:
```
cd ./clamscan-docker/
docker-compose up
```

Then, open your browser at http://127.0.0.1:8025/ to look at the alert mail sent at the fake email `security@team.fr`

### Generating a new version

To generate a new version, just run theses commandes (and change the "-patch" option in the NEXT_VERSION line if necessary):
```
curl https://raw.githubusercontent.com/fmahnke/shell-semver/master/increment_version.sh > increment_version.sh
chmod +x ./increment_version.sh
CURRENT_VERSION=$(git tag | tail -1)
NEXT_VERSION=$(./increment_version.sh -patch $CURRENT_VERSION) # -patch, -minor or -major
sed -i "s#clamscan-docker:$CURRENT_VERSION#clamscan-docker:$NEXT_VERSION#g" README.md docker-compose.yml
git commit README.md docker-compose.yml -m "Version $NEXT_VERSION" 
git tag $NEXT_VERSION
git push --tags
```

