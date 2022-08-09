NGINX site configurations
=========================

The scripts in here are processed by the init.d scripts responsible for them, and shouldn't be treated as actual site configurations that could just be symlinked into sites-available and then eaten by nginx.

E.g. the balancer for web socket workers has all upstream workers injected after detecting how many cores are installed on the given instance, and configuring forever to launch a specific number of workers.

In other words, treat these as templates, and consult the init.d scripts when you want to make changes.
