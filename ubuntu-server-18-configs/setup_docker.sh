echo "WILL SETUP DOCKER"

# https://docs.docker.com/engine/install/ubuntu/

sudo apt-get update

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# post install
sudo groupadd docker

echo "WILL ADD ALL USERS TO docker GROUP"
for ID in $(getent passwd | grep /home | cut -d ':' -f1); 
   do echo $ID; 
   adduser $ID docker; 
done


echo "WILL TEST DOCKER"

docker run hello-world

echo "WILL INSTALL DOCKER COMPOSE WITH pip"

sudo pip3 install docker-compose

docker-compose -v
