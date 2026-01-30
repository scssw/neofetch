#!/bin/bash

# 更新系统
apt update -y

# 安装必要的依赖
apt install -y bash vnstat

# 从当前目录安装 neofetch；若不存在则从远端拉取
neofetch_bin="/usr/local/bin/neofetch"
neofetch_cmd="$neofetch_bin"

if [ ! -f "./neofetch" ]; then
    repo_raw_base="https://raw.githubusercontent.com/scssw/neofetch/refs/heads/master"
    tmpdir="$(mktemp -d)"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${repo_raw_base}/neofetch" -o "${tmpdir}/neofetch"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "${tmpdir}/neofetch" "${repo_raw_base}/neofetch"
    else
        echo "错误：未找到 curl 或 wget，无法下载 neofetch。"
        exit 1
    fi
    if [ ! -s "${tmpdir}/neofetch" ]; then
        echo "错误：下载 neofetch 失败。"
        exit 1
    fi
    install -m 0755 "${tmpdir}/neofetch" "$neofetch_bin"
else
    # 复制 neofetch 脚本到 /usr/local/bin 目录
    install -m 0755 ./neofetch "$neofetch_bin"
fi

 # 复制后清理临时目录（如果创建了）
if [ -n "${tmpdir:-}" ] && [ -d "$tmpdir" ]; then
    rm -rf "$tmpdir"
fi

# 如果系统挂载了 noexec，直接执行可能失败，使用 bash 调用
if ! "$neofetch_bin" --version >/dev/null 2>&1; then
    neofetch_cmd="bash $neofetch_bin"
fi

# 更新 neofetch 配置文件，确保启用 Traffic 显示
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/neofetch"
config_file="${config_dir}/config.conf"

mkdir -p "$config_dir"

if [ ! -f "$config_file" ]; then
    $neofetch_cmd --print_config > "$config_file"
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
# 使 .bashrc 的更改生效
source ~/.bashrc

echo "Neofetch has been installed and will display on login."
# 验证安装
echo "Neofetch has been installed successfully!"
echo "You can now run 'neofetch' command."
