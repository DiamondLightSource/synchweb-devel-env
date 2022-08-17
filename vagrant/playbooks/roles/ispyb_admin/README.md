# ISPyB Admin Role

This role installs a simplified admin interface for ISPyB using the flask-ispyb-admin repo
IT is not enabled by default.

## Enable Role
To use it, add a line to a playbook file under the roles list.

## Running the application
Once the role is installed:
- vagrant ssh
- source /home/vagrant/flask-ispyb-admin/bin/activate
- cd /var/www/sites/flask-ispyb-admin
- flask run --host 192.168.33.10
