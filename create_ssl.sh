#!/bin/bash

echo "For whom/for what the certificate? ((S)erver/(U)ser/(C)ancel) "
while true; do
        read -r
        object=$REPLY
        if [[ "$object" == "S" ]] || [[ "$object" ==  "s" ]]; then
                echo "What is the name of your site? "
                read -r
                name=$REPLY
                break
        elif [[ "$object" == "U" ]] || [[ "$object" ==  "u" ]]; then
                echo "What is the name of your user? "
                read -r
                name=$REPLY
                break
        elif [[ "$object" == "C" ]] || [[ "$object" == "c" ]]; then
                exit
        else
                echo "Correct answer is S/s/U/u/C/c only!"
        fi
done
echo "Which CA to use? "
echo `ls ~/ | grep -E -i 'CA|easy|rsa'`
read -r
ca=$REPLY
cd ~/$ca/
echo "How long to sign the certificate (in days)?
365 - 1 year
730 - 2 years
1095 - 3 years
1460 - 4 years
1825 - 5 years "
read -r
year_new=$REPLY
mkdir ~/ssl_scripts/ssl_certs/$name
year_old=`cat ~/$ca/vars | grep "set_var EASYRSA_CERT_EXPIRE"`
sed -i "s/$year_old/set_var EASYRSA_CERT_EXPIRE $year_new/" ~/$ca/vars
./easyrsa gen-req $name nopass
if [[ "$object" == "S" ]] || [[ "$object" ==  "s" ]]; then
        ./easyrsa sign-req server $name
        echo "Do you need dh.pem? (y/n)"
        read -r
        dh=$REPLY
        if [[ "$dh" == "y" ]]; then
                if [ -e pki/dh.pem ]; then
                        mv pki/dh.pem ~/ssl_scripts/ssl_certs/$name
                else
                        ./easyrsa gen-dh
                        mv pki/dh.pem ~/ssl_scripts/ssl_certs/$name
                fi
        fi
        cp ~/$ca/pki/issued/$name.crt ~/ssl_scripts/ssl_certs/$name
        cp ~/$ca/pki/RootCA.crt ~/ssl_scripts/ssl_certs/$name
        cp ~/$ca/pki/private/$name.key ~/ssl_scripts/ssl_certs/$name
        cat ~/$ca/pki/issued/$name.crt ~/$ca/pki/SubCA.crt > ~/ssl_scripts/ssl_certs/$name/$name.fullchain.crt
elif [[ "$object" == "U" ]] || [[ "$object" ==  "u" ]]; then
        ./easyrsa sign-req client $name
        ./easyrsa export-p12 $name
        cp ~/$ca/pki/issued/$name.crt ~/ssl_scripts/ssl_certs/$name
        cp ~/$ca/pki/RootCA.crt ~/ssl_scripts/ssl_certs/$name
        cp ~/$ca/pki/private/$name.{key,p12} ~/ssl_scripts/ssl_certs/$name
fi
echo "$name `date | cut -d " " -f2,3,4` $ca $year_new $object  CREATE" >> ~/ssl_scripts/cert_base
whoami=`whoami`
sudo chown -R $whoami:$whoami ~/ssl_scripts/ssl_certs/$name/
echo "DONE!"

