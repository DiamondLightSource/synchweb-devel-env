#!/user/bin/env bash
INVENTORY_FILE=.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
KEYFILE=.vagrant/machines/default/virtualbox/private_key
SSH_USER=vagrant

ansible-playbook --inventory-file=$INVENTORY_FILE --private-key=$KEYFILE -u $SSH_USER $@
