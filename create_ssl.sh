#!/bin/bash

echo "How is name your site? "
read -r
site=$REPLY
name=`echo $site | cut -d '.' -f 1`
sudo openssl genrsa -out $site.key 4096
echo "C=US
ST=California
L=San_Francisco
O=Copyleft_Certificate_Co
OU=My_Organizational_Unit
CN=$site"
echo "Correct data or other? (Y/n/(C)acel)"
while true; do
        read -r
        data=$REPLY
        if [[ "$data" == "Y" ]] || [[ "$data" ==  "y" ]]; then
                sudo openssl req -new -key $site.key -sha256 -out $name.req -nodes -subj "/C=US/ST=California/L=San_Francisco/O=Copyleft_Certificate_Co/OU=My_Organizational_Unit/CN=$site"
                break
        elif [[ "$data" == "N" ]] || [[ "$data" == "n" ]]; then
                sudo openssl req -new -key $site.key -sha256 -out $name.req -nodes
                break
        elif [[ "$data" == "C" ]] || [[ "$data" == "c" ]]; then
                exit
        else
                echo "Correct answer is Y/y/N/n/C/c only!
Correct data or other? (Y/n/(C)ancel"
        fi
done
sudo mv *.{key,req} ssl_certs/
echo "Which CA to use? "
echo `ls ~/ | grep easyrsa`
read -r
ca=$REPLY
cd ~/$ca/
./easyrsa gen-dh
mv pki/dh.pem ~/ssl_scripts/ssl_certs/
./easyrsa import-req ~/ssl_scripts/ssl_certs/$name.req $name
echo "For how long to sign the certificate?
365 - 1 year
730 - 2 years
1095 - 3 years
1460 - 4 years
1825 - 5 years "
read -r
year_new=$REPLY
year_old=`cat ~/$ca/vars | grep "set_var EASYRSA_CERT_EXPIRE" | cut -d ' ' -f 2`
sed -i "s/set_var $year_old/set_var EASYRSA_CERT_EXPIRE $year_new/" ~/$ca/vars
printf "yes" | ./easyrsa sign-req server $name
cp ~/$ca/pki/issued/$name.crt ~/ssl_scripts/ssl_certs/
sudo rm ~/ssl_scripts/ssl_certs/$name.req
cat ~/$ca/pki/issued/$name.crt ~/$ca/pki/SubCA.crt > ~/ssl_scripts/ssl_certs/$name.fullchain.crt
whoami=`whoami`
sudo chown -R $whoami:$whoami ~/ssl_scripts/ssl_certs
echo "DONE!"
