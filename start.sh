#!/bin/bash

# ================== Variáveis de Cores ====================
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# ================== Verificacao de Root ====================
if [ "$(id -u)" -ne "0" ]; then
  echo "${RED}[✘] Iinicia essa porra com o usuario root${RESET}"
  exit 1
fi

# ================== Funcao de Atualizacao ======================
update_system() {
    echo -e "${YELLOW}[+] Atualizando o sistema...${RESET}"
    apt-get update -y >/dev/null 2>&1 && apt-get upgrade -y >/dev/null 2>&1
    [ $? -eq 0 ] && echo -e "${GREEN}[✔] Sistema atualizado.${RESET}" || echo -e "${RED}[✘] Falha ao atualizar o sistema.${RESET}"
}


# ================== Função para Instalar Pacotes ====================
install_packages() {
    local packages=(
        "openssh-server"
        "sudo"
        "chrony"
        "fail2ban"
        "unattended-upgrades"
        "logrotate"
        "ufw"
        "aide"
        "rkhunter"
        "docker.io"
        "tor"
        "obfs4proxy"
        "meek-client"
        "snowflake-client"
        "php"
        "nmap"
        "git"
        "sqlmap"
        "netcat"
        "hashcat"
        "gnupg2"
        "wget"
        "curl"
        "gcc-mingw-w64"
        "g++-mingw-w64"
        "cmake"
        "ruby"
        "nasm"
        "golang-go"
        "neofetch"
        "apt-transport-https"
        "python3.11-venv"
        #"cockpit"
        #"cockpit-machines"
        #"cockpit-navigator"
    )

    echo -e "${YELLOW}[+] Instalando pacotes essenciais...${RESET}"
    for package in "${packages[@]}"; do
        echo -e "${YELLOW}[+] Instalando $package...${RESET}"
        apt-get install -y "$package" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[✔] $package instalado.${RESET}"
        else
            echo -e "${RED}[✘] Falha ao instalar $package.${RESET}"
        fi
    done
}

# ================== Configurar Chrony ====================
configure_chrony() {
    echo -e "${YELLOW}[+] Instalando e configurando o Chrony...${RESET}"
    apt-get install -y chrony
    systemctl start chrony
    systemctl enable chrony
    chronyc tracking
    chronyc makestep
    echo -e "${GREEN}[✔] Chrony configurado.${RESET}"
}

# ================== Configurar SSH ====================
configure_ssh() {
    local SSHD_CONFIG="/etc/ssh/sshd_config"
    local IP_ADDRESS=$(hostname -I | awk '{print $1}')
    
    echo -e "${YELLOW}[+] Configurando SSH...${RESET}"
    if [ -f "$SSHD_CONFIG" ]; then
        sed -i "/^#ListenAddress/c\ListenAddress $IP_ADDRESS" "$SSHD_CONFIG"
        sed -i "/^#PermitRootLogin/c\PermitRootLogin yes" "$SSHD_CONFIG"
        echo -e "${GREEN}[✔] SSH configurado. Reiniciando serviço...${RESET}"
        systemctl restart ssh
    else
        echo -e "${RED}[✘] Arquivo de configuração SSH não encontrado.${RESET}"
    fi
}

# ================== Configurar Fail2Ban ====================
configure_fail2ban() {
    echo -e "${YELLOW}[+] Configurando Fail2Ban...${RESET}"
    cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enabled  = true
port     = ssh
logpath  = %(sshd_log)s
maxretry = 5
bantime  = 10m
EOF
    systemctl restart fail2ban
    echo -e "${GREEN}[✔] Fail2Ban configurado.${RESET}"
}


# ================== Configurar UFW ====================
configure_ufw() {
    echo -e "${YELLOW}[+] Configurando Firewall (UFW)...${RESET}"

    # Configurações de UFW
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

    echo -e "${GREEN}[✔] UFW configurado e habilitado.${RESET}"
}


