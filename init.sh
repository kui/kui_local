#!/bin/bash -exu
# -*- coding:utf-8 -*-

MACPORTS_INSTALLS=(git screen zsh curl wget coreutils)
UBUNTU_INSTALLS=(git screen zsh curl wget ssh build-essential)
PLATFORM="$(
    if which lsb_release; then
        if lsb_release -a | grep '^Description' | grep 'Ubuntu'; then
            echo "Ubuntu"
        fi
    elif grep "darwin" <<< "$OSTYPE"; then
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
    git clone git@github.com:kui/kui_dotfiles.git "$BASE_DIR"
    cd "$BASE_DIR"

    install_dotfiles
    install_templates

    if [[ -n "$DISPLAY" ]]; then
        setup_user_dir
    fi

    echo "Success!!"
    echo "Next, see the following scripts: "
    ls "$BASE_DIR/installs"
}

install_basics() {
    local installs
    case "$PLATFORM" in
        Ubuntu) for p in "${UBUNTU_INSTALLS[@]}"; apt-get install "$p";;
        MacOSX) for p in "${MACPORTS_INSTALLS[@]}"; ports install "$p";;
        *) abort "Invalid platform"
    esac
}

install_dotfiles() {
    local file
    for file in dotfiles/*; do
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

setup_user_dir(){
    mkdir -p "${HOME}/.config"
    ln_s "user-dirs.dirs" "${HOME}/.config/user-dirs.dirs"

    # create user dirs
    local dir
    for dir in $(grep '^XDG_' user-dirs.dirs | cut -d'=' -f2); do
        dir="$(eval echo -e "$dir")"
        [[ ! -e "$dir" ]] && mkdir -pv "$dir"
    done
}

LN_OPTS=$(
    case "$PLATFORM" in
        Ubuntu) echo "-sbT";;
        MacOSX) echo "-sf";;
        *) abort "Invalid platform"
    esac
)

ln_s() {
    ln "$LN_OPTS" $1 $2
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
