#! /bin/bash

mkdir -p ~/.local/bin

if hash ~/.local/bin/milkshake-cli 2>/dev/null; then
    echo "milkshake is already installed"
    ls -lah ~/.local/bin
else
    wget https://github.com/schell/milkshake/releases/download/v0.3.0.0/milkshake-cli.tar.gz
    tar xvfz milkshake-cli.tar.gz
    mv milkshake-cli ~/.local/bin
    echo "Installed milkshake"
fi
