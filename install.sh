HMDA_MODULE="hmda"
GRASSHOPPER_MODULE="grasshopper"
CFBP_DEPLOY_REPO=https://github.com/ilapchuk/cfpb-deploy.git
SBT_BUILD_FOLDER=cfpb-deploy

module=$2
virtual_switch=$1

install_boot2docker() 
{
	if [[ -z "$virtual_switch" ]]; then
		echo "Usage: install.sh HYPER_V_NETWORK_SWITCH [hmda|grasshopper]"
		exit 1
	fi

	if [[ -z "$module" ]]; then
		module=$HMDA_MODULE
	elif [[ "$module" != $HMDA_MODULE ]]  && [[ "$module" != $GRASSHOPPER_MODULE ]]; then 
		echo "Incorrect module name. The correct values are $GRASSHOPPER_MODULE and $HMDA_MODULE"
		exit 1
	fi

	vm_check=`docker-machine ls|grep "$module"`

	if [[ -n "$vm_check" ]]; then
		echo "VM for $module already exists"
		exit 1
	fi	

	echo "Starting creation of new VM $module-vm"
	docker-machine create -d hyperv --hyperv-virtual-switch "$virtual_switch" "$module"-vm

	if [[ "$?" -ne 0 ]]; then
		echo "Cannot start book2docker VM"	
		exit 1
	fi	
	echo "VM $module-vm is successfully created"
	return 0
}

setup_boot2docker() {

	echo "Establishing connection with $module-vm"
	
	docker-machine ssh $module-vm "git clone $CFBP_DEPLOY_REPO;cd ~/$SBT_BUILD_FOLDER; ./setup.sh $module"

	return 0	
}

install_boot2docker
setup_boot2docker

exit 0