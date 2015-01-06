#!/bin/bash
# -*- coding:utf-8 -*-
set -exu

emacs --batch --eval '(setq kui/install-mode-p t)' --load '~/.emacs.d/init.el'
