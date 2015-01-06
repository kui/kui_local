#!/bin/bash -exu
# -*- coding:utf-8 -*-

MACPORTS_INSTALLS=(git screen zsh curl wget coreutils)
UBUNTU_INSTALLS=(git screen zsh curl wget ssh build-essential)
PLATFORM="$(
    if which lsb_release &>/dev/null && lsb_release -a | grep 'Ubuntu' &>/dev/null; then
        echo "Ubuntu"
    elif grep "darwin" <<< "$OSTYPE" &>/dev/null; then
        echo "MacOSX"
    else
        echo ""
    fi
)"
BASE_DIR="$HOME/.dotfiles"

main() {
    if [[ -z "$PLATFORM" ]]; then
        abort "Not supported platform"
    fi

    install_basics
    if [[ -e "$BASE_DIR" ]];
    then cd "$BASE_DIR"; git push origin master
    else git clone git@github.com:kui/kui_local.git "$BASE_DIR"
    fi
    cd "$BASE_DIR"

    git submodule init
    git submodule update

    install_dotfiles
    install_templates

    echo "Success!!"
    echo "Next, see the following scripts: "
    ls "$BASE_DIR/installs"
}

install_basics() {
    local installs
    case "$PLATFORM" in
        Ubuntu) for p in "${UBUNTU_INSTALLS[@]}"; do sudo apt-get install "$p"; done;;
        MacOSX) for p in "${MACPORTS_INSTALLS[@]}"; do sudo port install "$p"; done;;
        *) abort "Invalid platform"
    esac
}

install_dotfiles() {
    local file
    for file in $(pwd)/dotfiles/*; do
        local dest="$HOME/.$(basename $file)"
        ln_s "$file" "$dest"
    done
}

install_templates() {
    local file
    for file in templates/*; do
        local dest="$HOME/.$(basename $file)"
        if [[ -e "$dest" ]]; then
            warn "Skip the template installation: Already exist $file"
            continue
        fi
        cp "$file" "$dest"
    done
}

ln_s() {
    local opts=$(
        if   [[ "$PLATFORM" == "Ubuntu" ]]; then echo "-sbT"
        elif [[ "$PLATFORM" == "MacOSX" ]]; then echo "-sf"
        fi
    )
    ln "$opts" $1 $2
}

abort() {
    err "$@"
    exit 1
}
err() {
    echo -e "$@" >&2
}
warn() {
    echo -e "WARN: $@"
}

main
