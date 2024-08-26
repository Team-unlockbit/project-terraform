#!/bin/bash
# Docker 설치
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# sudo usermod -aG docker ubuntu
sudo usermod -aG docker $USER

# 최신 버전 Docker Compose 설치
sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# GitLab 컨테이너 세팅
sudo mkdir -p /data/gitlab && cd /data/gitlab
sudo mkdir data logs config
chown -R $USER:$USER /data/gitlab
cat <<EOF > docker-compose.yml
version: '3.9'

services:
  gitlab:
    image: 'gitlab/gitlab-ee:16.1.0-ee.0'
    container_name: gitlab
    restart: always
    hostname: '${gitlab_ip}'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://${gitlab_ip}'
        gitlab_rails['gitlab_shell_ssh_port'] = 8022
        # Add any other gitlab.rb configuration here, each on its own line
      TZ: 'Asia/Seoul'
    ports:
      - '80:80'
      - '443:443'
      - '8022:22'
    volumes:
      - './config:/etc/gitlab'
      - './logs:/var/log/gitlab'
      - './data:/var/opt/gitlab'
EOF

# Gitlab runner 세팅
mkdir -p /data/gitlab-runner/config && cd /data/gitlab-runner
chown -R $USER:$USER /data/gitlab-runner
cat <<EOF > docker-compose.yml
version: '3.9'
services:
  gitlab-runner:
    image: 'gitlab/gitlab-runner:v16.0.2'
    container_name: gitlab-runner
    restart: always
    volumes:
      - './config:/etc/gitlab-runner'
      - '/var/run/docker.sock:/var/run/docker.sock'
EOF

# Gitlab & runner docker-compose up
cd /data/gitlab
cat <<EOF > sh.sh
#!/bin/bash
docker-compose up -d

#while true; do
#    if [ -s passwd.passwd ]; then
#        break
#    fi
#    docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password >> passwd.passwd
#    echo "왜 안되?" >> dhodksehl.txt
#    sleep 1
#done
cd /data/gitlab-runner
docker-compose up -d

cd /data/gitlab
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password >> passwd.passwd
EOF

sh sh.sh
