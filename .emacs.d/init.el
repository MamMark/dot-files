;;; Ver 5.0 20210725 u1804 zot/rubr + vm

;; (if nil
;; (cond
;;  ((file-newer-than-file-p "~/.emacs.el" "~/.emacs")
;;   (let ((mode-line-format "Recompiling .emacs..."))
;;     (message "Wait!  Your .emacs.el needs recompiling...")
;;     (sit-for 1)
;;     (byte-compile-file "~/.emacs.el")
;;     (rename-file "~/.emacs.elc" "~/.emacs" t)
;;     (message "Surfs up.  I'm outo here, Dude...")
;;     (sit-for 2)
;;     (kill-emacs)
;;     )))
;; )

(let ((local-settings "~/.emacs.d/.init.local.el"))
  (if (file-exists-p local-settings)
      (load-file local-settings)))

;;;
;;; frame positions dependent on what system we are actually displaying on
;;;

(when (display-graphic-p)
  (let ((remote_node
         (let ((node (getenv "SSH_CONNECTION")))
           (if (stringp node)
               (car (split-string node))
             "")))
        (rubr      "192.168.1.6" )
        (skoos-pro "192.168.1.93"))
    (cond
     ((and (string-equal system-name "zot")
           (string-equal remote_node ""))
        (message "zot, local")
        (setq initial-frame-alist
              '((top   .   0) (left   .    0)
                (width . 100) (height .   50)))
        (setq default-frame-alist
              '((top .     0) (left   . 1000)
                (width . 115) (height .   58)))
        (set-frame-size (selected-frame) 100 50))

     ((or (string-equal system-name "rubr.priv")
          (string-equal remote_node rubr))
        (message "rubr: %s %s" system-name rubr)
        (setq initial-frame-alist
              '((top   .   0) (left   . 1100)
                (width . 160) (height .   74)))
        (setq default-frame-alist
              '((top .     0) (left   . 1600)
                (width . 115) (height .   58)))
        (set-frame-size (selected-frame) 160 74))

     ((string-equal remote_node skoos-pro)
        (message "skoos-pro")
        (setq initial-frame-alist
              '((top   .   0) (left   .    0)
                (width . 100) (height .   50)))
        (setq default-frame-alist
              '((top .     0) (left   .  780)
                (width . 110) (height .   58)))
        (set-frame-size (selected-frame) 100 50)))))

;;;(set-frame-font "-adobe-courier-medium-r-normal--14-180-75-75-m-110-iso8859-1")

