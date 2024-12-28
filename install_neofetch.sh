#!/bin/bash

# 更新系统
sudo apt update -y

# 安装必要的依赖
sudo apt install -y git bash

# 克隆 neofetch 仓库
git clone https://github.com/scssw/neofetch.git /tmp/neofetch

# 复制 neofetch 脚本到 /usr/local/bin 目录
sudo cp /tmp/neofetch/neofetch /usr/local/bin/

# 删除临时文件夹
rm -rf /tmp/neofetch

# 设置执行权限
sudo chmod +x /usr/local/bin/neofetch

# 验证安装
echo "Neofetch has been installed successfully!"
echo "You can now run 'neofetch' command."
