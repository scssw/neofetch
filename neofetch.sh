#!/bin/bash

# 安装 neofetch
curl -sSL https://raw.githubusercontent.com/scssw/neofetch/refs/heads/master/install_neofetch.sh | bash

# 更新 .bashrc 文件，使得每次登录时显示 neofetch
echo 'if [ -x "$(command -v neofetch)" ]; then neofetch; fi' >> ~/.bashrc

# 使 .bashrc 的更改生效
source ~/.bashrc

echo "Neofetch has been installed and will display on login."
