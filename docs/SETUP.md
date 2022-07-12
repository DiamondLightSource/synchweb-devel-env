# Development Environment Setup

## Installation

This document will get updated if anything changes in terms of software used or if a particular version changes. The following are the setup procedures that needs to be followed to have the development environment running without issues.

1. Download and install VirtualBox for your machine [here](https://www.virtualbox.org/wiki/Downloads).  Note, full instructions for Fedora available [here](https://computingforgeeks.com/how-to-install-virtualbox-on-fedora-linux/).

1. Download and install vagrant for your machine [here](https://www.vagrantup.com/downloads)

1. If necessary, install `pip`, a python package manager for your machine [here](https://pip.pypa.io/en/stable/installation/). Add it to your system path so pip is a recognized command.

1. Install Ansible via `pip` by running the following command: `pip install --user ansible`

1. Clone the repository to a folder on your development machine
  - `git clone https://github.com/DiamondLightSource/synchweb-devel-env.git` for git https users
  - `git clone git@github.com:DiamondLightSource/synchweb-devel-env.git` for ssh users

6. Build and launch the virtual machine.
Depending on which virtual machine you want to build for, you would need to `cd` into the correct machine 
folder in the cloned repository. Currently we are building a virtual machine using `centos 7`; so you would
have to cd into the `centos` directory of your machine and start the virtual machine. For centos 7, you need to:
`cd {path_to_synchweb_devel_env}/vagrant/centos` and then type
`vagrant up`
. This would build the centos machine and install all the required packages both for the frontend and backend apps.  **Note**, if this fails due to an invalid IP address, edit the Vagrantfile and adjust both IP addresses to fall within the valid range (which will be listed in the error message). In this situation,
also update the IP addresses in the files, `playbooks/roles/cas/files/system/etc/hosts` and `playbooks/roles/synchweb/files/system/etc/hosts`. Once done, reprovision the VMs via `vagrant provision`.

1. Open app on a browser by visiting [https://192.168.33.10](https://192.168.33.10) (or the adjusted IP address) to see the app - this should display with the ISPyB logo.

1. Clone the github repository of the SynchWeb app to your local machine and take note of the 
path where it is installed
  - for ssh: `git clone git@github.com:DiamondLightSource/SynchWeb.git`
  - for https: `git clone https://github.com/DiamondLightSource/SynchWeb.git`

## Synching local files & folders for Centos - using VirtualBox Guest Additions

The following instructions enable use of `rsync` - to allow your local SynchWeb code to be sync'd 
with the above synchweb VM - i.e. allowing development changes to be picked up.  Note, for these to 
work, the client code needs to be built locally before sync'ing - instructions [here](https://github.com/DiamondLightSource/SynchWeb) 
(otherwise accessing the app in a browser will show up as 'Forbidden').
These instructions are based on details [here](https://www.if-not-true-then-false.com/2010/install-virtualbox-guest-additions-on-fedora-centos-red-hat-rhel/).

Note, there is a vagrant plugin available to automatically install the Guest Additions, however this does 
not work on the Fedora VM specified here. If using a different VM, this can be installed via, 
`vagrant plugin install vagrant-vbguest`. 

1. SSH into the synchweb virtual machine:
`vagrant ssh synchweb`

1. change permission to root user:
`su` or `sudo -i`

1. Create a directory to mount the virtual box guest addition .iso file
`mkdir /media/virtualBoxGuestAdditions`

1. Ensure you are running the up to date kernel for centos 7
`yum update kernel*`
then 
`shutdown` (note, the VM needs to be shutdown to attach an optical drive).

1. Download the `VBoxGuestAdditions.iso` from [here](https://www.virtualbox.org/wiki/Testbuilds)

1. Go to the VirtualBox application

1. Click on the synchweb machine and go to its settings dialog box

1. Click on storage menu and then on the "+" icon beside the `Controller IDE` list (to add an optical drive)

1. Select the `VBoxGuestAdditions.iso` file downloaded earlier to add it as a storage device, save changes and restart the virtual machine with `vagrant up`

1. SSH into the synchweb machine again and change to root via `su` or `sudo -i`

1. Install the EPEL repo for Centos 7 and some packages which are needed

`rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm`

`yum install gcc kernel-devel kernel-headers dkms make bzip2 perl`

12. Add the KERN environment variable
```KERN_DIR=/usr/src/kernels/`uname -r` ```

1. Export the environment variable
`export KERN_DIR`

1. Mount the `virtualBoxGuestAdditions` folder to the `cdrom` path of the virtual machine - to gain access to the attached iso file
`mount -r /dev/cdrom /media/virtualBoxGuestAdditions`

1. Change directory to the virtual box guest addition folder
`cd /media/VirtualBoxGuestAdditions`

1. Install the virtual box guest addition package
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

17. Shutdown the virtual machine
`shutdown`

1. Uncomment the `synchweb.vm.synced_folder "src/", "/var/www/sites/synchweb"` line of code in the `{path_to_synchweb-devel-env}/vagrant/centos/Vagrantfile` to allow folder/files sync when vagrant is restarted
  - The `src/` path of that line should be changed to point to the location of the SynchWeb repository
  cloned earlier (relative paths are ok).

19. Restart the virtual machine using the command `vagrant reload` (outside of the VM) to enable the local synchweb files to be sync'd with the guest machine
1. To stop the vagrant machine from running just type `vagrant suspend`

## Connecting to the database

To connect to the database with a database client, you would need to create a new port forwarding entry for the virtual machine on VirtualBox.

- Select the synchweb machine in VirtualBox
- Click on the `settings` menu, a dialog box will appear
- Select the `Network` tab and ensure you are on the `Adapter 1` tab
- Expand '`Advanced` and click on `Port Forwarding`.  A new dialog box will appear.
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
  - Insert a new entry in the `UserGroup_has_Person` table with the corresponding `id` of the needed `UserGroup` and `id` of the newly `Person` you created.
  - Run `vagrant reload cas --provision` to re-provision the cas machine on vagrant. This will reload and allow the newly created user to be able to login with the correct permissions
- You can visit [https://192.168.33.12/cas/login](https://192.168.33.12/cas/login) (or whatever IP address you set earlier) and enter the newly created credentials to ensure that it was added successfully
- You can then use the credential to login on the synchweb app.

## Troubleshooting

If errors are encountered along the way, it can be helpful to use `postman` to 
isolate and diagnose these.  This allows individual http requests to be created 
and sent - which can be particularly helpful when invoking the backend API.  If 
errors are being returned from the PHP code, `print_r()` can be added to the 
related code to return print statements in the http response.

Note, the vagrant VM provisioning can sometimes not fully complete successfully - so 
be careful to check for errors.  Sometimes these errors only occur on the first 
run of `vagrant up`, but can still impact the subsequent use of the VM - i.e. a `vagrant provision` is required to force things to fully rerun.

When running the webpack server to host the frontend client, be careful to 
ensure that the `env.proxy.target` is set correctly - pointing at the synchweb 
IP address configured above - including correct protocol (i.e. `http` or `https`).