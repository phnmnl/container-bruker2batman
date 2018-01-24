#!/bin/bash

apt-get update -y && apt-get install -y --no-install-recommends wget ca-certificates unzip

#download test data
mkdir testDir

wget https://github.com/phnmnl/container-bruker2batman/blob/master/test_data/mesa_bruker.zip?raw=true -O ./mesa_bruker.zip

unzip -q -d ./testDir ./mesa_bruker.zip

bruker2batman.R -i ./testDir

temp="NMRdata.txt"

if [ ! -f "$temp" ]; then
    echo "NMRdata.txt not found!"
    exit 1
else
    echo "Succeeded!"
fi

