#! /bin/bash

mkdir -p ~/.local/bin

if [ -f "~/.local/bin/milkshake-cli" ]; then
    echo "milkshake is already installed"
    ls -lah ~/.local/bin
else
    wget https://github.com/schell/milkshake/releases/download/v0.3.0.0/milkshake-cli.tar.gz
    tar xvfz milkshake-cli.tar.gz
    mv milkshake-cli ~/.local/bin/milkshake-cli
    echo "Installed milkshake"
fi
