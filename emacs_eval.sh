#!/usr/bin/env sh
read -r -d '' myhead <<- EOF
(let ((enable-local-variables nil) ;; to avoid some errors when those use some stuff not in emacs by default
      (warning-minimum-level :emergency)) ;; reduce warnings

  (add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
  (require 'setup-utils)
  (require 'setup-constants)
  (require 'setup-android)
  (require 'setup-elpaca)
  (require 'setup-org)
  (require 'setup-packages)
  (require 'setup-blk)
  (elpaca-wait)
EOF
emacs --batch --eval "$myhead$1)"