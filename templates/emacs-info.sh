#!/bin/sh
:;
:; exec "${EMACS:-emacs}" --debug-init --load "$0" "$@"; exit

;; now in emacs (could have more code above

(info (car command-line-args-left))

;; so that emacs doesn't load these as files
(setq command-line-args-left nil)

;; Local Variables:
;; mode: emacs-lisp
;; End:
