#!/usr/bin/env bash

# 输出内容
# SCRIPT:GO 路径:GO 版本
# BOTH:脚本 GO 路径:脚本 GO 版本:系统 GO 版本
# SYSTEM:GO 版本
# ERROR:错误原因

# 配置环境变量

if ! curl --version > /dev/null
then
    echo "ERROR:No curl"
    exit 1
fi

path="$HOME/GO"

getSysInfo() {

    # 获取系统架构

    # https://github.com/chise0713/go-install
    case "$(uname -m)" in
      'i386' | 'i686')
        MACHINE='386'
        ;;
      'amd64' | 'x86_64')
        MACHINE='amd64'
        ;;
      'armv5tel')
        MACHINE='arm'
        ;;
      'armv6l')
        MACHINE='arm'
        ;;
      'armv7' | 'armv7l')
        MACHINE='arm'
        ;;
      'armv8' | 'aarch64')
        MACHINE='arm64'
        ;;
      'mips')
        MACHINE='mips'
        ;;
      'mipsle')
        MACHINE='mipsle'
        ;;
      'mips64')
        MACHINE='mips64'
        lscpu | grep -q "Little Endian" && MACHINE='mips64le'
        ;;
      'mips64le')
        MACHINE='mips64le'
        ;;
      'ppc64')
        MACHINE='ppc64'
        ;;
      'ppc64le')
        MACHINE='ppc64le'
        ;;
      's390x')
        MACHINE='s390x'
        ;;
      *)
        echo "ERROR:The architecture is not supported."
        exit 1
        ;;
    esac

    # 获取系统 go 版本

    if ! sysGoVer=$(go version | sed -n 's/.*\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p')
    then
        sysGoVer=false
    fi

    # 获取脚本安装 go 版本

    if ! scrGoVer=$("$path/go/bin/go" version | sed -n 's/.*\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p')
    then
        scrGoVer=false
    fi

}

getSysInfo

# CURL

curl() {
    # Copy from https://github.com/XTLS/Xray-install
    if ! $(type -P curl) -L -q --retry 5 --retry-delay 10 --retry-max-time 60 "$@";then
        echo "ERROR:Curl Failed, check your network"
        exit 1
    fi
}

# 安装函数

# https://github.com/chise0713/go-install

install_go() {
    getGoVersion
    if [[ $MACHINE == amd64 ]] || [[ $MACHINE == arm64 ]] || [[ $MACHINE == armv6l ]] || [[ $MACHINE == 386 ]]; then
        mkdir -p "$path/tmp"
        rm "$path/tmp/go.tar.gz"
        curl -o "$path/tmp/go.tar.gz" "https://go.dev/dl/go$GO_VERSION.linux-$MACHINE.tar.gz"
        rm -rf "$path/go" # && echo -e "DEBUG: Deleted current GO"
        tar -C "$path" -xzf "$path/tmp/go.tar.gz" # && echo -e "DEBUG: Replaced GO"
        rm "$path/tmp/go.tar.gz"
    else
        echo "ERROR:The architecture is not supported. Try to install go by yourself."
        exit 1
    fi
}

# 获取最新 go 版本函数

getGoVersion() {
    if [ ! "$GO_VERSION" ]
    then
        GO_VERSION=$(curl -sL https://golang.org/VERSION?m=text | head -1 | sed -n 's/.*\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p')
    fi
}

# 版本输出函数

scrVer() {
    echo "1.0.0"
    exit 0
}

# 输出 GO 版本

echoGoVer() {
    if [ "$sysGoVer" ]
    then
        if [ "$scrGoVer" ]
        then
            echo "BOTH:$HOME/GO/go/bin/go:$scrGoVer:$sysGoVer"
        else
            echo "SYSTEM:$sysGoVer"
        fi
    else
        if [ "$scrGoVer" ]
        then
            echo "SCRIPT:$HOME/GO/go/bin/go:$scrGoVer"
        else
            echo "ERROR:unexpected error"
        fi
    fi
    exit 0
}

# GO 检查更新

checkGoUpdate() {
    getGoVersion
    if [ "$scrGoVer" == "$GO_VERSION" ]
    then
        echo false
    else
        echo true
    fi
}

# 脚本安装 & 更新

scrUpgrade() {
    local latScrVer locScrVer
    latScrVer=$(curl https://raw.githubusercontent.com/AsenHu/rootless_go_manager/main/version.txt)
    locScrVer=$("$path/install.sh" version)
    if [ "$latScrVer" != "$locScrVer" ]
    then
        curl -o "$path/install.sh" "https://raw.githubusercontent.com/AsenHu/rootless_go_manager/main/install.sh"
        chmod +x "$path/install.sh"
    fi
}

# main 函数

main () {
    scrUpgrade
    if [ "$FORCE" == true ]
    then
        if [ "$(checkGoUpdate)" == true ]
        then
            install_go
            getSysInfo
        fi
    else
        if [ "$sysGoVer" == false ]
        then
            if [ "$(checkGoUpdate)" == true ]
            then
                install_go
                getSysInfo
            fi
        fi
    fi
    echoGoVer
}

# help 函数

# https://github.com/chise0713/go-install

helpInfo() {
    echo -e "\
usage: install.sh ACTION [OPTION]...

ACTION:
install                   Use --path=$HOME/GO to install script
version                   Get script version
help                      Show help (alias: -h|--help)
If no action is specified, then help will be selected.

OPTION:
  install:
    -f --force                    If it's specified, the scrpit will force install latest version of golang.
    -p= --path=                    If it's specified, the scrpit will install latest version of golang to your specified path.
                                    For example, if \`--path=$HOME/GO\` is specified, the scrpit will install golang into \`$HOME/GO/go\`

If you want to uninstall, please delete the folder where the script is located directly.
    "
}

# 菜单，如果全都没中就 help

for arg in "$@"; do
  case $arg in
    --force)
      FORCE=true
      ;;
    --path=*)
      path="${arg#*=}"
      ;;
    install)
      INSTALL=true
      ;;
    version)
      scrVer
      ;;
  esac
done

if [ "$INSTALL" ]
then
    main
else
    helpInfo
fi
