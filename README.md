# pool_automation_scripts
Collection of our Cardano stakepool scripts

## pool-check.sh 
This is a very simple script to basic check cardano-node host setup.

This script should be run as root on every machine running cardano-node it checks for: 
* ssh configuration (Port,Passwords vs PubKey Login).
* Firewall.
* ipv6.
* sudo vurnability.
* dmesg signiature version.

![pool-check](https://olympus.rest/media/django-summernote/2021-06-07/0525d0b1-fc56-4db2-b85b-ff12cbfc4f28.png)
 

 Our blog post @ https://olympus.rest/blog/basic-node-seurity/ help to propper configure cardano-node host.
 
 
## pool-watcher.sh 
This script launch tmux session with 4 separate panes and open ssh connection predefined  in .bashrc - 2 connection to BP for gLiveView and nload, and 1 connection to each of relays executing gLiveViewscript.

![pool-watcher](https://olympus.rest/media/django-summernote/2021-06-08/401e53f6-2820-42be-8e07-363ce99059b7.png)

add aliases to .bashrc
```bash
alias node1="ssh -t -i $HOME/.ssh/node1 USER@node1 -p [PORT] '/opt/cardano/cnode/scripts/gLiveView.sh'"
alias node2="ssh -t -i $HOME/.ssh/node2 USER@node2 -p [PORT] '/opt/cardano/cnode/scripts/gLiveView.sh'"
alias bp="ssh -t -i $HOME/.ssh/bp USER@bp -p [PORT] '/opt/cardano/cnode/scripts/gLiveView.sh'"
alias nbp="ssh -t -i $HOME/.ssh/bp USER@bp -p [PORT] '/usr/bin/nload'"
```
