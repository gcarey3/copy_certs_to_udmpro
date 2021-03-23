#!/bin/bash
#
# This script copies our domain cert over to the gateway. We use a wildcard cert so we can have
# different names for the guest portal and main admin page if we want.
#
# Our pub ssh key is in /root/.ssh/authorized_keys on the gateway so we
# don't need a password to run it.
#
# Call this from cron once in a while to make sure your cert stays updated.
# Not too often though as it restarts the whole network container which isn't very desireable.
#
# Be sure to change the location of the cert files and the IP address of the UDM-PRO as needed for your situation.
#

# First copy the full chain (*.montco.net and the intermediate)
/bin/scp /etc/letsencrypt/live/yourdomain.com/fullchain.pem root@192.168.1.1:/mnt/data/unifi-os/unifi-core/config/unifi-core.crt

# Next copy the private key for *.montco.net
/bin/scp /etc/letsencrypt/live/yourdomain.com/privkey.pem root@192.168.1.1:/mnt/data/unifi-os/unifi-core/config/unifi-core.key

# Build a pkcs12 version of the cert that contains the cert, intermediate cert, and the key
# Alias must be set to 'unifi' for this to work
/bin/openssl pkcs12 -export -in /etc/letsencrypt/live/yourdomain.com/fullchain.pem -inkey /etc/letsencrypt/live/yourdomain.com/privkey.pem -out /tmp/keystore.p12 -passout pass:aircontrolenterprise -name 'unifi'

# Put the pkcs12 into keystore file needed by guest portal
# 'aircontrolenterprise' is the default password expected for the keystore
/bin/keytool -importkeystore -destkeystore /tmp/keystore -srckeystore /tmp/keystore.p12 -srcstoretype PKCS12 -srcstorepass aircontrolenterprise -deststorepass aircontrolenterprise -alias unifi

# Copy the keystore to proper dir on UDM-PRO
/bin/scp /tmp/keystore root@192.168.1.1:/mnt/data/unifi-os/unifi/data/keystore

# Cleanup temp files
/bin/rm /tmp/keystore.p12
/bin/rm /tmp/keystore

# Change the ownership of the file to what it should be
/bin/ssh root@192.168.1.1 '/bin/chown 902:902 /mnt/data/unifi-os/unifi/data/keystore'

# Now restart the unifi-os service on the gateway - CAUTION: will disconnect stuff temporarily
/bin/ssh root@192.168.1.1 '/usr/bin/podman restart unifi-os'
