#!/bin/bash

echo "Which CA to use? "
echo `ls ~/ | grep easyrsa`
read -r
ca=$REPLY
cd ~/$ca/
echo "For which server to revoke the certificate? "
echo `ls pki/issued/ | cut -d '.' -f 1`
read -r
name_crt=$REPLY
printf "yes" | ./easyrsa revoke $name_crt
./easyrsa gen-crl
cp pki/crl.pem ~/ssl_scripts/ssl_certs/
rm ~/$ca/pki/issued/$name_crt.crt
echo "DONE!"
