#!/bin/bash

# 更新系统
apt update -y

# 安装必要的依赖
apt install -y bash vnstat

# 从当前目录安装 neofetch
if [ ! -f "./neofetch" ]; then
    echo "错误：当前目录未找到 ./neofetch"
    echo "请在 neofetch 仓库目录内运行本脚本。"
    exit 1
fi

# 复制 neofetch 脚本到 /usr/local/bin 目录
cp ./neofetch /usr/local/bin/

# 更新 neofetch 配置文件，确保启用 Traffic 显示
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/neofetch"
config_file="${config_dir}/config.conf"

mkdir -p "$config_dir"

if [ ! -f "$config_file" ]; then
    /usr/local/bin/neofetch --print_config > "$config_file"
fi

if ! grep -q 'info "Traffic" traffic' "$config_file"; then
    awk '
        { print }
        /info "Local IP" local_ip/ && !done {
            print "    info \"Traffic\" traffic"
            done=1
        }
    ' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
fi

# 设置执行权限
chmod +x /usr/local/bin/neofetch

# 确保 vnstat 服务运行并初始化数据库（如果适用）
if command -v vnstat >/dev/null 2>&1; then
    if command -v systemctl >/dev/null 2>&1; then
        systemctl enable --now vnstat >/dev/null 2>&1 || true
    fi

    if command -v ip >/dev/null 2>&1; then
        iface="$(ip route get 1 2>/dev/null | awk '/dev/ {for (i=1; i<=NF; i++) if ($i=="dev") {print $(i+1); exit}}')"
        [ -n "$iface" ] || iface="$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')"
    fi

    if [ -n "$iface" ]; then
        vnstat -u -i "$iface" >/dev/null 2>&1 || true
    fi
fi

# 验证安装
echo "Neofetch has been installed successfully!"
echo "You can now run 'neofetch' command."