# ================== Configurar Tor ====================
configure_tor() {
    echo -e "${YELLOW}[+] Configurando o Tor...${RESET}"

    # Iniciar e habilitar o serviço Tor
    systemctl start tor
    systemctl enable tor

    TOR_CONFIG="/etc/tor/torrc"
    echo "Configurando o Tor para escutar na porta SOCKS5 (9050) e habilitar o ControlPort (9051)..."

    # Configurar SocksPort
    if grep -q "^#SocksPort" "$TOR_CONFIG"; then
        sed -i "/^#SocksPort/c\SocksPort 0.0.0.0:9050" "$TOR_CONFIG"
    elif grep -q "^SocksPort" "$TOR_CONFIG"; then
        sed -i "/^SocksPort/c\SocksPort 0.0.0.0:9050" "$TOR_CONFIG"
    else
        echo "SocksPort 0.0.0.0:9050" >> "$TOR_CONFIG"
    fi

    # Configurar ControlPort
    if grep -q "^#ControlPort" "$TOR_CONFIG"; then
        sed -i "/^#ControlPort/c\ControlPort 9051" "$TOR_CONFIG"
    elif grep -q "^ControlPort" "$TOR_CONFIG"; then
        sed -i "/^ControlPort/c\ControlPort 9051" "$TOR_CONFIG"
    else
        echo "ControlPort 9051" >> "$TOR_CONFIG"
    fi

    # Configurar log
    if ! grep -q "Log notice" "$TOR_CONFIG"; then
        echo "Log notice file /var/log/tor/notices.log" >> "$TOR_CONFIG"
    fi

    # Habilitar bridges 
    if ! grep -q "UseBridges 1" "$TOR_CONFIG"; then
        echo "UseBridges 1" >> "$TOR_CONFIG"
        echo "ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy" >> "$TOR_CONFIG"
        
        # Adicionando bridges obfs4
        echo "Bridge obfs4 178.17.170.33:4444 07D619A6011501CC892FAA78D182F0B20C826145 cert=DdnwQv/dJBh2aeW+PQWPHKZMijhEOy593n87dKKEBb6T7DWEIZOk3LdNOOH0sRoZsDdefw iat-mode=0" >> "$TOR_CONFIG"
        echo "Bridge obfs4 76.150.191.15:64998 3605A1AA3AD7E4E418E9F3C2C72F40DEA6BEA637 cert=oQfwM8t2d6cXcF8xSpqnp4JdGS1QIzz6C/6gGWeTy6CAssIIVbthr1TRlHaTV8HTqEt2Ig iat-mode=0" >> "$TOR_CONFIG"
    fi

    # Adicionar meek transport
    if ! grep -q "ClientTransportPlugin meek exec" "$TOR_CONFIG"; then
        echo "Adicionando meek transport..."
        echo "ClientTransportPlugin meek exec /usr/bin/meek-client" >> "$TOR_CONFIG"
        echo "Bridge meek 0.0.2.0:2" >> "$TOR_CONFIG"
    fi

    # Adicionar snowflake transport
    if ! grep -q "ClientTransportPlugin snowflake exec" "$TOR_CONFIG"; then
        echo "Adicionando snowflake transport..."
        echo "ClientTransportPlugin snowflake exec /usr/bin/snowflake-client" >> "$TOR_CONFIG"
    fi

    # Adicionar obfs3 transport
    if ! grep -q "ClientTransportPlugin obfs3 exec" "$TOR_CONFIG"; then
        echo "Adicionando obfs3 transport..."
        echo "ClientTransportPlugin obfs3 exec /usr/bin/obfs4proxy" >> "$TOR_CONFIG"
        echo "Bridge obfs3 178.17.170.33:4443 07D619A6011501CC892FAA78D182F0B20C826145" >> "$TOR_CONFIG"
    fi

    # Reiniciar o Tor
    systemctl restart tor
    echo -e "${GREEN}[✔] Tor configurado e reiniciado.${RESET}"
}

