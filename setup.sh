
HMDA_MODULE="hmda"
GRASSHOPPER_MODULE="grasshopper"

module=$1

common_setup() {
	tce-load -wi python && curl https://bootstrap.pypa.io/get-pip.py | \
	  sudo python - && sudo pip install -U docker-compose

	if [[ "$?" -ne 0 ]]; then
		echo "Cannot install docker-compose"	
		exit 1
	fi	

	if [[ "$module" = $GRASSHOPPER_MODULE ]]; then
		sed -i 's/0.13.13/0.13.8/g' Dockerfile
	fi

	docker build -t sbt-build .
	if [[ "$?" -ne 0 ]]; then
		echo "Cannot create image of sbt-build"	
		exit 1
	fi	
}

setup_hmda() {
	common_setup
	cd ~ && mkdir -p hmda && sudo chmod -R a+w hmda && cd hmda

	git clone https://github.com/cfpb/hmda-platform.git
	git clone https://github.com/cfpb/hmda-platform-auth.git
	git clone https://github.com/cfpb/hmda-platform-ui.git

	cd ~/hmda/hmda-platform && sed -i 's/inMemoryPersistence = "1.3.7"/inMemoryPersistence = "1.3.9"/g' project/Version.scala

	docker run -v `pwd`:/io -w /io sbt-build clean assembly

	sed -i '/ui:/{n;n;n;n;n;n;n;n;N;d;}' docker-compose.yml

	docker-compose up
}

setup_grasshopper() {
	common_setup
	cd ~ && mkdir -p grasshopper && sudo chmod -R a+w grasshopper && cd grasshopper
	
	git clone https://github.com/cfpb/grasshopper.git
	git clone https://github.com/cfpb/grasshopper-loader.git
	git clone https://github.com/cfpb/grasshopper-retriever.git
	git clone https://github.com/cfpb/grasshopper-parser
	git clone https://github.com/cfpb/grasshopper-ui.git

	cd ~/grasshopper/grasshopper && docker run -v `pwd`:/io -w /io sbt-build clean assembly

	sed -i '/ui:/{n;n;n;n;n;n;N;d;}' docker-compose.yml

	docker-compose up
}

if [[ "$module" = $HMDA_MODULE ]]; then
        exit 0
elif [[ "$module" = $GRASSHOPPER_MODULE ]]; then
	setup_grasshopper;	
else 
	echo "Usage: setup.sh [hmda|grasshopper]"
	exit 1	
fi

exit 0