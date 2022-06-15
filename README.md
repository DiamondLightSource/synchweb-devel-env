# SynchWeb Virtual Development Environment

## Introduction
This project allows you to generate a vagrant based dev environment.

It uses Ansible for provisioning.

It can generate:
- a machine with apache, php, synchweb and mariadb in one VM.
- a cas authentication VM (via nginx and tomcat).

Self signed certificates are generated for synchweb.example.org and cas.example.org

The test data includes a couple of visits registered to the user:password 'boaty':'mcboatface'


## Setup
* Clone this repository: `git clone https://github.com/DiamondLightSource/synchweb-devel-env.git`
* Set up the development environment (including VMs for SynchWeb and CAS) by following the instructions [here](./docs/SETUP.md)

### Authentication
* Authentication types supported: dummy and cas. 
* Dummy authentication should be used in the standalone case (synchweb vm only)
* SynchWeb can work with CAS but requires the cas VMs to run up as well.
* To change the authentication type, before running vagrant up, edit the template file playbooks/roles/synchweb/vars/main.yml
* To add users to cas, edit the playbooks/roles/cas/files/apereo-cas/etc/cas/config/users.txt file (username::password)
* The user will still need permissions to see sessions in ISPyB so some editing of the ispyb database will be required.
* LDAP is also supported in SynchWeb if you want to test integration with a directory server (see below)
* The CAS auth needs some work. At the moment it relies on a patched source file CAS.php to explicitly set the CAS certificate. The synchweb auth_host variable should match the cas role sitename.

### Hosts
Some features may require your host being able to resolve the hostname of the boxes (e.g. cas logout will redirect to https://cas.example.org/cas/logout) so add an entries in your hosts file as follows:
* 192.168.33.10 synchweb.example.org
* 192.168.33.12 cas.example.org

#### LDAP
SynchWeb can be configured to talk to an LDAP server.
An LDAP role is not currently included here.
However you can get one from [here](https://github.com/rgl/ldap-vagrant.git)
Change the SynchWeb config.php settings to talk to the ldap server e.g. ldap://192.168.33.xx (see ldap Vagrant box for ip addr).
You can add users (e.g. boaty) into the LDAP provision.sh script. Do this before bringing the box up.

## Reprovision
* If you need to re-run the provisioning (after a change) run `vagrant provision <boxname>` 

## Cleanup
* cd into the vagrant/<os> dir and run vagrant destroy
* This should cleanup and delete the vagrant box

## Notes
* We don't have many template files so some are stored under roles/<role>/files
* Could be moved to separate templates folder at a later date...
* There are lots of sql files (under roles/ispyb_db/files) that can be imported into the db - they will need checking to make sure you get what you need.
* The debian standalone has some issue with the nfs role - it requires a restart for it to mount properly. May be a service order issue, if in doubt try re-provisioning (vagrant up --provision).

## Web based Admin VM
* There is also a simple web based admin tool under centos_ispyb_admin/
* This is a flask tool that pulls code from https://github.com/drnasmith/flask_ispyb_admin
* To run the admin VM; follow instructions in the roles/ispyb_admin/README.
* Once provisioned, vagrant ssh, source /home/vagrant/env/bin/activate, then run: flask run --host 192.168.33.10 (as an example - ip addresses may need to be changed based on your setup)
