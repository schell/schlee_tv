#! /bin/bash


if hash aws 2>/dev/null; then
    echo "aws is already installed at:"
    which aws
else
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    echo "Installed aws into:"
    which aws
fi
