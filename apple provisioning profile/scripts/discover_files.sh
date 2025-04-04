#!/bin/bash

DIRECTORY="/var/log/zabbix/output"

echo '{'
echo '  "data":['

first=1
for file in "$DIRECTORY"/*; do
  if [[ -f $file ]]; then
    filename=$(basename "$file")

    if [[ $first -ne 1 ]]; then
      echo ','
    else
      first=0
    fi

    echo "    {"
    echo "      \"{#FILENAME}\":\"$filename\""
    echo "    }"
  fi
done

echo '  ]'
echo '}'
