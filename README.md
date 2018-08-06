WAVI Blockchain Explorer - 1.7.0
================

An open source block explorer written in node.js.

### Requires

*  node.js >= 0.10.28
*  mongodb 2.6.x
*  *coind

### Installation

* Install WAVI Core

Use a special script for Ubuntu 16.04:

    wget -q https://raw.githubusercontent.com/wavicom/wavi_scripts/master/setup_wavi_for_explorer.sh
    chmod 755 setup_wavi_for_explorer.sh
    ./setup_wavi_for_explorer.sh

Or for Ubuntu 18.04:

    wget -q https://raw.githubusercontent.com/wavicom/wavi_scripts_ubuntu18/master/setup_wavi_for_explorer.sh
    chmod 755 setup_wavi_for_explorer.sh
    ./setup_wavi_for_explorer.sh

* Install MongoDB Community Edition

https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
    echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
    sudo apt-get update
    sudo apt-get install -y mongodb-org

Default init system is systemd which was Upstart previously. So you need to install Upstart, reboot your system and here you go, you can now run mongodb service.

Install Upstart
    
    sudo apt-get install upstart-sysv -y

To add the file /etc/init/mongod_vm_settings.conf with the following content:

    nano /etc/init/mongod_vm_settings.conf

Add this content to the mongod_vm_settings.conf:

    # Ubuntu upstart file at /etc/init/mongod_vm_settings.conf
    #
    #   This file will set the correct kernel VM settings for MongoDB
    #   This file is maintained in Ansible
    
    start on (starting mongod)
    script
    echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
    echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
    end script

Reboot your system

    sudo reboot
    sudo service mongod start

Running MongoDB - reference

    sudo service mongod start
    sudo service mongod stop
    sudo service mongod restart

Note: if you later see this warning from mongo:

    WARNING: /sys/kernel/mm/transparent_hugepage/enabled is 'always'.

then you can solve it by the following steps:

To add the file /etc/init/mongod_vm_settings.conf with the following content:

    # Ubuntu upstart file at /etc/init/mongod_vm_settings.conf
    #
    #   This file will set the correct kernel VM settings for MongoDB
    #   This file is maintained in Ansible
    
    start on (starting mongod)
    script
    echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
    echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
    end script

This will cause the script to run before mongod. Restart mongod and run:

    sudo service mongod restart

* Install NodeJS

https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions

    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y nodejs


### Create database

Enter MongoDB cli:

    $ mongo

Create databse:

    > use explorerdb

Create user with read/write access:

    > db.createUser( { user: "username", pwd: "3xp!0reR", roles: [ "readWrite" ] } )

*note: If you're using mongo shell 2.4.x, use the following to create your user:

    > db.addUser( { user: "username", pwd: "password", roles: [ "readWrite"] })

### Get the source

    git clone https://github.com/wavicom/explorer

### Install node modules

    cd explorer && npm install --production

### Configure

    cp ./settings.json.template ./settings.json

*Make required changes in settings.json*

Note: user (61 line) and password (62 line) must match the your local wavi.conf file.

### Start Explorer

    npm start

*note: mongod must be running to start the explorer*

As of version 1.4.0 the explorer defaults to cluster mode, forking an instance of its process to each cpu core. This results in increased performance and stability. Load balancing gets automatically taken care of and any instances that for some reason die, will be restarted automatically. For testing/development (or if you just wish to) a single instance can be launched with

    node --stack-size=10000 bin/instance

To stop the cluster you can use

    npm stop

### Syncing databases with the blockchain

sync.js (located in scripts/) is used for updating the local databases. This script must be called from the explorers root directory.

    Usage: node scripts/sync.js [database] [mode]

    database: (required)
    index [mode] Main index: coin info/stats, transactions & addresses
    market       Market data: summaries, orderbooks, trade history & chartdata

    mode: (required for index database only)
    update       Updates index from last sync to current block
    check        checks index for (and adds) any missing transactions/addresses
    reindex      Clears index then resyncs from genesis to current block

    notes:
    * 'current block' is the latest created block when script is executed.
    * The market database only supports (& defaults to) reindex mode.
    * If check mode finds missing data(ignoring new data since last sync),
      index_timeout in settings.json is set too low.


*It is recommended to have this script launched via a cronjob at 1+ min intervals.*

**crontab**

*Example crontab; update index every minute and market data every 2 minutes*

    */1 * * * * cd /path/to/explorer && /usr/bin/nodejs scripts/sync.js index update > /dev/null 2>&1
    */2 * * * * cd /path/to/explorer && /usr/bin/nodejs scripts/sync.js market > /dev/null 2>&1
    */5 * * * * cd /path/to/explorer && /usr/bin/nodejs scripts/peers.js > /dev/null 2>&1

### Wallet

WAVI Explorer is intended to be generic so it can be used with any wallet following the usual standards. The wallet must be running with atleast the following flags

    -daemon -txindex

### Donate (Left Luke's addresses, please contribute!)  

    BTC: 168hdKA3fkccPtkxnX8hBrsxNubvk4udJi
    JBS: JZp9893FMmrm1681bDuJBU7c6w11kyEY7D (no longer valid, use BTC address)

### Known Issues

**script is already running.**

If you receive this message when launching the sync script either a) a sync is currently in progress, or b) a previous sync was killed before it completed. If you are certian a sync is not in progress remove the index.pid from the tmp folder in the explorer root directory.

    rm tmp/index.pid

**exceeding stack size**

    RangeError: Maximum call stack size exceeded

Nodes default stack size may be too small to index addresses with many tx's. If you experience the above error while running sync.js the stack size needs to be increased.

To determine the default setting run

    node --v8-options | grep -B0 -A1 stack_size

To run sync.js with a larger stack size launch with

    node --stack-size=[SIZE] scripts/sync.js index update

Where [SIZE] is an integer higher than the default.

*note: SIZE will depend on which blockchain you are using, you may need to play around a bit to find an optimal setting*

### License

Copyright (c) 2015, Iquidus Technology  
Copyright (c) 2015, Luke Williams  
Copyright (c) 2018, MNOS Developers  
Copyright (c) 2018, WAVI Community Developers  
  
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of Iquidus Technology nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
