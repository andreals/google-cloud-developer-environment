#!/bin/bash
VM=$1

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Verifica se for --help, mostra como usa o comando
if [ "${VM}" = "--help" ]; then
    echo "Uso: sh local-config.sh [vmname]"
    exit 0
fi

# Se não recebeu VM, retorna erro
if [ "${VM}" = "" ]; then
    echo "${RED}Favor informar os parâmetros corretos."
    echo "${NC}Use: sh local-config.sh --help"
    exit 3
fi

# Valida se as dependências necessárias foram instaladas.
deps="gcloud wget sed grep"
for dep in ${deps}; do
    exists=$(eval "command -v $dep")
    if [ "${exists}" = "" ]; then
        echo "${RED}$dep não instalada(o)..."
        echo "${NC}Favor realizar a instalação e se autenticar."
        exit 3
    fi
done

# Cria a VM no GCP
echo "${GREEN}Criando VM ${VM} no GCP...${NC}"
gcloud beta compute --project=appratico-dev instances create ${VM} \
	--zone=southamerica-east1-b --machine-type=n1-standard-1 --subnet=default --network-tier=PREMIUM --metadata=startup-script-url=gs://appratico-dev/startup.sh \
	--no-restart-on-failure --maintenance-policy=TERMINATE --preemptible --service-account=590576424562-compute@developer.gserviceaccount.com \
	--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
	--image=debian-10-buster-v20210316 --image-project=debian-cloud --boot-disk-size=30GB --boot-disk-type=pd-balanced \
	--boot-disk-device-name=${VM} --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any

# Reservar IP Estático
echo "${GREEN}Reservando IP Estático para a VM ${VM} no GCP...${NC}"
gcloud compute addresses create ${VM}-ip --project=appratico-dev --region=southamerica-east1

echo "${GREEN}Obtendo IP Estático criado no GCP...${NC}"
ip=$(eval "gcloud compute addresses describe ${VM}-ip --project=appratico-dev --region=southamerica-east1 \
    --format=\"value(address)\"")
echo "${GREEN}IP obtido: ${ip}${NC}"

echo "${GREEN}Obtendo Access Config Name no GCP...${NC}"
name=$(eval "gcloud compute instances describe ${VM} --project=appratico-dev --zone=southamerica-east1-b \
    --format=\"value(networkInterfaces.accessConfigs.name)\" | sed -e \"s/\['\|'\]//g\"")
echo "${GREEN}Access Config Name obtido: ${name}${NC}"

echo "${GREEN}Deletando Access Config Name...${NC}"
gcloud compute instances delete-access-config ${VM} --access-config-name="${name}" --project=appratico-dev --zone=southamerica-east1-b

echo "${GREEN}Atribuindo novo IP Estático (${ip}) na VM (${VM})...${NC}"
gcloud compute instances add-access-config ${VM} --access-config-name="${name}" --address ${ip} --project=appratico-dev --zone=southamerica-east1-b

# Mudar de diretório
cd ~/.ssh/

# Criar launch-gc-vm
echo "${GREEN}Fazendo download do Launch GC VM...${NC}"
wget https://storage.googleapis.com/appratico-dev/launch-gc-vm.sh
echo "${GREEN}Alterando permissão do Launch GC VM...${NC}"
chmod +x launch-gc-vm.sh

# Criar config
echo "${GREEN}Fazendo download do Config...${NC}"
wget https://storage.googleapis.com/appratico-dev/config
echo "${GREEN}Alterando dados do Config...${NC}"
sed -i "s/X.X.X.X/${ip}/" config
sed -i "s/path\/to/home\/$USER\/.ssh/" config
sed -i "s/myvm\"/${VM}\"/" config
sed -i "s/myvm/${VM}/" config
sed -i "s/myuser/$USER/" config

# Finalizado
echo "${GREEN}Parabéns, seu ambiente DEV está quase concluido!${NC}"

# Fazendo primeiro acesso na VM via gcloud
echo "${GREEN}Acessando VM via gcloud...${NC}"
gcloud compute ssh ${VM} --project=appratico-dev