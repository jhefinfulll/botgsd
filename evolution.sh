#######################################################

  echo "\n\n"
  echo "${GREEN}";
  echo " █████████      ███████         █████████";
  echo "       ███      ███    ██       ███      ";
  echo "     ███        ███    ███      ███      ";
  echo "   ███          ███    ███      ███  ████";
  echo " ███            ███    ██       ███    ██";
  echo " █████████      ███████         █████████";
  echo "\n";
  echo "ESSE MATERIAL FAZ PARTE DA COMUNIDADE ZDG";
  echo "\n";
  echo "Compartilhar, vender ou fornecer essa solução";
  echo "sem autorização é crime previsto no artigo 184";
  echo "do código penal que descreve a conduta criminosa";
  echo "de infringir os direitos autorais da ZDG.";
  echo "\n";
  echo "PIRATEAR ESSA SOLUÇÃO É CRIME.";
  echo "\n";
  echo " © COMUNIDADE ZDG - comunidadezdg.com.br";
  echo "${NC}";
  echo "\n"

#######################################################

read -p "Link da API (ex: evolutionapi.seudominio.com): " evolution
echo ""
read -p "Seu Email (ex: contato@dominio.com): " email
echo ""

#######################################################

echo "Atualizando a VPS + Instalando Evolution API"

sleep 3

clear

sudo apt update -y
sudo apt upgrade -y

apt install git -y
sudo apt update

cd ~
git clone https://github.com/EvolutionAPI/evolution-api.git
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g npm@latest
sudo npm install -g pm2@latest

sudo apt update -y
sudo apt upgrade -y

echo "Atualizado/Instalado com Sucesso"

sleep 3

clear

#######################################################

echo "Instalando a API"

sleep 3

cd evolution-api
# git reset --hard HEAD
npm install
mv /root/evolution-api/src/dev-env.yml /root/evolution-api/src/env.yml
pm2 start 'npm run start:prod' --name evolutionapi
pm2 startup
pm2 save --force

sleep 3

clear

###############################################

cd

cat > evolutionapi << EOL
server {

  server_name $evolution;

  location / {

    proxy_pass http://127.0.0.1:8080;

    proxy_http_version 1.1;

    proxy_set_header Upgrade \$http_upgrade;

    proxy_set_header Connection 'upgrade';

    proxy_set_header Host \$host;

    proxy_set_header X-Real-IP \$remote_addr;

    proxy_set_header X-Forwarded-Proto \$scheme;

    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    
    proxy_cache_bypass \$http_upgrade;

	  }

  }
EOL

###############################################

sudo mv evolutionapi /etc/nginx/sites-available/

sudo ln -s /etc/nginx/sites-available/evolutionapi /etc/nginx/sites-enabled

###############################################

sudo certbot --nginx --email $email --redirect --agree-tos -d $evolution

###############################################

  echo "\n\n"

  echo "${GREEN}";
  echo " █████████      ███████         █████████\n";
  echo "       ███      ███    ██       ███      \n";
  echo "     ███        ███    ███      ███      \n";
  echo "   ███          ███    ███      ███  ████\n";
  echo " ███            ███    ██       ███    ██\n";
  echo " █████████      ███████         █████████\n";
  echo "\n";
  echo "ESSE MATERIAL FAZ PARTE DA COMUNIDADE ZDG\n";
  echo "\n";
  echo "Compartilhar, vender ou fornecer essa solução\n";
  echo "sem autorização é crime previsto no artigo 184\n";
  echo "do código penal que descreve a conduta criminosa\n";
  echo "de infringir os direitos autorais da ZDG.\n";
  echo "\n";
  echo "PIRATEAR ESSA SOLUÇÃO É CRIME.\n";
  echo "\n";
  echo " © COMUNIDADE ZDG - comunidadezdg.com.br\n";
  echo "${NC}";

  echo "\n"
