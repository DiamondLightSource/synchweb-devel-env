# SynchWeb Podman Development Environment

## Introduction
These instructions allow you to generate a Podman based dev environment for SynchWeb.

They create and run a Podman image which runs the SynchWeb backend code
and hosts the frontend web client using httpd. For this to work, the
`config.php` file included in this repo must be updated to include
valid connection string data to an ISPyB database - i.e. via the `$isb` variable. 


## Setup
1. Clone this repository: `git clone https://github.com/DiamondLightSource/synchweb-devel-env.git`
1. Edit `config.php` adjusting details as appropriate (at a minimum setting a valid value for `$isb`)
1. Run `setup.bash` - note, this can take two input args:
``` setup.bash <image-name> <run-initial-setup=1,0>```.
If no args are specified, an image called `synchweb-dev` is built and run, 
and the full set up is done (including copying the config files to
override the repository defaults).

This will run a container with the SynchWeb backend running and the frontend built and hosted on an httpd server.  This will be available at `http://localhost:8082`.

## Troubleshooting

If SynchWeb does not work as expected, review the following:

* Occasionally the podman image fails to build fully - i.e. errors are 
encountered in some of its configuration steps.  This, however, may not 
stop the image from being created.  As a result, the `setup.bash` script
forces a full build rebuild each time (using the `--no-cache` option) - so
rerunning may fix the problem.  Keep an eye out for errors in the output, 
anyway.
* One source of error in the above step is a failure to correctly download
some of the required dependencies.  This is usually down to network issues.
For Diamond users, it is recommended that the `sshuttle` vpn set up 
is running.
* Once running, the podman container can be accessed by using, 
`podman exec -it synchweb-dev /bin/bash`.  From here, check the required
php and httpd processes are running and check the logs under
`/var/log/httpd`.
*  See [here](../README.md) for general advice.
