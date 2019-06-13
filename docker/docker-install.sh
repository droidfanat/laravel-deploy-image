#!/bin/bash
	echo '
    Script only works if sudo caches the password for a few minutes
    '
	sudo true

	echo '
    Install docker
    '
	curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
	sudo sh /tmp/get-docker.sh
	
	#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	echo '
    Update repository
    '
	sudo apt update > /dev/null 2>&1

	echo '
    Docker installation
    '
	sudo apt -y install docker-ce > /dev/null 2>&1
	sudo groupadd docker || true
	sudo usermod -aG docker "$USER"
	sudo systemctl daemon-reload
	sudo systemctl enable docker
	sudo systemctl start docker

	echo '
    Install docker-compose
    '
	COMPOSE_VERSION=$(git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | tail -n 1)
	sudo sh -c "curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose"
	sudo chmod +x /usr/local/bin/docker-compose
	chown :docker /usr/local/bin/docker-compose 
	
    echo '
    Install docker-compose autocomplite
    '
	sudo sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
	
    echo '
    Install DockStation
    '
	DOCKSTATION_VERSION=$(git ls-remote https://github.com/DockStation/dockstation | grep refs/tags | grep -oP "[0-9]+\.[0-9]+\.[0-9]+$" | tail -1)
	curl -L "https://github.com/DockStation/dockstation/releases/download/v${DOCKSTATION_VERSION}/dockstation_${DOCKSTATION_VERSION}_amd64.deb" > /tmp/dockstation.deb
	sudo dpkg -i /tmp/dockstation.deb
	sudo apt install -y --fix-broken  /tmp/dockstation.deb
	
    echo'
    Please, reboot system
    '