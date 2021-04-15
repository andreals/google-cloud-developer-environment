# Ambiente Developer Cloud

## Configurações locais
---

#### Passos:

1. Rode o comando: `wget https://storage.googleapis.com/appratico-dev/local-config.sh`
2. Rode o comando: `sh local-config.sh $VMNAME`, onde `$VMNAME` é o nome da sua VM que será criada
3. Aguarde todos os passos serem executados, até conectar-se na VM
4. Depois de conectado, sugiro sair da conexão: `CTRL` + `D` e em seguida executar: `ssh $VMNAME`, onde `$VMNAME` é o nome da sua VM criada

---
## Configurações VM
---

#### Passos
1. Rode o comando: `wget https://storage.googleapis.com/appratico-dev/vm-config.sh`
2. Caso não tenha o `wget` instalado, basta aguardar alguns minutos até a VM instalar
3. Rode o comando: `sh vm-config.sh $LOCAL_USER $EMAIL_APPRATICO`, onde `$LOCAL_USER` é o nome do usuário de sua máquina e o `$EMAIL_APPRATICO` é o seu e-mail
    * Exemplo: `sh vm-config.sh andre andre@appratico.com`
    * Use as dicas do tópico abaixo para auxiliar
4. Após finalizar todos os passos de configuração inicial, rode os seguintes comandos:
    * `echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.zshrc`
    * `source ~/.zshrc`

#### Dicas da execução do script
1. Irá solicitar a criação de uma senha (sugiro a mesma do e-mail) e em seguida vai pedir a confirmação da mesma
2. Irá solicitar uma senha para o `id_rsa`, basta pressionar `ENTER` até aparecer a mensagem de `Conteúdo SSH Key`
3. Após isso, siga os passos que o script aponta (copiar o SSH Key exibido no Terminal e adicionar uma nova SSH Key no BitBucket com esse conteúdo)
4. Digite `yes` depois que adicionar a `SSH Key` e aguarde o clone dos repositórios
5. No momento dos clones, vai solicitar a confiança do fingerprint, digite `yes` quando solicitado
6. Após o clone irá instalar o Go, os bin files e o `$PATH`
7. Em seguida, irá instalar o `gcloud` e solicitar uma confirmação, digite `Y` e `ENTER`
8. Após isso, irá informar um link de autenticação do `gcloud`, basta clicar no link, autenticar-se, copiar o código que aparecerá no site e colar no Terminal e pressionar `ENTER`
9. Por último vai configurar o `zsh`, que basicamente vai solicitar a confirmação da instalação (digite `y` e `ENTER`) e digitar a senha do seu usuário (a mesma do Passo 1)

---
## Configurações do VSCode
---

#### Passos
1. Baixe as extensões: `Go` (Microsoft) e `Error Lens` (Alexander)
2. Abra o `Settings` (Engrenagem no canto inferior esquerdo)
3. Pesquise por: `go.formatTool` e altere para `gofmt`
4. Pesquise por: `go.lintOnSave` e altere para `off`
5. Baixe a extensão `Remote - SSH` da Microsoft
6. Abrir o Remote SSH que irá aparecer na lateral do VSCode (abaixo do Debug), e acessar a máquina virtual que será listada
7. Abrir as pastas `src/site` dos projetos para já ficar salvo como favorito no VSCode
8. Pressione os botões `CTRL` + `SHIFT` + `P`
9. Digite: `Terminal: Select Default Profile` ou `Terminal: Select Default Shell`
10. Selecione o `zsh`