# ================== Configurar Docker ====================
configure_docker() {
    echo -e "${YELLOW}[+] Configurando Docker...${RESET}"
    systemctl start docker && systemctl enable docker
    echo -e "${GREEN}[✔] Docker configurado.${RESET}"
}

# ================== Instalar Ferramentas ====================
install_tools() {
    echo -e "${YELLOW}[+] Instalando ferramentas adicionais...${RESET}"

    # Instalação do ngrok
    curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" > /etc/apt/sources.list.d/ngrok.list
    apt update && apt install ngrok -y >/dev/null 2>&1
    ngrok config add-authtoken 2fVPAdmzYDxqsIMcTXMIvbHmhcl_3YPjXEi7GNCGxFL3cND5t
    echo -e "${GREEN}[✔] Ngrok instalado e configurado.${RESET}"

    # Instalação do Metasploit
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
    chmod +x msfinstall && ./msfinstall >/dev/null 2>&1
    echo -e "${GREEN}[✔] Metasploit instalado.${RESET}"

    # Configuracao do AIDE
    aideinit
    cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    echo -e "${GREEN}[✔] AIDE instalado e configurado.${RESET}"

    # Configuracao do RKHunter
    rkhunter --update
    echo -e "${GREEN}[✔] RKHunter atualizado.${RESET}"

    # Instalar Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env

    # Rust para Windows
    rustup target add x86_64-pc-windows-gnu
    rustup target add x86_64-pc-windows-msvc
    echo -e "${GREEN}[✔] Rust instalado e configurado.${RESET}"

    # Instalar Dlang
    curl -fsS https://dlang.org/install.sh | bash -s dmd

    echo -e "${GREEN}[✔] Dlang instalado.${RESET}"

    if ! grep -Fxq "neofetch" ~/.bashrc; then
        echo "neofetch" >> ~/.bashrc
        echo -e "${GREEN}[✔] Neofetch configurado para iniciar no terminal.${RESET}"
    fi

    # Configurar unattended-upgrades
    dpkg-reconfigure --priority=low unattended-upgrades

    # Habilitar o serviço de atualizações automáticas
    systemctl enable unattended-upgrades
    systemctl start unattended-upgrades

    echo -e "${GREEN}[✔] Unattended Upgrades configurado.${RESET}"

    # Configuracao do Cockpit
    #systemctl enable --now cockpit.socket

    # Reiniciar o serviço do Cockpit
    #systemctl restart cockpit

    #echo -e "${GREEN}[✔] Cockpit instalado e configurado.${RESET}"

    echo -e "${GREEN}[✔] Ferramentas instaladas e configuradas.${RESET}"
}

# ================== Configurar Ambiente Python ====================
configure_python_env() {
    echo -e "${YELLOW}[+] Configurando ambiente Python...${RESET}"
    python3 -m venv /venv
    echo -e "${GREEN}[✔] Ambiente Python configurado.${RESET}"
}

apt-get install -y unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades

# ================== Configurar Logrotate ====================
configure_logrotate() {
    echo -e "${YELLOW}[+] Configurando logrotate...${RESET}"
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
    echo -e "${GREEN}[✔] Logrotate configurado.${RESET}"
}

# ================== Inicializar Banco de Dados do Metasploit ====================
initialize_msfdb() {
    echo -e "${YELLOW}[+] Inicializando banco de dados do Metasploit...${RESET}"
    
    # Comando para inicializar o banco de dados do Metasploit
    msfdb init
    echo -e "${GREEN}[✔] Banco de dados do Metasploit inicializado.${RESET}"
}

# ================== Função principal ====================
main() {
    update_system
    install_packages
    configure_chrony
    configure_ssh
    configure_fail2ban
    configure_ufw
    configure_tor
    configure_docker
    install_tools
    configure_python_env
    configure_logrotate
    initialize_msfdb
}

main

# ================== Recarrega o terminal ====================
source ~/.bashrc
