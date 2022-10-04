#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

for i in .gitconfig .gitignore .pystartup .xonshrc; do
    echo $i
    ln -fs $SCRIPT_DIR/$i ~
done
