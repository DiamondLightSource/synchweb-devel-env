# Development Environment Setup

## Installation

This document will get updated if anything changes in terms of software used or if a particular version changes. The following are the setup procedures that needs to be followed to have the development environment running without issues.

- Download and install a virtual box for your machine [here](https://www.vagrantup.com/downloads.html)

- Download vagrant for your machine [here](https://www.vagrantup.com/downloads)

- Install vagrant for your machine [here](https://www.vagrantup.com/docs/installation)

- Install `pip`, a python package manager for your machine. Add it to your system path so pip is a recognized command

- Install Ansible via `pip` by running the following command: `pip install --user ansible`

- Clone the repository to a folder on your development machine
  - `git clone https://github.com/DiamondLightSource/synchweb-devel-env.git` for git https users
  - `git clone git@github.com:DiamondLightSource/synchweb-devel-env.git` for ssh users

- Build and launch the virtual machine.
Depending on which virtual machine you want to build for, you would need to `cd` into the correct machine folder in the cloned repository. Currently we are building a virtual machine using `centos 7`; so you would have to cd into the `centos` directory of your machine and start the virtual machine.

For centos 7, you need to:
`cd {path_to_synchweb_devel_env}/vagrant/centos` and then type
`vagrant up`

This would build the centos machine and install all the required packages both for the frontend and backend apps.

- Open app on a browser by visiting [https://192.168.33.10](https://192.168.33.10) to see the app.

- Clone the github repository of the synchweb app to your local machine and take note of the path where it is installed
  - for ssh: `git clone git@github.com:DiamondLightSource/SynchWeb.git`
  - for https: `git clone https://github.com/DiamondLightSource/SynchWeb.git`

## Synching local files & folders for Centos

After going through all the installation and set up process, you would need to be able to have changes in your local files and folders reflect on the browser.

- SSH into the synchweb virtual machine by typing:
`vagrant ssh synchweb`

- change permission to root user by typing:
`su` or `sudo i`

- Ensure you are running the up to date kernel for centos 7
`yum update kernel*`
then 
`reboot`

- Create a directory to mount the virtual box guest addition .iso file
`mkdir /media/virtualBoxGuestAdditions`

- mount this folder to the `cdrom` path of the virtual machine
`mount -r /dev/cdrom /media/virtualBoxGuestAdditions`

- Shutdown the virtual machine with `vagrant halt`

- Go to the virtualBox application

- Click on the synchweb machine and go to its settings dialog box

- Click on storage menu and then on the "+" icon beside the `Controller IDE` list

- Select the `VBoxGuestAdditions.iso` file to add it as a storage device, save changes and restart the virtual machine with `vagrant up`

- SSH into the synchweb machine again with `su` or `sudo i`

- Install the EPEL repo for Centos 7 and some packages which are needed
`rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm`
`yum install gcc kernel-devel kernel-headers dkms make bzip2 perl`

- Add the KERN environment variable
`KERN_DIR=/usr/src/kernels/`uname -r`

- Export the environment variable
`export KERN_DIR`

- Change directory to the virtual box guest addition folder
`cd /media/VirtualBoxGuestAdditions`

- Install the virtual box guest addition package
`./VBoxLinuxAdditions.run`
Output will look like this:

```bash
Verifying archive integrity... All good.
Uncompressing VirtualBox 6.0.13 Guest Additions for Linux........
VirtualBox Guest Additions installer
Removing installed version 6.0.13 of VirtualBox Guest Additions...
Copying additional installer modules ...
Installing additional modules ...
VirtualBox Guest Additions: Building the VirtualBox Guest Additions kernel modules.  This may take a while.
VirtualBox Guest Additions: Running kernel modules will not be replaced until the system is restarted
VirtualBox Guest Additions: Starting.
```

- Reboot virtual machine system
`reboot`

- Uncomment the `synchweb.vm.synced_folder "src/", "/var/www/sites/"` line of code in the `{path_to_synchweb}/vagrant/centos/Vagrantfile` to allow folder/files sync when vagrant is restarted
  - The `src/` path of that line should match the path where you cloned the synchweb repository earlier. If it is in the `path_to_synchweb}/vagrant/centos/src` folder then you can leave it as it is.

- Restart the virtual machine using the command `vagrant reload` to enable virtual box sync the local synchweb files with the guest machine.
- To stop the vagrant machine from running just type `vagrant suspend`

## Connecting to the database

To connect to the database with a database client, you would need to create a new port forwarding entry for the virtual machine on virtual box.

- Select the Synchweb machine in virtual box
- Click on the `settings` menu, a dialog box will appear
- Select the `Network` tab and ensure you are on the `Adapter 1` tab
- Click on port forwarding, a new dialog box will appear
- Click on the "+" icon on the screen and then enter the required values for the database port
  - name can be anything
  - protocol: `TCP`
  - Host IP: `127.0.0.1`
  - Host Port: `3306`
  - Guest IP: can be left blank
  - Guest Port: `3306`
- Click out of the table and then save all the settings
- Connect to the database using a client with the following credentials:
  - Database: `ispyb`
  - User: `ispyb`
  - Port: `3306`
  - password: `integration`

## Creating a user with privileges to access admin routes

- Go to the `{path_to_synchweb}/playbooks/roles/cas/files/apereo-cas/etc/cas/config/users.txt` file and create an entry with the following format like so `{username}::{password}`
- Go to the database client
  - insert a new entry in the `Person` table. Ensure that the `login` field matches the `{username}` you entered in the `users.txt` file
  - Insert a new entry in the `UserGroup_has_Person` table with the corresponding `id` of the needed `UserGroup` and `id` of the newly `Person` you created
- Run `vagrant reload cas --provision` to re-provision the cas machine on vagrant. This will reload and allow the newly created user to be able to login with the correct permissions
- You can visit [https://192.168.33.12/cas/login](https://192.168.33.12/cas/login) and enter the newly created credentials to ensure that it was added successfully
- You can then use the credential to login on the synchweb app.
