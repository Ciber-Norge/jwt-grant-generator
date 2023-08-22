#!/bin/bash

# params
# 1 - environment [l|u|s]
#     l local
#     u development
#     s stage/test
# 2 - operation
#     getReceipts
#     getReceipt
#     deleteReceipt
#     postFile
# 3 - filnavn
#     For getReceipt, deleteReceipt and postFile a filname is needed.

if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters"
    echo "vrapi.sh [l|u|s] <operation> (filename)"
    echo "   l | u | s: local, development or stage/test"
    echo "   vrapi.sh [l|u|s] <operation> (filename)"
    echo "   vrapi.sh [l|u|s] getReceipts"
    echo "   vrapi.sh [l|u|s] getReceipt <name of receipt>"
    echo "   vrapi.sh [l|u|s] deleteReceipt <name of receipt>"
    echo "   vrapi.sh [l|u|s] postFile <name of report file>"
    exit
fi
#SERVER_ADDRESS_STAGE="https://cib-vris-app-vip.cib2.osl.basefarm.net"
SERVER_ADDRESS_STAGE="https://valutareginnrapp-test.skatteetaten.no"
#SERVER_ADDRESS_UTV="http://cib-vrit-app1.cib2.osl.basefarm.net:8080"
SERVER_ADDRESS_UTV="https://cib-vrit-app-vip.cib2.osl.basefarm.net"
SERVER_ADDRESS_LOCAL="https://127.0.0.1:8443"
LEGAL_OPERATIONS=(getReceipts getReceipt deleteReceipt postFile)

if [ "$1" == "l" ]; then
   SERVER_ADDRESS=$SERVER_ADDRESS_LOCAL
elif [ "$1" == "u" ]; then
   SERVER_ADDRESS=$SERVER_ADDRESS_UTV
elif [ "$1" == "s" ]; then
   SERVER_ADDRESS=$SERVER_ADDRESS_STAGE
else
  echo "Unknown environment, use l, u or s"
  exit
fi

OPERATION=$2
FILENAME=""
if [ "$#" -eq 3 ]; then
  FILENAME=$3
fi

TOKEN=`java -jar target/jwt-grant-generator-1.1.0-SNAPSHOT-jar-with-dependencies.jar ./client.properties json | cut -f 4 -d ":" | cut -f 2 -d "\""`

#echo $TOKEN
# options to curl
# -s silent
# -o output to file
# -k Ikke verifiser sertifikat
# -i include response headers
# --location Follow redirect
case $OPERATION in
  "getReceipts")
curl -v -k -s -o - --location --request GET "$SERVER_ADDRESS/api/kvitteringer" --header "Authorization: Bearer $TOKEN"
    ;;
  "getReceipt")
curl -k -o $FILENAME --location --request GET "$SERVER_ADDRESS/api/kvittering?filename=$FILENAME" --header "Authorization: Bearer $TOKEN"
    ;;
  "deleteReceipt")
curl -k -i -o - --location --request DELETE "$SERVER_ADDRESS/api/kvittering?filename=$FILENAME" --header "Authorization: Bearer $TOKEN"
    ;;
  "postFile")
  # lage noe kode som trekker ut kun filnavnet, kan ha fått sti til en annen fil.
curl -k -i -o - --location --header "Content-Type:application/octet-stream" --request POST "$SERVER_ADDRESS/api/file?filename=$FILENAME" --data-binary "@$FILENAME" --header "Authorization: Bearer $TOKEN"
    ;;
  *)
    echo "Invalid operation: "$OPERATION
    ;;
esac
