# Automação de Configuração de Sistema Linux (Debian) 🖥️

![jntfrfgvhytfrfg](1.png)

Este script realiza a automação de diversas tarefas de configuração e instalação em um sistema baseado em Debian (Ubuntu, etc.). Ele instala pacotes essenciais, configura serviços de segurança, e ajusta configurações de rede para otimizar a segurança e a performance do sistema.

---
## Como Executar o script (automatic) 💠
1. **Abra o terminal como sudo e cole este comando**
  ```bash
git clone https://github.com/lalaio1/Debian_server.git && \
cd Debian_server && \
chmod +x start.sh && \
sudo ./start.sh
```

---

## Como Executar o Script (manual) 🏃‍♂️

1. **Obtenha o script**:
   Baixe o script para o seu servidor Linux.
   
2. **Torne o script executável**:
   ```bash
   chmod +x start.sh
   ```

3. **Execute o script como root**:
   Para garantir que o script funcione corretamente, execute-o como usuário root.
   ```bash
   sudo ./start.sh
   ```

---

## Funcionalidades do Script 🚀

### 1. **Verificação de Permissão de Execução como Root** 🔐
O script verifica se está sendo executado com privilégios de root (superusuário) para evitar falhas devido à falta de permissões.

### 2. **Atualizações de Pacotes** 📦
- Atualiza os pacotes do sistema com `apt-get update` e `apt-get upgrade`.

### 3. **Instalação e Configuração do OpenSSH** 🔐
- Instala o servidor **OpenSSH** e habilita o acesso remoto via SSH.
- Configura a permissão de login para o usuário root.

### 4. **Configuração do NTP (Network Time Protocol)** ⏰
- Instala e configura o **Chrony** para sincronização de tempo.

### 5. **Instalação de Ferramentas de Segurança** 🛡️
- Instala o **Fail2Ban**, que protege contra ataques de força bruta.
- Configura o **ufw** (Uncomplicated Firewall) para controlar o tráfego de rede.
- Instala e configura o **AIDE** (Advanced Intrusion Detection Environment).
- Instala o **rkhunter** para verificar rootkits no sistema.

### 6. **Instalação de Containers e Tor** 🌀
- Instala o **Docker** para criar e gerenciar containers.
- Instala o **Tor** e configura o Tor como um proxy para garantir anonimato na rede.

### 7. **Instalação de Ferramentas de Penetração e Desenvolvimento** 🔍
- Instala ferramentas como **Metasploit**, **Nmap**, **Git**, **Sqlmap**, **Hashcat**, entre outras.
- Instala pacotes como **Python**, **PHP**, **Ruby**, **Go**, **CMake**, **Neofetch**, **ngrok**, entre outros, para automação e desenvolvimento.

---

## Instalações Realizadas 🛠️

Abaixo estão os pacotes e ferramentas instalados e configurados pelo script:

| Pacote/Ferramenta         | Descrição                                                     | Emoji         |
|---------------------------|---------------------------------------------------------------|---------------|
| **OpenSSH Server**         | Servidor SSH para acesso remoto.                             | 🔐            |
| **Chrony**                 | Serviço de sincronização de tempo NTP.                       | ⏰            |
| **Fail2Ban**               | Protege contra ataques de força bruta em serviços SSH.       | 🛡️            |
| **ufw (Firewall)**         | Firewall para bloquear e permitir tráfego de rede.           | 🚫            |
| **AIDE**                   | Ferramenta de detecção de intrusão avançada.                  | 🔍            |
| **rkhunter**               | Ferramenta para verificar rootkits.                          | 👾            |
| **Docker**                 | Plataforma para containers e virtualização.                  | 📦            |
| **Tor**                    | Rede de anonimato para navegação segura.                     | 🌀            |
| **Metasploit**             | Framework para testes de penetração e exploração de falhas.  | 🐍            |
| **Nmap**                   | Ferramenta para auditoria de rede.                           | 🌐            |
| **Git**                    | Sistema de controle de versão para desenvolvimento de código.| 🧑‍💻         |
| **Sqlmap**                 | Ferramenta para testes de SQL injection.                     | 💉            |
| **Hashcat**                | Ferramenta para quebra de hashes.                            | 🔓            |
| **Neofetch**               | Ferramenta para exibir informações do sistema.               | 🖥️            |
| **ngrok**                  | Serviço para criar túneis de rede (túnel seguro).             | 🌉            |
| **PHP**                    | Linguagem de programação para desenvolvimento web.           | 💻            |
| **Python**                 | Linguagem de programação popular.                            | 🐍            |
| **Ruby**                   | Linguagem de programação para desenvolvimento web.           | 💎            |
| **Go**                     | Linguagem de programação para sistemas e redes.              | 🏁            |
| **CMake**                  | Ferramenta para controle de builds de projetos.              | 🛠️            |
| **MinGW-w64**              | Ferramenta para compilar binários para Windows.              | 💻            |
| **Rust**                   | Linguagem de programação focada em performance e segurança.  | 🦀            |
| **Dlang**                  | Linguagem de programação para sistemas e redes.              | 🐬            |
| **Nmap**                   | Scanner de rede para auditoria e mapeamento de redes.        | 🌍            |

---

## Observações Importantes ⚠️

- O script foi projetado para ser executado em sistemas baseados em Debian (Ubuntu, etc.).
- Algumas instalações podem variar dependendo do ambiente ou da configuração do seu sistema.
- **Atenção**: O script realiza mudanças importantes no seu sistema, como a configuração de firewall, instalação de serviços de segurança, entre outros.

---