(setq load-path (append (list "~/.emacs.d/lib") load-path))
(load "misc")
(load "make")
(load "uniquify")
(setq uniquify-buffer-name-style 'forward)

(load "flushish")

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

;;; (load-library "realgud")
;;; (setq realgud-safe-mode nil)

(require 'ido)
(ido-mode 1)
(setq ido-default-file-method 'selected-window)
(setq ido-default-buffer-method 'selected-window)
(add-hook 'ido-setup-hook
                    (lambda ()
                      (define-key ido-completion-map
                        (kbd "C-x g") 'ido-enter-magit-status)))

(defun ido-remove-tramp-from-cache nil
  "Remove any TRAMP entries from `ido-dir-file-cache'.
    This stops tramp from trying to connect to remote hosts on emacs startup,
    which can be very annoying."
  (interactive)
  (setq ido-dir-file-cache
        (cl-remove-if
         (lambda (x)
           (string-match "/\\(rsh\\|ssh\\|telnet\\|su\\|sudo\\|sshx\\|krlogin\\|ksu\\|rcp\\|scp\\|rsync\\|scpx\\|fcp\\|nc\\|ftp\\|smb\\|adb\\):" (car x)))
         ido-dir-file-cache)))

;; redefine `ido-kill-emacs-hook' so that cache is cleaned before being saved
(defun ido-kill-emacs-hook ()
  (ido-remove-tramp-from-cache)
  (ido-save-history))

;;;
;;; when emacs 25.1 comes along.
;;;
;;; (define-key ido-common-completion-map
;;;            (kbd "C-x g") 'ido-enter-magit-status)
;;;

;;;
;;; org mode
;;;
(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done 'time)
(setq org-agenda-files (list "~/.emacs.d/org/tag.org"
                             "~/.emacs.d/org/Misc.org"))
(setq org-todo-keywords
      '((sequence "TODO(t)" "INPROGRESS(i)" "WAITING(w)" "FEEDBACK(f)" "VERIFY(v)" "|" "DONE(d)" "ABANDONED(a)" )))


;;; (fset 'yes-or-no-p 'y-or-n-p)

(setq display-time-interval 30)
(setq dired-dwim-target t)
(setq dired-backup-overwrite t)
(setq backward-delete-char-untabify-method 'all)
(display-time)
;;; (mouse-avoidance-mode 'banish)
(size-indication-mode t)
(show-paren-mode t)
(setq show-paren-style 'mixed)
(scroll-bar-mode 0)
(tool-bar-mode 0)

;; Allow repeated pops from the mark ring with C-u C-SPC C-SPC ...
(setq set-mark-command-repeat-pop t)

;;;
;;; grep stuff
;;;
(setq-default grep-template "grep <X> <C> -nHiR -e <R> <F>")
(setq grep-highlight-matches t)

;;;(grep-compute-defaults)
;;;(grep-apply-setting 'grep-command xxx)
;;;(eval-after-load "grep"
;;;  '(progn
;;;     (add-to-list 'grep-find-ignored-files "*.tmp")
;;;     (add-to-list 'grep-find-ignored-directories "_darcs")))
;;;add GREP_OPTIONS="--exclude=*#* --exclude=...

;;;
;;; Dired stuff
;;;
(add-hook 'dired-load-hook
          (function (lambda ()
                      (load "dired-x")
                      ;; Set global variables here.  For example:
                      ;; (setq dired-guess-shell-gnutar "gtar")
                      )))


;;;
;;; Shell stuff
(add-hook 'shell-mode-hook
	  (function (lambda ()
		      (local-unset-key "\C-c\C-m")
		      )))
(setq shell-popd-regexp "popd\\|p")
(setq shell-prompt-pattern "^[^#$%>:\n]*[#$%>:] *")
(setq shell-pushd-regexp "pushd\\|pd")
(add-to-list 'same-window-buffer-names "*shell*")
;;; (define-key text-mode-map "\es" nil)
;;; (define-key text-mode-map "\eS" nil)
;;; (define-key indented-text-mode-map "\es" nil)
;;; (define-key indented-text-mode-map "\eS" nil)
(global-set-key "\e\es" 'shell)

;;;
;;; gdb stuff
;;; make
;;; magit
;;;

(load "gdbish")

(add-hook 'gdb-mode-hook
          (function (lambda ()
                      (local-set-key (kbd "^C^L") 'gdb-redraw))))

(global-set-key (kbd "<f12>") 'gdb-redraw)
(global-set-key (kbd "C-X SPC") 'gud-break)
(global-set-key (kbd "C-C g")   'gdb)

(global-set-key "\^C\^M" 'make)
(global-set-key (kbd "C-X c") 'compile-with-same-commands)

(global-set-key (kbd "C-X g")   'magit-status)
(global-set-key (kbd "C-x M-g") 'magit-dispatch-popup)

;;; (require 'magit-gitflow)
;;; (add-hook 'magit-mode-hook 'turn-on-magit-gitflow)

(setq magit-repository-directories
      '(("~/mm/tinyos-main/tinyos-2.x" . 0)
        ("~/mm/tp-master/tinyos-2.x"   . 0)))

;;;
;;; turn on winner mode
;;;

(when (fboundp 'winner-mode)
  (winner-mode 1))

;;;
;;; ediff customization
;;;
;;; see https://oremacs.com/2015/01/17/setting-up-ediff/
;;;

(defmacro csetq (variable value)
  `(funcall (or (get ',variable 'custom-set)
                'set-default)
            ',variable ,value))
(csetq ediff-window-setup-function 'ediff-setup-windows-plain)
(csetq ediff-split-window-function 'split-window-horizontally)
(add-hook 'ediff-after-quit-hook-internal 'winner-undo)


;;;
;;; Bookmarks.
;;;
;;; C-x r m     set a bookmark
;;; C-x r l     list bookmarks
;;; C-x r b     jump to bookmark

;;;
;;; C/Nesc Editing
;;;
;;; (autoload 'nesc-mode "nesc.el")
;;;(add-to-list 'auto-mode-alist '("\\.nc\\'" . nesc-mode))
(add-to-list 'auto-mode-alist '("\\.nc\\'" . c-mode))

(global-set-key "\^Cb" 'c-begin-function)

;;
;; code formatting
;;
(c-add-style "mine"
	     '("linux"
	       (c-basic-offset . 2)
	       (c-tab-always-indent t)
	       (c-auto-align-backslashes t)
	       (c-offsets-alist . ((arglist-close . c-lineup-arglist)
                                   (substatement-open . 0)
                                   (case-label        . +)
                                   (statement-block-intro . +)
                                   (block-open        . 0)))))
(setq c-default-style "mine")
(setq-default comment-column 40)

;;;(defun my-c-mode-hook ()
;;;  (c-set-style "mine"))

;;;(defun my-c-mode-hook ()
;;;  (c-set-style "mine")
;;;  (setq c-basic-offset 2
;;;        c-tab-always-indent t
;;;        c-auto-align-backslashes t
;;;        c-offsets-alist '((arglist-close     . c-lineup-arglist)
;;;                          (substatement-open . 0)
;;;                          (case-label        . +)
;;;                          (block-open        . 0)))
;;;  (c-set-offset 'substatement-open '0) ; brackets should be at same indentation level as the statements they open
;;;  (c-set-offset 'inline-open '+)
;;;  (c-set-offset 'block-open '+)
;;;  (c-set-offset 'brace-list-open '+)   ; all "opens" should be indented by the c-indent-level
;;;  (c-set-offset 'case-label '+))       ; indent case labels by c-indent-level, too

;;;(add-hook 'c-mode-common-hook 'my-c-mode-hook)


;;;(defconst my-c-style
;;;    (c-hanging-braces-alist     . ((substatement-open after)
;;;                                   (brace-list-open)))
;;;    (c-hanging-colons-alist     . ((member-init-intro before)
;;;                                   (inher-intro)
;;;                                   (case-label after)
;;;                                   (label after)
;;;                                   (access-label after)))
;;;    (c-cleanup-list             . (scope-operator
;;;                                   empty-defun-braces
;;;                                   defun-close-semi))
;;;    (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
;;;                                   (substatement-open . 0)
;;;                                   (case-label        . 4)
;;;                                   (block-open        . 0)
;;;                                   (knr-argdecl-intro . -)))
;;;    (c-echo-syntactic-information-p . t)
;;;    )

(setq c-report-syntactic-errors t)
(setq c-echo-syntactic-information-p t)

(setq tramp-default-method "ssh")

;;
;; key modifications to suit my tastes (do I have more than one?)
;;

;;; (setq indent-line-function 'indent-relative-maybe)

(global-set-key "\^C\^B" 'single-buffer-menu)
(global-set-key "\^C\^H" 'command-history-mode)
(global-set-key "\^C\^N" 'other-window)
(global-set-key "\^C\^P" 'prev-window)
(global-set-key "\^C." 'set-mark-command)
(global-set-key "\^C>" 'scroll-right-all)
(global-set-key "\^Cn"   'other-window)
(global-set-key "\^Cp"   'prev-window)

;; Add a keystroke for renaming a buffer
(global-set-key "\C-cr" 'rename-buffer)

(global-set-key "\^X\^B" 'buffer-menu)
;;; (global-set-key "\^X\^C" 'give-info-about-exit)
(global-set-key "\^X]"	 'next-page-top)
(global-set-key "\^Xl" 'goto-line)
(global-set-key "\^Z"  'scroll-down)
(global-set-key "\e\e=" 'what-line)

(global-set-key "\e?" 'apropos)
(global-set-key "\e]" 'forward-paragraph)

;;
;; mode line
;;
(setq-default mode-line-position
              '((-5 "%p") (size-indication-mode ("/" (-5 "%I")))
                (line-number-mode
                 (" %l" (column-number-mode ":%c")))
                "  "
                ))

(setq-default mode-line-format
  '("%e" mode-line-front-space
    mode-line-mule-info
    mode-line-client
    mode-line-modified
    mode-line-remote
    mode-line-frame-identification
    mode-line-buffer-identification
    " "
    mode-line-position
    (vc-mode vc-mode)
    "  "
    mode-line-misc-info
    " %b "
    mode-line-modified
    " "
    mode-line-modes
    mode-line-end-spaces))

(setq-default mode-line-buffer-identification
	      '(#("%5f " 0 3
   (local-map
    (keymap
     (header-line keymap
		  (mouse-3 . mode-line-next-buffer)
		  (down-mouse-3 . ignore)
		  (mouse-1 . mode-line-previous-buffer)
		  (down-mouse-1 . ignore))
     (mode-line keymap
		(mouse-3 . mode-line-next-buffer)
		(mouse-1 . mode-line-previous-buffer)))
    mouse-face mode-line-highlight help-echo "Buffer name\nmouse-1: previous buffer\nmouse-3: next buffer" face mode-line-buffer-id))))


;;;
;;; backup settings
;;;
(setq make-backup-files t
      backup-by-copying t)
(setq backup-by-copying-when-linked t)
(setq dired-kept-versions 3)
(setq trim-versions-without-asking nil)
(setq version-control t
      kept-new-versions 8
      kept-old-versions 4
      delete-old-versions t)

;;;
;;; Disables
;;;
(put 'eval-expression 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled t)
(put 'downcase-region 'disabled t)

;;;
;;; whitespace
;;;
(require 'whitespace)
(setq-default show-trailing-whitespace t)

(defun no-trailing-whitespace ()
  (interactive)
  (setq show-trailing-whitespace nil))

(add-hook 'minibuffer-setup-hook  'no-trailing-whitespace)
(add-hook 'eww-mode-hook          'no-trailing-whitespace)
(add-hook 'ielm-mode-hook         'no-trailing-whitespace)
(add-hook 'gdb-mode-hook          'no-trailing-whitespace)
(add-hook 'pdb-mode-hook          'no-trailing-whitespace)
(add-hook 'help-mode-hook         'no-trailing-whitespace)
(add-hook 'Buffer-menu-mode-hook  'no-trailing-whitespace)
(add-hook 'calendar-mode-hook     'no-trailing-whitespace)
(add-hook 'shell-mode-hook        'no-trailing-whitespace)
(add-hook 'magit-popup-mode-hook  'no-trailing-whitespace)
(add-hook 'compilation-mode-hook  'no-trailing-whitespace)
(add-hook 'process-menu-mode-hook 'no-trailing-whitespace)

;;
;; other variables
;;

(setq split-width-threshold  nil)
(setq split-height-threshold nil)
(setq ctl-arrow t)
(setq-default indent-tabs-mode nil
              tab-width 8)
(setq-default fill-column 75)
(setq auto-save-interval 240
      delete-auto-save-files t)
(setq delete-exited-processes t)
;;; (setq inhibit-eol-conversion t)
(setq inhibit-quit nil)
(setq inhibit-startup-message t)
(setq inverse-video t)
(setq pop-up-windows t)
;;;(setq scroll-step 0)
(setq search-slow-window-lines 6)
(setq show-trailing-whitespace t)
(setq track-eol nil)
(setq truncate-lines nil)
(setq require-final-newline t)
(setq truncate-partial-width-windows nil)

(if (get-buffer "elisp")
    (progn (set-buffer "elisp")
	   (lisp-interaction-mode)
	   t)
  (set-buffer (get-buffer-create "*scratch*"))
  (lisp-interaction-mode)
  (rename-buffer "elisp")
  nil)

(setq-default major-mode 'indented-text-mode)
;;; (find-file-read-only "~/.ToDo")

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "1ASC" :family "Liberation Mono")))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(display-time-mode t)
 '(magit-commit-arguments nil)
 '(magit-log-arguments (quote ("--graph" "--decorate" "-n256")))
 '(save-place t)
 '(show-paren-mode t)
 '(size-indication-mode t)
 '(tool-bar-mode nil))
