#!/bin/bash

source "./csv2json.jq"

USERNAME="<git user>"

TOKEN="<git token>"

PERPAGE=100

BASEURL="https://api.github.com/orgs/<ORG or USERNAME>/repos"

TOTALPAGES=`curl -I -i -u $USERNAME:$TOKEN -H "Accept: application/vnd.github.v3+json" -s ${BASEURL}\?per_page\=${PERPAGE} | grep -i link: 2>/dev/null|sed 's/link: //g'|awk -F',' -v  ORS='\n' '{ for (i = 1; i <= NF; i++) print $i }'|grep -i last|awk '{print $1}' | tr -d '\<\>' | tr '\?\&' ' '|awk '{print $3}'| tr -d '=;page'`

i=1

echo "Repo Name,SSH URL,Clone URL,Languages,Created at,Updated At,Visibility,Archived" >> list.csv

until [ $i -gt $TOTALPAGES ]
do
  result=`curl -s -u $USERNAME:$TOKEN -H 'Accept: application/vnd.github.v3+json' ${BASEURL}?per_page=${PERPAGE}\&page=${i} 2>&1`
  echo $result > tempfile
  cat tempfile|jq '.[]| [.name, .ssh_url, .clone_url, .language, .created_at, .updated_at, .visibility, .archived]| @csv'|tr -d '\\"' >> list.csv
  ((i=$i+1))
done

jq -cR 'split(",")' list.csv | jq -csf csv2json.jq > out.json

jq -c -r ".[]" out.json | while read line; do echo '{"index":{}}'; echo $line; done > bulk.json

curl -X DELETE "localhost:9200/git-big-brother"

curl -XPOST http://localhost:9200/git-big-brother/_doc/_bulk -H "Content-Type: application/json" --data-binary @bulk.json

rm -f bulk.json list.csv out.json tempfile
