#! /bin/bash


downloadTerraform () {
    echo "Downloading terraform..."
    wget https://releases.hashicorp.com/terraform/$VER/$PKG.zip
    echo "Unzipping..."
    unzip $PKG
    echo "Moving it into place..."
    mv terraform $DIR/
    echo "Cleaning up..."
    rm $PKG.zip
}


if hash terraform 2>/dev/null; then
    echo "Terraform is already installed at:"
    which terraform
else
    VER="0.12.20"
    PKG="terraform_${VER}_linux_amd64"
    DIR="/usr/local/bin"
    PREV=`pwd`

    mkdir -p install-terraform
    cd install-terraform
    downloadTerraform
    cd $PREV
    echo "Installed terraform into:"
    which terraform
fi
