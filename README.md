# Manual & Automatic Deployment Guide for CFPB Grasshopper and HDMA (Windows 10)

Prequisites
------------------------
Please keep in mind that this guide is in its in

1. Download docker tool for windows https://docs.docker.com/docker-for-windows/
2. Enable Hyper-V on your laptop (As alternative you can use virtual box)
3. In Hyper-V Manager establish new virtual switch by following next insruction https://docs.docker.com/machine/drivers/hyper-v/. Virtual Switch name later will be used for VM creation.
4. Install terminal with bash

## Manual Procedure
---------------------------

Common steps
-------------------------
Create new docker machine using next command:

	docker-machine create -d hyperv --hyperv-virtual-switch "NAME_OF_YOUR_VIRTUAL_SWITCH" YOUR_VM_NAME
	
Verify the status of your docker virtual machine by running command:

	docker-machine ls --filter name=YOUR_VM_NAME

The state field must be set to RUNNING state. Connect to your VM by typying:

	docker-machine ssh YOUR_VM_NAME

In order to be able to execute docker-compose scripts, you need to install docker-compose on your VM. Please execute next installation instruction:

	tce-load -wi python && curl https://bootstrap.pypa.io/get-pip.py | \
	  sudo python - && sudo pip install -U docker-compose

You also need to setup sbt container based on custom image. Clone and build sbt image:

	cd ~ && git clone https://github.com/ilapchuk/cfpb-deploy.git && cd cfpb-deploy && \
	docker build -t sbt-build .

### Setup of hmda platform:
---------------------------

1. Create hmda folder for project:

		cd ~ && mkdir -p hmda && sudo chmod -R a+w hmda && cd hmda

2. Clone hmda related services from github:

		hmda core module(includes api, parser): 
			git clone https://github.com/cfpb/hmda-platform.git
		hmda authentication module: 
			git clone https://github.com/cfpb/hmda-platform-auth.git
		hmda ui: 
			git clone https://github.com/cfpb/hmda-platform-ui.git
		
3. Fix the version of in-memory-persistence library in file ~/hmda/hmda-platform/project/Version.scala from 

	  val inMemoryPersistence = "1.3.7"
		to
	  val inMemoryPersistence = "1.3.9"

4. You can build hmda platform using sbt-build image:

		cd ~/hmda/hmda-platform && docker run -v `pwd`:/io -w /io sbt-build clean assembly

5. Currently docker-compose script mount project dist folder as internal volume for docker container. Subsequently, external dist folder overlaps with internal dist folder that contains build artifact. In order to fix this problem, remove volume mounting for ui module in ~/hmda/hmda-platform/docker-compose.yml file. Next two lines must be removed:

         volumes:
	      - ../hmda-platform-ui/dist:/usr/src/app/dist

6. docker-compose command will bring application up:

		cd ~/hmda/hmda-platform && docker-compose up

### Setup of grasshopper platform:
---------------------------

1. Create grasshopper folder for project:

		cd ~ && mkdir -p grasshopper && sudo chmod -R a+w grasshopper && cd grasshopper

2. Clone grasshopper related services from github:

		grasshopper core module: 
			git clone https://github.com/cfpb/grasshopper.git
		grasshopper loader: 
			git clone https://github.com/cfpb/grasshopper-loader.git
		grasshopper retriever: 
			git clone https://github.com/cfpb/grasshopper-retriever.git
		grasshopper parser: 
			git clone https://github.com/cfpb/grasshopper-parser
		grasshopper ui: 
			git clone https://github.com/cfpb/grasshopper-ui.git

3. You can build grasshopper using sbt-build image:

		cd ~/grasshopper/grasshopper && docker run -v `pwd`:/io -w /io sbt-build clean assembly

4. Currently docker-compose script mount project dist folder as internal volume for docker container. Subsequently, external dist folder overlaps with internal dist folder that contains build artifact. Remove volume mounting for ui module in ~/grasshopper/grasshopper/docker-compose.yml file. Next two lines must be removed:

		  volumes:
			- ../grasshopper-ui/dist:/usr/src/app/dist/

5. Start grasshopper platform: 

		cd ~/grasshopper/grasshopper && docker-compose up

## Automated Procedure
---------------------------

Clone project cfpp-deploy to your local PC: 

		git clone https://github.com/ilapchuk/cfpb-deploy.git

Go to projects folder and find install.sh script. This script provides capability for automatic creation and setup of VMs for hmda and grasshopper projects.
If you want to setup hmda VM run next command:

		install.sh YOUR_VIRTUAL_CIRCUIT_NAME hmda

if you want to setup grasshopper VM run next command:

		install.sh YOUR_VIRTUAL_CIRCUIT_NAME grasshopper

	
