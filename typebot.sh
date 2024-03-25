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

read -p "Link do Builder (ex: typebot.seudominio.com): " builder
echo ""
read -p "Link do Viewer (ex: bot.seudominio.com): " viewer
echo ""
read -p "Link do Storage (ex: storage.seudominio.com): " storage
echo ""
read -p "Seu Email (ex: contato@dominio.com): " email
echo ""
read -p "Senha do seu Email: " senha
echo ""
read -p "SMTP do seu email (ex: smtp.hostinger.com): " smtp
echo ""
read -p "Porta SMTP (ex: 465): " portasmtp
echo ""
read -p "SMTP_SECURE (Se a porta SMTP for 465, digite true, caso contrario,digite false): " SECURE 
echo ""
read -p "Chave secreta de 32 caracteres: " key



#######################################################

echo "Atualizando a VPS + Instalando Docker Compose + Nginx + Certbot"

sleep 3

clear

cd ~
sudo apt update -y
sudo apt upgrade -y

apt install docker-compose -y
sudo apt update

sudo apt install nginx -y
sudo apt update

sudo apt install certbot -y
sudo apt install python3-certbot-nginx -y
sudo apt update

mkdir typebot.io
cd typebot.io

echo "Atualizado/Instalado com Sucesso"

sleep 3

clear

#######################################################

echo "Criando arquivo docker-compose.yml"

sleep 3

cat > docker-compose.yml << EOL
version: '3.3'
services:
  typebot-db:
    image: postgres:13
    restart: always
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=typebot
      - POSTGRES_PASSWORD=typebot
  typebot-builder:
    ports:
      - 3001:3000
    image: baptistearno/typebot-builder:latest
    restart: always
    depends_on:
      - typebot-db
    environment:
      - DATABASE_URL=postgresql://postgres:typebot@typebot-db:5432/typebot
      - NEXTAUTH_URL=https://$builder
      - NEXT_PUBLIC_VIEWER_URL=https://$viewer
      - ENCRYPTION_SECRET=$key
      - DEFAULT_WORKSPACE_PLAN=UNLIMITED
      - ADMIN_EMAIL=$email
      - SMTP_SECURE=$SECURE
      - SMTP_HOST=$smtp
      - SMTP_PORT=$portasmtp
      - SMTP_USERNAME=$email
      - SMTP_PASSWORD=$senha
      - NEXT_PUBLIC_SMTP_FROM='Suporte Typebot' <$email>

      - S3_ACCESS_KEY=minio
      - S3_SECRET_KEY=minio123
      - S3_BUCKET=typebot
      - S3_ENDPOINT=$storage
  typebot-viewer:
    ports:
      - 3002:3000
    image: baptistearno/typebot-viewer:latest
    restart: always
    environment:
      - DATABASE_URL=postgresql://postgres:typebot@typebot-db:5432/typebot
      - NEXTAUTH_URL=https://$builder
      - NEXT_PUBLIC_VIEWER_URL=https://$viewer
      - ENCRYPTION_SECRET=$key
      - DEFAULT_WORKSPACE_PLAN=UNLIMITED
      - S3_ACCESS_KEY=minio
      - S3_SECRET_KEY=minio123
      - S3_BUCKET=typebot
      - S3_ENDPOINT=$storage
  mail:
    image: bytemark/smtp
    restart: always
  minio:
    labels:
      virtual.host: '$storage'
      virtual.port: '9000'
      virtual.tls-email: '$email'
    image: minio/minio
    command: server /data
    ports:
      - '9000:9000'
    environment:
      MINIO_ROOT_USER: minio
      MINIO_ROOT_PASSWORD: minio123
    volumes:
      - s3_data:/data
  createbuckets:
    image: minio/mc
    depends_on:
      - minio
    entrypoint: >
      /bin/sh -c "
      sleep 10;
      /usr/bin/mc config host add minio http://minio:9000 minio minio123;
      /usr/bin/mc mb minio/typebot;
      /usr/bin/mc anonymous set public minio/typebot/public;
      exit 0;
      "
volumes:
  db_data:
  s3_data:
EOL

echo "Criado e configurado com sucesso"

sleep 3

clear

###############################################

echo "Iniciando Container"

sleep 3

docker-compose up -d

echo "Typebot Instaldo... Realizando Proxy Reverso"

sleep 3

clear

###############################################

cd

cat > typebot << EOL
server {

  server_name $builder;

  location / {

    proxy_pass http://127.0.0.1:3001;

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

sudo mv typebot /etc/nginx/sites-available/

sudo ln -s /etc/nginx/sites-available/typebot /etc/nginx/sites-enabled

###############################################

cd

cat > bot << EOL
server {

  server_name $viewer;

  location / {

    proxy_pass http://127.0.0.1:3002;

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

sudo mv bot /etc/nginx/sites-available/

sudo ln -s /etc/nginx/sites-available/bot /etc/nginx/sites-enabled

##################################################

cd

cat > storage << EOL
server {

  server_name $storage;

  location / {

    proxy_pass http://127.0.0.1:9000;

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

sudo mv storage /etc/nginx/sites-available/

sudo ln -s /etc/nginx/sites-available/storage /etc/nginx/sites-enabled

###############################################

sudo certbot --nginx --email $email --redirect --agree-tos -d $builder -d $viewer -d $storage

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
