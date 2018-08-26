#!/bin/bash

get_info() {
    read -p "Enter an email for SSL certificate notifications: " email
    read -p "Enter the domain name for the SSL certificate: " domain
    domain_two="www.${domain}"
}

install_lego() {
    cd /tmp
    curl -s https://api.github.com/repos/xenolf/lego/releases/latest | grep browser_download_url | grep linux_amd64 | cut -d '"' -f 4 | wget -i -
    tar xf lego*
    sudo mv lego /usr/local/bin/lego
    rm lego*
}

stop_services() {
    sudo /opt/bitnami/ctlscript.sh stop
}

get_ssl_cert() {
    sudo lego --email="${email}" --domains="${domain}" --domains="${domain_two}" --path="/etc/lego" run
}

rename_default_ssl() {
    sudo mv /opt/bitnami/apache2/conf/server.crt /opt/bitnami/apache2/conf/server.crt.old
    sudo mv /opt/bitnami/apache2/conf/server.key /opt/bitnami/apache2/conf/server.key.old
    sudo mv /opt/bitnami/apache2/conf/server.csr /opt/bitnami/apache2/conf/server.csr.old
}

link_ssl_certs() {
    sudo ln -s /etc/lego/certificates/${domain}.key /opt/bitnami/apache2/conf/server.key
    sudo ln -s /etc/lego/certificates/${domain}.crt /opt/bitnami/apache2/conf/server.crt
}

change_permissions() {
    sudo chown root:root /opt/bitnami/apache2/conf/server*
    sudo chmod 600 /opt/bitnami/apache2/conf/server*
}

restart_services() {
    sudo /opt/bitnami/ctlscript.sh start
}

get_info
install_lego
stop_services
get_ssl_cert
rename_default_ssl
link_ssl_certs
change_permissions
restart_services
