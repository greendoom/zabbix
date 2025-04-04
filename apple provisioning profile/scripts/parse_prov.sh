#!/bin/bash

# Directory with files
DIRECTORY="/Users/USERNAME/Library/MobileDevice/Provisioning Profiles"

# Temp files for saving dates and names
temp_file=$(mktemp)

# Go through all files in the directory
for file in "$DIRECTORY"/*; do
  if [[ -f $file ]]; then

    # Parse date and name from file
    date=$(grep -a -A 1 '<key>ExpirationDate</key>' "$file" | grep '<date>' | sed -n 's:.*<date>\(.*\)</date>.*:\1:p')
    name=$(grep -a -A 1 '<key>Name</key>' "$file" | grep '<string>' | sed -n 's:.*<string>\(.*\)</string>.*:\1:p')

    # Check and write into temp file
    if [[ -n $date && -n $name ]]; then
      echo "$name $date" >> "$temp_file"
    fi
  fi
done

# Create/update file with max date
while read -r line; do
  name=$(echo "$line" | awk '{for (i=1; i<=NF-1; i++) printf $i " "; print ""}' | xargs)
  date=$(echo "$line" | awk '{print $NF}')

  output_file="/var/log/zabbix/output/$name"

    # Checking file: $output_file

  if [[ -f $output_file ]]; then
    existing_date=$(grep 'expdate =' "$output_file" | sed 's/expdate = //; s/;//' | xargs)
    # Check existing date in file
    if [[ "$date" > "$existing_date" ]]; then
    # Date in new file greater, overwriting $output_file
      echo "name = $name;" > "$output_file"
      echo "expdate = $date;" >> "$output_file"
    fi
  else
    # Creating file $output_file
    echo "name = $name;" > "$output_file"
    echo "expdate = $date;" >> "$output_file"
  fi
done < <(sort -u "$temp_file")

# Delete temp file
rm "$temp_file"
