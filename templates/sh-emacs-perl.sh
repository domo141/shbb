#!/bin/sh
:;
:; exec "${EMACS:-emacs}" --debug-init --load "$0" "$@"; exit

;; note: many things broken after load-read-function change.
;;       some hook to continue elsewhere (if possible) might help...

(unless inhibit-startup-screen (split-window))

(insert "elisp: " load-file-name)

(call-process "perl" nil "*scratch*" nil "-x" load-file-name "Hey there!")

;; do not do this -- as I did first: ;// (process deliberately typoed)
;; (call-prozezz load-file-name nil "*scratch*" nil "Hey there!")

;; stop reading this file as emacs lisp code
(setq load-read-function
      (lambda (stream)
        (prog1 nil (condition-case nil (read stream) ((debug error) nil)))))

;; c-x c-e at the end of these lines to change modes...
;; (cperl-mode)
;; (emacs-lisp-mode)
;; (sh-mode)

#'` <-- these 2 chars may help for cperl-mode to work correctly (when not)

#!perl
#line 29
#'''' 29

use 5.10.1; # 5.10 provides say; and \K in regexps...
use strict;
use warnings;

say '';
say 'perl: ', $0, ' line ', __LINE__, ' -- ', $ARGV[0];
say ''

__END__

;; Local Variables:
;; mode: emacs-lisp
;; End:
