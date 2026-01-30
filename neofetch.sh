#!/bin/bash

# 清理旧的 neofetch 文件
echo "Removing old Neofetch files..."
rm -rf /usr/local/bin/neofetch
rm -rf /root/.config/neofetch


# 安装 neofetch
curl -sSL https://raw.githubusercontent.com/scssw/neofetch/refs/heads/master/install_neofetch.sh | bash

# 更新 .bashrc 文件，使得每次登录时显示 neofetch
#!/bin/bash

#!/bin/bash
#!/bin/bash


#!/bin/bash

# 检查系统是否为 Debian
if grep -qi "debian" /etc/os-release; then
    echo "检测到系统为 Debian，将覆盖 .bashrc 文件。"

    # 定义新的 .bashrc 内容
    cat > ~/.bashrc <<'EOF'
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
#    . /etc/bash_completion
#fi

# 自动运行 neofetch（兼容 noexec 环境）
if command -v neofetch >/dev/null 2>&1; then
    neofetch >/dev/null 2>&1 || bash /usr/local/bin/neofetch
elif [ -f /usr/local/bin/neofetch ]; then
    bash /usr/local/bin/neofetch
fi

# 加载 acme.sh 环境变量
[ -f "/root/.acme.sh/acme.sh.env" ] && . "/root/.acme.sh/acme.sh.env"
EOF

    echo ".bashrc 文件已覆盖完成。"

else
    echo "非 Debian 系统，仅添加 neofetch 自动运行逻辑到 .bashrc 文件。"

    # 检查是否已经包含 neofetch 逻辑
    if ! grep -Fq 'neofetch >/dev/null' ~/.bashrc; then
        cat >> ~/.bashrc <<'EOF'
# 自动运行 neofetch（兼容 noexec 环境）
if command -v neofetch >/dev/null 2>&1; then
    neofetch >/dev/null 2>&1 || bash /usr/local/bin/neofetch
elif [ -f /usr/local/bin/neofetch ]; then
    bash /usr/local/bin/neofetch
fi
EOF
        echo "已添加 neofetch 自动运行逻辑到 .bashrc 文件。"
    else
        echo "neofetch 自动运行逻辑已存在，无需重复添加。"
    fi
fi

# 确保登录 shell 也会加载 .bashrc
if [ ! -f ~/.bash_profile ]; then
    cat > ~/.bash_profile <<'EOF'
# Load ~/.bashrc for login shells
[ -f ~/.bashrc ] && . ~/.bashrc
EOF
elif ! grep -Fq '. ~/.bashrc' ~/.bash_profile; then
    echo '[ -f ~/.bashrc ] && . ~/.bashrc' >> ~/.bash_profile
fi

if [ ! -f ~/.profile ]; then
    cat > ~/.profile <<'EOF'
# Load ~/.bashrc for login shells
[ -f ~/.bashrc ] && . ~/.bashrc
EOF
elif ! grep -Fq '. ~/.bashrc' ~/.profile; then
    echo '[ -f ~/.bashrc ] && . ~/.bashrc' >> ~/.profile
fi

# 使 .bashrc 的更改生效
source ~/.bashrc

echo "Neofetch has been installed and will display on login."
