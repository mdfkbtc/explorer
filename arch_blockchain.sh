#!/bin/bash

cd >/dev/null 2>&1
cd /root/.wavicore >/dev/null 2>&1
tar -cvf blockchain_database.tar blocks >/dev/null 2>&1
tar -rvf blockchain_database.tar chainstate >/dev/null 2>&1
tar -rvf blockchain_database.tar hashes >/dev/null 2>&1
cd >/dev/null 2>&1
cd /root/explorer/public/downloads >/dev/null 2>&1
rm blockchain_database.tar >/dev/null 2>&1
cd >/dev/null 2>&1
cd /root/.wavicore >/dev/null 2>&1
mv blockchain_database.tar /root/explorer/public/downloads >/dev/null 2>&1
