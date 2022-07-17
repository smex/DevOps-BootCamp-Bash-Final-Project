#!/bin/bash

USAGE=$(cat <<EOF
Description: Bash tool to transfer files from the command line.
Usage: transfer.sh [-d | -h | -v] [file1 ...]
  -d  dir_name file_id file_name  Download file
  -h  Show the help message
  -v  Get the tool version
Examples:
Upload test.txt and test2.txt files
  ./transfer.sh test.txt test2.txt
Download file test.txt to directory ./test with id on the remote Mij6ca
  ./transfer.sh -d ./test Mij6ca test.txt
EOF
)

currentVersion="1.23.0"

httpSingleUpload()
{
    response=$(curl -A curl --upload-file "$1" "https://transfer.sh/$2") || { echo "Failure!"; return 1;}
}

printUploadResponse()
{
fileID=$(echo "$response" | cut -d "/" -f 4)
  cat <<EOF
Transfer File URL: $response
EOF
}

singleUpload()
{
  filePath=$(echo "$1" | sed s:"~":"$HOME":g)
  if [ ! -f "$filePath" ]; then { echo "Error: invalid file path"; return 1;}; fi
  tempFileName=$(echo "$1" | sed "s/.*\///")
  echo "Uploading $tempFileName"
  httpSingleUpload "$filePath" "$tempFileName"
}

singleDownload()
{
  echo "Downloading to $2 from $1"
  curl --progress-bar "$1" -o "$2"
}

getopts "dhv" opt
case "$opt" in
  h)
    echo "$USAGE" && exit
    ;;
  v)
    echo $currentVersion && exit
    ;;
  d)
    url="https://transfer.sh/$3/$4"
    file="$2$4"
    singleDownload "$url" "$file"
    exit
    ;;
esac

for file in $@; do
  singleUpload "$file" || exit 1
  printUploadResponse
done