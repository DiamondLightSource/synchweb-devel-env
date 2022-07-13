# SynchWeb Development Environment

## Introduction
This project allows you to generate a dev environment for SynchWeb - using either Vagrant or Podman.

* Instructions for setting up using Podman are available [here](./docs/Podman_instructions.md).
* Instructions for setting up using Vagrant are available [here](./docs/Vagrant_instructions.md).

Note, setting things up in a container via Podman is signficantly simpler, more lightweight and requires less external dependencies
(e.g. use of VirtualBox), so is the encouraged route.


## Troubleshooting

If errors are encountered along the way, it can be helpful to use `postman` to 
isolate and diagnose these.  This allows individual http requests to be created 
and sent - which can be particularly helpful when invoking the backend API.  If 
errors are being returned from the PHP code, `print_r()` can be added to the 
related code to return print statements in the http response.
