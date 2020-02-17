#! /bin/bash


if hash ~/.local/bin/milkshake-cli 2>/dev/null; then
    echo "milkshake is already installed"
else
    wget https://github.com/schell/milkshake/releases/download/v0.3.0.0/milkshake-cli.tar.gz
    tar xvfz milkshake-cli.tar.gz
    mkdir -p ~/.local/bin
    mv milkshake-cli ~/.local/bin
    echo "Installed milkshake"
fi
