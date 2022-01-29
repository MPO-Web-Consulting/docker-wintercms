#!/bin/bash
set -e

# original entrypoint script
docker-wn-entrypoint

# run certbot setup one time
CERTBOT_MARK_FILE=.certbot_did_initialise
if [[ ! -f "$CERTBOT_MARK_FILE" ]]; then
	echo "setting up certbot to run later (in 5 minutes)..."
	# setup a timer to run certbot setup after a given time
	# this should allow the apache server to get up and running
	# before responding to the http-01 challenge
	# it this fails then it will have to be set up manually
	certbot --apache | at now + 5 min

	# drop a file to indicate that certbot did run once and next start (if persistent data) don't run again
	touch $CERTBOT_MARK_FILE
fi

exec "$@"
