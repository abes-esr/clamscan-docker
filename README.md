# clamscan-docker

[![Docker Pulls](https://img.shields.io/docker/pulls/abesesr/clamscan-docker.svg)](https://hub.docker.com/r/abesesr/clamscan-docker/)
[![clamscan-docker ci](https://github.com/abes-esr/clamscan-docker/actions/workflows/ci.yml/badge.svg)](https://github.com/abes-esr/clamscan-docker/actions/workflows/ci.yml)

Dockerization of [ClamAV](https://www.clamav.net/) and specifically `clamscan` command used to scan periodicaly a specific folder for detecting trojans, viruses, malware & other malicious threats. If something bad is detected, an email is sent.

![](https://docs.google.com/drawings/d/e/2PACX-1vQEDK9TB6PJMLF1HA_Js9b36rVfaByUg8Z-9MWk0atfRWWl4DBop_wq8_phRzM82_y6R39iMoreE0vD/pub?w=200)

[demo](https://user-images.githubusercontent.com/328244/116212678-5d9bb680-a745-11eb-909a-e2ad75d750a1.mp4)



## Parameters

- `SCAN_AT_STARTUP`: if 1, then start with a scan when the container is created (default is `1`)
- `FRESHCLAM_AT_STARTUP`: if 1, then update the virus database when the container startup (default is `1`)
- `SCAN_ONLY_NEW_FILES`: if 1, then the scan will scan a first time the whole `FOLDER_TO_SCAN` content, and the next time (see `CRON_CLAMSCAN`) it will only scan the new files found. Thanks to this feature, the process will be lighter (less CPU usage) especially when there is lot and lot of files in `FOLDER_TO_SCAN` (default is `1`)
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
docker run -d --name myclamavcontainer \
  -v /var/www/html/uploads/:/folder-to-scan/ \
  -e SCAN_AT_STARTUP="1"
  -e CRON_CLAMSCAN="*/15 * * * *" \
  -e ALERT_SUBJECT="Alert from clamscan !" \
  -e ALERT_MAILTO="mymail@mydomain.fr" \
  -e SMTP_HOST="smtp.mydomain.fr" \
  -e SMTP_PORT="25" \
  abesesr/clamscan-docker:1.4.5
```

## Developement

### Debugging and testing

Firstly, download a virus and put it into `./volumes/folder-to-scan/`:
```
cd ./clamscan-docker/
mkdir -p volumes/folder-to-scan/ && cd volumes/folder-to-scan/ 
curl -L "https://github.com/ytisf/theZoo/blob/dd88d539de6c91e39483848fa0bd2fe859009c3e/malware/Binaries/Win32.LuckyCat/Win32.LuckyCat.zip?raw=true" > ./Win32.LuckyCat.zip
unzip -P infected ./Win32.LuckyCat.zip 
```

Then run the `docker-compose.yml` to scan the `volumes/folder-to-scan/` folder:
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
git push && git push --tags
```

## See also

- https://dev.to/brisbanewebdeveloper/scan-infected-files-with-docker-and-clam-antivirus-clamav-1939
- https://medium.com/@darkcl_dev/scanning-files-with-clamav-inside-a-dockerized-node-application-bd2e5fcc5ce8

