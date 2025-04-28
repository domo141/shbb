#!/bin/sh
#@0 -*- org -*-
# remember: c-x c-q (read-only-mode) (or often just 'e')
: || : << sh-code
#+STARTUP: overview

Some sample content for notes of one's own... /shell-code/
and /elisp-code/ are the ones that make this function....
In Emacs, press TAB on *-lines below to expand.

* org

  (info "org")

  C-u TAB  (org-cycle '(4))
  C-u C-u TAB  (org-cycle '(16))
  C-u C-u C-u TAB  (org-cycle '(64))

  https://orgmode.org/manual/Initial-visibility.html

  #.STARTUP: overview
  #.STARTUP: content
  #.STARTUP: showall
  #.STARTUP: show2levels
  #.STARTUP: show3levels
  #.STARTUP: show4levels
  #.STARTUP: show5levels
  #.STARTUP: showeverything


* nmcli

man nmcli-examples

$ nmcli -g ip4.address,ip4.gateway,ip4.dns \
        -m multiline device show [device]

$ nmcli device modify eth0 ipv4.method manual \
        ipv4.addresses 192.168.0.193/26 \
        ipv4.gateway ... ipv4.dns ...

\^ with leading '+' adds, '-' removes...

nmcli device wifi list
nmcli device wifi connect {SSID} password {password}
nmcli device wifi show-password
nmcli device status

$ nmcli d connect wlp2s0
$ nmcli d disconnect wlp2s0

$ nmcli c


* cc

  $ gcc -dM -E -xc /dev/null
  $ clang -dM -E -xc /dev/null
  $ zig cc -dM -E -xc /dev/null -target aarch64-linux-gnu.2.30


* shell-code
sh-code

set -euf

if test "${DISPLAY-}" && test "${XDG_RUNTIME_DIR-}"
then
	if ! emacsclient 2>/dev/null -cn -s sh-w-emacs.sock \
		--eval '(switch-to-tietoo)'
	then echo new emacs
	     emacs --load "$0" "$0" "$@" & # extra "$0" for older emacs'
	fi
	exit
fi

x_exec () {
	x=$1 y=$2 z=$3; shift 3; echo + $x $y $z \\;
	printf '   %s\n' "$*" >&2; exec $x $y $z "$@"
}

if command -v keept >/dev/null
then
	x_exec keept wl "$HOME"/tmp/usock-journals-org-keept \
		emacs -nw --load "$0" "$0" "$@"

elif command -v dtach >/dev/null
then
	x_exec dtach -A "$HOME"/tmp/usock-journals-org-dtach -z -e '^z' \
		emacs -nw --load "$0" "$0" "$@"
else
	echo 'no keept(1) nor dtach(1)'
	exit 55
fi

# c-x c-e at the end of next line
# (shell-script-mode)

exit not reached - failed attempts below...

${EMACSCLIENT:=emacsclient} -cn --socket-name=sh-w-emacs.sock \
	--eval '(switch-to-tietoo)' "$@" && exit

${EMACS:-emacs} --debug-init --daemon=sh-w-emacs.sock  \
	--eval "(load \"$0\")" "$0" "$@"

#--load "$0" "$0" "$@"

exec $EMACSCLIENT -cn --socket-name=sh-w-emacs.sock \
	--eval '(switch-to-tietoo)' "$@"

* elisp-code

v: ref: emacsninja.com/posts/forbidden-emacs-lisp-knowledge-block-comments.html


(setq car_argv (car argv)
      argv nil
      vc-follow-symlinks t)

(defun switch-to-tietoo ()
  (interactive)
  (switch-to-buffer
   (or (get-buffer "*tietoo*")
       (dired-noselect
	 (cons "*tietoo*"
	     (seq-filter
	      #'file-exists-p
	      ;;`,load-true-file-name ;; older emacs' don't have
	      `(,car_argv
		"~/.local/journal.org" ;; sample
		"~" ;; sample
		"." ;; sample
		))) "-go")
       )))

(switch-to-tietoo)

(require 'dired)
(define-key dired-mode-map "\C-m" #'dired-view-file)

(when (display-graphic-p)
  (setq server-name "sh-w-emacs.sock")
  (server-start))

;; (lisp-interaction-mode)
;; (org-mode)
;; (fundamental-mode)
