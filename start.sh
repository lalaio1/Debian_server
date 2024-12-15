#!/bin/sh

if [ "$(id -u)" -ne "0" ]; then
  echo "inicia essa porra com o usuario root"
  exit 1
fi

apt-get update -y 
apt-get upgrade -y
apt-get install -y openssh-server
apt-get install -y sudo

apt-get install -y chrony
systemctl start chronyd
systemctl enable chronyd
chronyc tracking
chronyc makestep


IP_ADDRESS=$(hostname -I | awk '{print $1}')

SSHD_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSHD_CONFIG" ]; then
  exit 1
fi

if grep -q "^#ListenAddress" "$SSHD_CONFIG"; then
  sed -i "/^#ListenAddress/c\ListenAddress $IP_ADDRESS" "$SSHD_CONFIG"
elif grep -q "^ListenAddress" "$SSHD_CONFIG"; then
  sed -i "/^ListenAddress/c\ListenAddress $IP_ADDRESS" "$SSHD_CONFIG"
else
  echo "ListenAddress $IP_ADDRESS" >> "$SSHD_CONFIG"
fi

if grep -q "^#PermitRootLogin" "$SSHD_CONFIG"; then
  sed -i "/^#PermitRootLogin/c\PermitRootLogin yes" "$SSHD_CONFIG"
elif grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
  sed -i "/^PermitRootLogin/c\PermitRootLogin yes" "$SSHD_CONFIG"
else
  echo "PermitRootLogin yes" >> "$SSHD_CONFIG"
fi

systemctl restart ssh


install_python() {
  if command -v python3 >/dev/null 2>&1; then
    apt-get install -y python3 python3-pip
  else
    apt-get install -y python3 python3-pip
  fi
}

install_pip() {
  if command -v pip3 >/dev/null 2>&1; then
    pip3 install --upgrade pip
  else
    apt-get install -y python3-pip
  fi
}



install_python
install_pip


apt-get install -y fail2ban
cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enabled  = true
port     = ssh
logpath  = %(sshd_log)s
maxretry = 5
bantime  = 10m
EOF
systemctl restart fail2ban

apt-get install -y unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades

apt-get install -y logrotate
echo "/var/log/syslog {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    delaycompress
    sharedscripts
}" > /etc/logrotate.d/syslog

echo "/var/log/auth.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    delaycompress
    sharedscripts
}" > /etc/logrotate.d/auth


sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow out 80/tcp
sudo ufw allow out 443/tcp
sudo ufw deny out 5555
sudo ufw allow 9090/tcp
sudo ufw deny out 6666
sudo ufw allow 9050
sudo ufw allow 9051
sudo ufw allow 8118
sudo ufw deny icmp
sudo ufw allow ssh
sudo ufw enable
sudo ufw status verbose

apt-get install -y aide
aideinit
cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db

apt-get install -y rkhunter
rkhunter --update

apt-get install -y docker.io
systemctl start docker
systemctl enable docker

apt-get install -y tor
apt-get install -y obfs4proxy
apt-get install -y meek-client 
apt-get install -y snowflake-client
systemctl start tor
systemctl enable tor
TOR_CONFIG="/etc/tor/torrc"

TOR_CONFIG="/etc/tor/torrc"
echo "Configurando o Tor para escutar na porta SOCKS5 (9050) e habilitar o ControlPort (9051)..."
if grep -q "^#SocksPort" "$TOR_CONFIG"; then
  sed -i "/^#SocksPort/c\SocksPort 0.0.0.0:9050" "$TOR_CONFIG"
elif grep -q "^SocksPort" "$TOR_CONFIG"; then
  sed -i "/^SocksPort/c\SocksPort 0.0.0.0:9050" "$TOR_CONFIG"
else
  echo "SocksPort 0.0.0.0:9050" >> "$TOR_CONFIG"
fi

if grep -q "^#ControlPort" "$TOR_CONFIG"; then
  sed -i "/^#ControlPort/c\ControlPort 9051" "$TOR_CONFIG"
elif grep -q "^ControlPort" "$TOR_CONFIG"; then
  sed -i "/^ControlPort/c\ControlPort 9051" "$TOR_CONFIG"
