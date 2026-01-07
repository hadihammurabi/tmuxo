#!/bin/bash
curl -L -O 'https://raw.githubusercontent.com/hadihammurabi/tmuxo/refs/heads/master/tmuxo.sh'
chmod +x ./tmuxo.sh
rm /usr/bin/tmuxo || true
ln -s $(pwd)/tmuxo.sh /usr/bin/tmuxo

