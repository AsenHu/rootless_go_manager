#!/usr/bin/env bash

install_go_scr() {
    local GO_PATH status tmp errMes goVer goPath
    GO_PATH="$HOME/GO"
    if ! "$GO_PATH/install.sh version > /dev/null"
    then
        tmp=$(bash <(curl https://raw.githubusercontent.com/AsenHu/rootless_go_manager/main/install.sh) @ install "--path=$GO_PATH")
    else
        tmp=$("$GO_PATH/install.sh" @ install "--path=$GO_PATH")
    fi

    status=$(echo "$tmp" |cut -d':' -f1)

    if [ "$status" == "ERROR" ]
    then
        errMes=$(echo "$tmp" |cut -d':' -f2)
        echo "ERROR: $errMes"
    fi

    if [ "$status" == "SYSTEM" ]
    then
        goVer=$(echo "$tmp" |cut -d':' -f2)
    fi

    if [ "$status" == "BOTH" ]
    then
        goVer=$(echo "$tmp" |cut -d':' -f4)
    fi

    if [ "$status" == "SCRIPT" ]
    then
        goPath=$(echo "$tmp" |cut -d':' -f2)
        goVer=$(echo "$tmp" |cut -d':' -f3)
        PATH="$PATH:$GO_PATH/go/bin"
    fi
}