else
  echo "ControlPort 9051" >> "$TOR_CONFIG"
fi

if ! grep -q "Log notice" "$TOR_CONFIG"; then
  echo "Log notice file /var/log/tor/notices.log" >> "$TOR_CONFIG"
fi

if ! grep -q "UseBridges 1" "$TOR_CONFIG"; then
  echo "UseBridges 1" >> "$TOR_CONFIG"
  echo "ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy" >> "$TOR_CONFIG"
  
  echo "Adicionando bridges obfs4..."
  echo "Bridge obfs4 178.17.170.33:4444 07D619A6011501CC892FAA78D182F0B20C826145 cert=DdnwQv/dJBh2aeW+PQWPHKZMijhEOy593n87dKKEBb6T7DWEIZOk3LdNOOH0sRoZsDdefw iat-mode=0" >> "$TOR_CONFIG"
  echo "Bridge obfs4 76.150.191.15:64998 3605A1AA3AD7E4E418E9F3C2C72F40DEA6BEA637 cert=oQfwM8t2d6cXcF8xSpqnp4JdGS1QIzz6C/6gGWeTy6CAssIIVbthr1TRlHaTV8HTqEt2Ig iat-mode=0" >> "$TOR_CONFIG"
fi

if ! grep -q "ClientTransportPlugin meek exec" "$TOR_CONFIG"; then
  echo "Adicionando meek transport..."
  echo "ClientTransportPlugin meek exec /usr/bin/meek-client" >> "$TOR_CONFIG"
  echo "Bridge meek 0.0.2.0:2" >> "$TOR_CONFIG"
fi

if ! grep -q "ClientTransportPlugin snowflake exec" "$TOR_CONFIG"; then
  echo "Adicionando snowflake transport..."
  echo "ClientTransportPlugin snowflake exec /usr/bin/snowflake-client" >> "$TOR_CONFIG"
fi

if ! grep -q "ClientTransportPlugin obfs3 exec" "$TOR_CONFIG"; then
  echo "Adicionando obfs3 transport..."
  echo "ClientTransportPlugin obfs3 exec /usr/bin/obfs4proxy" >> "$TOR_CONFIG"
  echo "Bridge obfs3 178.17.170.33:4443 07D619A6011501CC892FAA78D182F0B20C826145" >> "$TOR_CONFIG"
fi

systemctl restart tor

# echo "instalando cockpit"
# apt-get install -y cockpit 
# apt-get install -y cockpit-machines 
# systemctl enable --now cockpit.socket
# apt install -y cockpit-navigator
# systemctl restart cockpit

if ! grep -Fxq "neofetch" ~/.bashrc; then
    echo "neofetch" >> ~/.bashrc
else
    echo "[!] Neofetch ja está configurado para iniciar no terminal."
fi

apt-get install -y php
apt-get install -y nmap 
apt-get install -y git
apt-get install -y sqlmap
apt-get install -t netcat
apt-get install -y hashcat
apt-get install -y gnupg2
apt-get install -y wget 
apt-get install -y curl 
apt-get install -y gcc-mingw-w64 
apt-get install -y g++-mingw-w64
apt-get install -y cmake
apt-get install -y ruby
apt-get install -y nasm
apt-get install -y golang-go
apt-get install -y golang
apt-get install -y neofetch
apt-get install -y apt-transport-https
apt-get install -y python3.11-venv 
python3 -m venv /venv
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc |  tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" |  tee /etc/apt/sources.list.d/ngrok.list &&  apt update &&  apt install ngrok
ngrok config add-authtoken 2fVPAdmzYDxqsIMcTXMIvbHmhcl_3YPjXEi7GNCGxFL3cND5t
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod +x msfinstall
./msfinstall
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustup target add x86_64-pc-windows-gnu
rustup target add x86_64-pc-windows-msvc
apt-get install -y mingw-w64
curl -fsS https://dlang.org/install.sh | bash -s dmd
echo "de o comando : msfdb init"

# -================= Recarrega o terminal 
source ~/.bashrc
