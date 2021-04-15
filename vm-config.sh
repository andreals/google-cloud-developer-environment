#!/bin/bash
USER=$1
EMAIL_APPRATICO=$2

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Verifica se for --help, mostra como usa o comando
if [ "${USER}" = "--help" ]; then
    echo "Uso: sh vm-config.sh [usuario] [e-mail appratico]"
    exit 0
fi

# Se não recebeu USER e EMAIL_APPRATICO, retorna erro
if [ "${USER}" = "" ] || [ "${EMAIL_APPRATICO}" = "" ]; then
    echo "${RED}Favor informar os parâmetros corretos."
    echo "${NC}Use: sh vm-config.sh --help"
    exit 3
fi

# Valida se as dependências necessárias foram instaladas.
deps="git zsh curl"
for dep in ${deps}; do
    exists=$(eval "command -v $dep")
    if [ "${exists}" = "" ]; then
        echo "${RED}$dep não instalada(o)..."
        echo "${NC}Aguarde a instalação da VM terminar."
        exit 3
    fi
done

# Criando/refazendo usuário
sudo passwd ${USER}

# Configurando GIT
git config --global user.name "${USER}"
git config --global user.email "${EMAIL_APPRATICO}"

# Gerando chave SSH
ssh-keygen
echo "${NC}---------------------"
echo "${GREEN}Conteúdo SSH Key:"
echo "${NC}---------------------${NC}"
cat /home/${USER}/.ssh/id_rsa.pub
echo "${NC}---------------------"
echo "${GREEN}Copie o conteúdo acima"
echo "${NC}Vá até o site: https://bitbucket.org/account/settings/ssh-keys/"
echo "${GREEN}Adicione uma nova chave e cole o conteúdo copiado"
echo "${NC}---------------------"

bitbucket=""
while [ "$bitbucket" != "yes" ]; do
    echo "${NC}Após inserir a chave no BitBucket, digite [yes]:"
    read bitbucket
done

# Criando diretórios do Documentos
echo "${GREEN}Criando diretório Documentos...${NC}"
mkdir ~/Documentos/
cd ~/Documentos

# Iniciando clone dos repositórios
echo "${GREEN}Iniciando clone dos repositórios...${NC}"
git clone git@bitbucket.org:teamappratico/qualityentregas.git
git clone git@bitbucket.org:teamappratico/qualityentregas-app.git
git clone git@bitbucket.org:teamappratico/appratico.git

# Instalando Go 1.14
if [ -d "/usr/local/go" ]; then
    echo "${RED}Removendo diretório Go...${NC}"
    sudo rm -rf /usr/local/go
fi

echo "${GREEN}Fazendo download do Go 1.14...${NC}"
wget https://golang.org/dl/go1.14.13.linux-amd64.tar.gz
echo "${GREEN}Instalando Go...${NC}"
sudo tar -C /usr/local -xzf go1.14.13.linux-amd64.tar.gz
echo "${RED}Removendo Go.tar...${NC}"
rm -rf go1.14.13.linux-amd64.tar.gz

# Instalando Go bin
if [ ! -d "/home/${USER}/go/bin" ]; then
  echo "${GREEN}Criando pasta bin...${NC}"
  mkdir -p /home/${USER}/go/bin
fi

echo "${GREEN}Fazendo download dos arquivos Bin...${NC}"
wget https://storage.googleapis.com/appratico-dev/bin.zip
echo "${GREEN}Descompactando arquivos Bin...${NC}"
unzip -o bin.zip -d /home/$USER/go/bin
echo "${RED}Removendo Bin.zip...${NC}"
rm -rf bin.zip

# Configurando gcloud
gcloud auth login

# Finalizando script
echo "${GREEN}Pronto... Seu ambiente foi configurado com sucesso!${NC}"

# Configurando ZSH
echo "${GREEN}Configurando ZSH...${NC}"
sh -c "$(curl -fsSL https://storage.googleapis.com/appratico-dev/install-zsh.sh)"
chsh -s /usr/bin/zsh ${USER}