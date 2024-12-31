#!/bin/sh -e

sudo git clone https://github.com/bigsen/gas-preprocessor.git /usr/local/bin/gas
sudo cp /usr/local/bin/gas/gas-preprocessor.pl /usr/local/bin/gas-preprocessor.pl
sudo chmod 777 /usr/local/bin/gas-preprocessor.pl
sudo rm -rf /usr/local/bin/gas/
