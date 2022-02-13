#!/bin/sh
:;
:; exec "${EMACS:-emacs}" --debug-init --load "$0" "$@"; exit

(unless inhibit-startup-screen (split-window))

(insert "elisp: " load-file-name)

(call-process "perl" nil "*scratch*" nil "-x" load-file-name "Hey there!")

;; do not do this -- as I did first: ;// (process deliberately typoed)
;; (call-prozezz load-file-name nil "*scratch*" nil "Hey there!")

;; ref: emacsninja.com/posts/forbidden-emacs-lisp-knowledge-block-comments.html
#@00 /* We've just seen #@00, which means "skip to end". */

^^ emacs no longer evaluates this file ^^

## c-x c-e at the end of these lines to change modes...
;; (cperl-mode)
## (emacs-lisp-mode)
;; (sh-mode)

#!perl
#line 26
#'''' 26

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
