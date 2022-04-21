#!/bin/bash

echo "Which CA to use? "
echo `ls ~/ | grep -E -i 'CA|easy|rsa'`
read -r
ca=$REPLY
cd ~/$ca/
echo "For whom/for what to revoke the certificate? ((S)erver/(U)ser/(C)ancel) "
echo `ls pki/issued/ | cut -d '.' -f 1`
read -r
name_crt=$REPLY
if [ -e ~/ssl_scripts/ssl_certs/revoke ]; then
        printf "yes" | ./easyrsa revoke $name_crt
        ./easyrsa gen-crl
        cp pki/crl.pem ~/ssl_scripts/ssl_certs/revoke/
else
        mkdir ~/ssl_scripts/ssl_certs/revoke
        printf "yes" | ./easyrsa revoke $name_crt
        ./easyrsa gen-crl
        cp pki/crl.pem ~/ssl_scripts/ssl_certs/revoke/
fi
rm ~/$ca/pki/issued/$name_crt.crt
rm ~/$ca/pki/private/$name_crt.*
rm -r ~/ssl_scripts/ssl_certs/$name_crt
echo "$name_crt `date | cut -d " " -f2,3,4` $ca REVOKE" >> ~/ssl_scripts/cert_base
echo "DONE!"
