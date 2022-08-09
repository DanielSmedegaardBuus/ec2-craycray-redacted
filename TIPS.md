Updating Cassandra
==================

* Gotta stop it first, and this won't currently work with service cassandra stop, as there's some bug in the Datastax init script which causes the PID file to not point to the started cassandra service when started at boot. Manual service cassandra start seems to not have this issue, but to be safe, get the pid and issue a kill instead.

* We want updates to the configuration files to go through, but we still have to apply our own patches before starting cassandra again, so we need to make sure that cassandra isn't automatically started after being updated. Also, opt "yes" to replacing local configuration with the package maintainer's (issue this as root):

    echo '#!/bin/sh'"$NL2"'exit 101' > /usr/sbin/policy-rc.d
    apt-get update
    apt-get install cassandra
    apt-get clean
    rm -f /usr/sbin/policy-rc.d
    service myproject-configure-cassandra start
    apt-get autoremove
