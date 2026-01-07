#!/bin/bash
rm /usr/bin/tmuxo 2> /dev/null
ln -s $(pwd)/tmuxo.sh /usr/bin/tmuxo
