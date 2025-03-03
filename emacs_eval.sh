#!/usr/bin/env sh
read -r -d '' myhead <<- EOF
(let ((enable-local-variables nil) ;; to avoid some errors when those use some stuff not in emacs by default
      (warning-minimum-level :emergency)) ;; reduce warnings

  (toggle-debug-on-error)
  (add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
  (require 'config-utils)
  (require 'config-constants)
  (require 'config-android)
  (require 'config-elpaca)
  (require 'config-other)
  (require 'config-org)
  (require 'config-packages)
  (require 'config-theme)
  (require 'config-blk)
  (elpaca-wait)
EOF
emacs --batch --eval "$myhead$1)"