#!/bin/bash
# -*- coding: utf-8-unix -*-

is_ubuntu() {
    which lsb_release &>/dev/null && ( lsb_release -a | grep 'Ubuntu' ) &>/dev/null
}

is_mac_os_x() {
    [ "$(sw_vers -productName)" = "Mac OS X" ]
}

run() {
    echo_green $ "$@"
    env "$@"
}
echo_green() {
    echo "\e[32m${@}\e[39m"
}
echo_red() {
    echo "\e[31m${@}\e[39m"
}
abort() {
    err "Abort: $@"
    exit 1
}
err() {
    echo_red "$@" >&2
}
warn() {
    echo_red "WARN: $@"
}
