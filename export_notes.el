#!/bin/sh
":"; exec emacs --script "$0" "$@" # -*- mode: emacs-lisp; lexical-binding: t; -*-
(let ((enable-local-variables nil) ;; to avoid some errors when those use some stuff not in emacs by default
      (org-startup-with-inline-images nil) ;; to avoid errors
      (warning-minimum-level :emergency)) ;; reduce warnings
  (add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
  (require 'setup-constants)
  (require 'setup-utils)
  (require 'setup-elpaca)
  (require 'setup-org)
  (elpaca-wait)
  (map-dir-files (format "%s/notes/" (getenv "BRAIN_DIR"))
                 (list (lambda ()
                         (message "file: %s\n" buffer-file-name)
                         (export-file buffer-file-name :pdf-p t)
                         ))
                 "\.org$"))
