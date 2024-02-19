 #!/bin/sh
tracd --port 8000 --basic-auth="*,/trac_deploy/.htpasswd,trac" /trac_project

