Configuration files and scripts for Amazon EC2 instances
========================================================

Base configuration
------------------
- Ubuntu Trusty Tahr base with mainline kernel 3.15.2, amd64 and paravirtualized.
    
- Locale has been repaired, set to en_US.UTF-8. This is reconfigurable across all instances by modifying etc/default/locale in this repository. Changes won't apply until a service restart or instance reboot.
    
- bcache, mdadm and xfsprogs installed. Mdadm sends emails to $EMAIL_RECIPIENT.
    
- Oracle Java 1.7 installed (currently u60).
    
- Postfix and mailutils set up. Postfix server name set to myproject.com.
  
- Git, NodeJS and NPM installed.
    
- srv:srv user created, with $HOME in /srv, which is neither owned by srv, nor
  writable by srv.
  PLEASE CONSIDER THIS IN YOUR NODEJS CODE, AND DO NOT ATTEMPT TO WRITE LOCALLY.
    
- This repo cloned into /, the server application repo cloned into /srv.
  + / is pulled whenever a new version is pushed to git.
  + /srv is pulled whenever a git version with a release-XXX tag higher than the one currently residing is found in the repository. Use make deploy to auto-deploy new releases onto all servers.

- User ubuntu has been assigned a password for sudo, you know which.



Boot configuration
------------------
- See init.d scripts.



Configuration tags
------------------
Init scripts in /etc/init.d/myproject-* take care of automatically configuring the instance for particular uses. These uses can be defined by adding configuration tags to the instance.

Note that all variables defined here are available in both root and regular user shells by pulling in credentials from /.env or /.env-pub, the former being root-only, and not readable by others (it contains AWS login credentials for the CLI tools, possibly other sensitive data).

/.env-pub is a subset excluding sensitive data and is available in nodejs and any shell where you choose to source it.

Recognized tags are:

    Email Recipient
                        Admin email address to send status and incident reports to. If omitted, it defaults to "ec2-reports@myproject.com". Is exported in the instance as env var EMAIL_RECIPIENT.
 
    Email Sender
                        The FROM: header data to use when sending emails from the instance. If omitted, it defaults to the machine's name tag and public hostname as a name, and the instance id @ availability zone .ec2.myproject.com for address, e.g. "Parser (ec2-54-85-95-167.compute-1.amazonaws.com) <i-a5e12586@us-east-1d.ec2.myproject.com>". Is EMAIL_SENDER inside the instance.
 
    Runs
                        Space separated tokens telling the instance how to configure itself and which services it should run. Each token is exported as instance environment variables with the value true, uppercased and prefixed with "RUNS_".
                        
                        Recgnized tokens:
        
        bcache
                        Uses ephemeral storage as a cache device for all EBS volumes other than the root volume. All ephemeral and EBS devices are configured as individually md striped arrays, after which the ephemeral one is used as cache device for the EBS one in write-through mode.
                        
                        Loss of ephemeral data due to crashes and start/stop cycles is repaired automatically on startup.
                        
                        Storage is formatted as XFS and mounted at /mnt.
                        
                        If this tag isn't set, any bcache backing dev orphaned from its cache dev found at boot will be detected and mounted in its "inconsistent" state without the cache device.
                        
                        Note that we cannot convert an old backing device to a regular block device and mount it as-is without using partitions, which would make it really difficult to grow an existing EBS backing arrays.
                        
                        WARNING: You MUST reboot after changing this setting. The reason is that we've stopped using named md arrays as bcache components, since having them in initramfs and booting via fstab would stall the instance after a crash or planned shutdown.
                        
                        Currently, we use dmesg kernel logs to determine the presence of backing and cache devices, and so we need a clean dmesg log or we may make wrong choices. Therefore, the script will exit with an error when not run inside a named runlevel (i.e. during boot).
        
        parser
                        Configures and runs nodejs and nginx on the instance, accepting parse requests on https://parser.myproject.com.
        
        ws
                        Configures and runs a local cluster of nodejs web socket workers (two per detected CPU core), load balanced by nginx and serving sockets on wss://ws.myproject.com. If you upgrade to a larger or smaller instance type with a different number of cores, you must either reboot the instance or run "service myproject-ws-workers restart" inside the instance to update the number of workers.
                        
                        Locally, each worker listens for client traffic on ports 8000 and up (automatically configured
                        with nginx), while listening for node gossip on ports 9091 and up (security groups are only
                        configured to allow ingress inter-dc traffic on 32 ports).
        
        cassandra
                        Configures and runs a cassandra node. Discovery of inter- and intra-regional neighbors is automated, as is creation and/or configuration of the "cassandra-gossip" security group allowing communications between peers. The node will automatically bootstrap and join the ring.
        
        casbackup
                        Backs up the most recent btrfs cassandra data store snapshot to S3 every day.
        
        mongo
                        Basically just a tag for the mongo parser (the spocosy push endpoint). This has currently been
                        set up manually (in the Oregon region), so there's no automagic happening here.
        
        mongobackup
                        Backs up the most recent btrfs mongodb data store snapshot to S3 every day.
        
        mmonit
                        Installs and configures M/Monit, the central adminstration point for each monit hound in the EC2 pound. Every instance has a monit hound configured which will try to connect to and share data with mmonit.myproject.com via SSL on port 44443. You should only ever have one instance tagged for mmonit, or you'll have multiple instances overwriting each other's changes. M/Monit will create the "mmonit" SG in the region of the instance tagged with mmonit, allowing ingress traffic from all public IPs of instances across the cluster and web UI access on port 44443. Additionally, it'll configure ingress traffic on port 2812 for all regional "default" SGs, allowing traffic from itself. Due to limitations in the AWS EC2 CLI tools, however, you'll have to assign the mmonit group to the instance yourself.
        
    Cassandra Seeds
                        *DEPRECATED* and ignored. Seeds are now automatically detected.
                        
                        Comma-delimited list of IPs of cassandra seed nodes to aid snitching across data centers. Should contain at least one node from each data center. No spaces!
                        
                        The IPs here are the public IPs, and you need to make sure that the nodes you want to seed are ALSO told their own IP as that's how it knows it should act as a seed.  Otherwise, it won't be listening.
    
    *
                        Any other tag is exported as an uppercased variable with spaces and dashes replaced by underscores, and prefixed with "INSTANCE_". Avoid special chars if you don't wanna break stuff.



