# Check apple provisioning profiles expiration date by zabbix.

## Description

Check expiration date of apple provisioning profiles by zabbix server.

Tested on Zabbix 7.0.0 and macOS 14.4.1.


## Requirements:
- Zabbix 7.0.0 or later
- macOS with bash

## How it works?
1. Shell script "discover_files.sh" checks all provisioning profiles, finds the expiration dates of all files(if we have 2 or more profiles with the same profile name inside the directory it takes the latest date expiration) and creates files for zabbix on the path "/var/log/zabbix/output/$name" with content:
```console
name = Development MacOS;
expdate = 2030-01-10T10:05:10Z;
```
2. Shell script "parse_prov.sh" takes content from the previous step files and brings it to the zabbix server.

3. Template "macOS_check_provisionprofile_date_expiration.yaml" creates item with the name of provisioning profile, item with expiration date of each provisioning profile and trigger for each provisioning profile with message 'Provisioning {#FILENAME} expires less than in 30 days'.
4. If you add new provisioning profile, new items and triggers will be created for them. Also old dates of expiration will be updated with update of profiles.

## Setup:

1. Put the directory "scripts" to the macOS. Make shell scripts executable (e.g. chmod +x /scripts/*)
2. Change in shell script "parse_prov.sh" the path to the directory with provisioning profiles. (DIRECTORY="/Users/USERNAME/Library/MobileDevice/Provisioning Profiles")
3. Make crontab for shell script "parse_prov.sh". Once in 24 hours will be enough:
```console
0 12 * * * /scripts/parse_prov.sh
```
4. Zabbix agent should be preinstalled on this Mac PC and be working. Add to your "zabbix_agentd.conf" user parameter with the path to the shell script "discover_files.sh":
```console
UserParameter=file.discovery,/scripts/discover_files.sh
```
5. Restart zabbix agent.
6. Import the template "macOS_check_provisionprofile_date_expiration.yaml" to your zabbix server and attach it to the macOS host.