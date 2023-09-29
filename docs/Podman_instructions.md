# SynchWeb Podman Development Environment

## Introduction
These instructions allow you to generate a Podman based dev environment for SynchWeb.

They create and run a Podman image which runs the SynchWeb backend code
and hosts the frontend web client using httpd. For this to work, the
`SynchWeb\api\config_sample.php` file included in the synchweb repo should be
 copied to `SynchWeb\api\config.php` and updated to include
valid connection string data to an ISPyB database - i.e. via the `$isb` variable. You
are almost definitely better copying a config from another developer if possible.

## Setup
1. Clone this repository: `git clone https://github.com/DiamondLightSource/synchweb-devel-env.git`
1. Run `setup_synchweb.bash` - note, this can take arguments use `-h` for list
1. Edit `config.php` adjusting details as appropriate (at a minimum setting a valid value for `$isb`)
1. Copy the `SynchWeb\api\config_sample.php` file to `SynchWeb\api\config.php` and updated to include valid
 connection string data to an ISPyB database - i.e. via the `$isb` variable. You are almost
  definitely better copying a config from another developer if possible.

This will run a container with the SynchWeb backend running and the frontend built
and hosted on an httpd server.  This will be available at `https://localhost:8082`.
The actual SynchWeb code will be downloaded locally and mounted into the container.

## Running on Windows

The devenv can be set up to run on Windows using WSL (Windows Subsystem for Linux).  Set this up
with the required tools (VS Code is recommended) - guidance 
[here](https://docs.microsoft.com/en-us/windows/wsl/setup/environment).  Once done, start an instance
of the default linux distro (Ubuntu) and follow the `Setup` instructions above.

## Running once Built

Once the container is built then it should not need changing unless you update the container definition, the code is mounted from outside. 
To run the container without building use:

```run_synchweb.bash``` - note this can take multiple arguments run ```run_synchweb.bash --help``` to see what these are.

To run the front end in dev mode, allow hot reloading on code changes run the `run_dev_client.bash` script, the hot reloadable client is hosted on `https://localhost:9000`.

## Troubleshooting

If SynchWeb does not work as expected, review the following:

* Occasionally the podman image fails to build fully - i.e. errors are 
encountered in some of its configuration steps.  This, however, may not 
stop the image from being created.  As a result, the `setup_synchweb.bash` script
forces a full build rebuild each time (using the `--no-cache` option) - so
rerunning may fix the problem.  Keep an eye out for errors in the output, 
anyway.
* One source of error in the above step is a failure to correctly download
some of the required dependencies.  This is usually down to network issues.
For Diamond users, it is recommended that the `sshuttle` vpn set up 
is running.
* Once running, the logs can be accessed with `podman logs synchweb-dev`. The podman container can be accessed by using, 
`podman exec -it synchweb-dev /bin/bash`.
* Sometimes the web client stops working.  Not sure why, but this can usually
be fixed by rebuilding and relinking this.  The `run_dev_client.bash -b -d` can be
used to simplify this process.  For Diamond users, restarting the VPN client
can also help here.
*  See [here](../README.md) for general advice.
