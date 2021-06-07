# pool_automation_scripts
Collection of our Cardano stakepool scripts

Very simple script to basic check cardano-node host setup. Our blog post @ https://olympus.rest/blog/basic-node-seurity/ help to propper configure cardano-node host. This script should be run as root on every machine running cardano-node it checks for: 
-ssh configuration (Port,Passwords vs PubKey Login).
-Firewall.
-ipv6.
-sudo vurnability.
-dmesg signiature version.
