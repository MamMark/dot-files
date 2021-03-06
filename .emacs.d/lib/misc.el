(defun white-on-black ()
  "force emacs to use white-on-black"
  (interactive)
  (set-background-color "black")
  (set-foreground-color "white"))

(defun black-on-white ()
  "force emacs to use black-on-white"
  (interactive)
  (set-foreground-color "black")
  (set-background-color "white"))

(defun prev-window (howmany)
  "select the previous window"
  (interactive "p")
  (other-window (- howmany)))

(defun scroll-right-all ()
  "force the current window to scroll fully to the right."
  (interactive)
  (scroll-right (window-hscroll)))

(defun single-buffer-menu (arg)
  "go into buffer-menu mode but make sure it has a single window.
ARG if non-nil, will show only buffers visiting files."
  (interactive "P")
  (buffer-menu arg)
  (delete-other-windows))

(defun update-buffer ()
  "Replace current buffer with contents of file that has changed
since this buffer last matched the file.  This is done by
looking at the modification times of the buffer and the
file it contains.  Current position and mark (in an absolute
sense) are maintained."
  (interactive)
  (if (not (buffer-file-name))
      (message "There is no file associated with this buffer.")
    (if (buffer-modified-p)
	(progn (message "This buffer is modified!")
	       (ding))
      (if (not (file-exists-p (buffer-file-name)))
	  (progn (sleep-for 2)
		 (if (not (file-exists-p (buffer-file-name)))
		     (progn (message "File no longer exists!")
			    (ding)))))
      (if (verify-visited-file-modtime (current-buffer))
	  (message "File and buffer are in sync.")
	(if (y-or-n-p "Are you sure? ")
	    (let ((cur-mark (mark))
		  (cur-line (count-lines 1 (point))))
	      (revert-buffer t t)
	      (set-mark cur-mark)
	      (goto-line cur-line))
	  (message "Aborted!")
;
; following is to get around a strange bug in 18.44.  If I leave
; just the above message without the following, the cursor will
; jump to the left edge of the window but point will still be
; where it was before.  but with the following nop it is fixed.
; something is south somewhere.
;
;	  (set-window-start (get-buffer-window (current-buffer))
;			    (window-start))
	  )
	)
      )
    )
  )

(defun rp(&optional opt-cmd-line no-reset)
  (interactive)
  (realgud:pdb opt-cmd-line no-reset))

(defvar make-command "make"
  "*command string that \"\\[make]\" uses to do its dirty deed.
Must be a string enclosed in double quotes.")

(defun make ()
  "force a make compilation.  The var make-command is what is
fed to compile"
  (interactive)
  (compile make-command)
  (setq compiled-in-this-buffer t)
  (save-excursion
    (set-buffer "*compilation*")
    (setq compiled-in-this-buffer t)
    (setq compile-command make-command)))

;; Use (make-variable-buffer-local 'compile-command) to have a different
;; one in every buffer.

;; C-x c compiles with the same commands as last M-x compile in this buffer

(make-variable-buffer-local 'compile-command)

(defvar compiled-in-this-buffer nil
  "*T if \\[compile-with-same-commands] has been run in this buffer.")

(make-variable-buffer-local 'compiled-in-this-buffer)

(defun compile-with-same-commands ()
  "Run \\[compile] with the same commands as the
last \\[compile], \\[make], or \\[compile-with-same-commands]."
  (interactive)
  (if compiled-in-this-buffer
      (compile compile-command)
    (call-interactively 'compile))
  (setq compiled-in-this-buffer t))

(defun bs-clean ()
  "Cleans current buffer of only underlining and overstriking,
leaves blank lines"
  (interactive)
  (save-excursion
    ;; Nuke underlining and overstriking (only by the same letter)
    (goto-char (point-min))
    (while (search-forward "\b" nil t)
      (let* ((preceding (char-after (- (point) 2)))
	     (following (following-char)))
	(cond ((= preceding following)
	       ;; x\bx
	       (delete-char -2))
	      ((= preceding ?\_)
	       ;; _\b
	       (delete-char -2))
	      ((= following ?\_)
	       ;; \b_
	       (delete-region (1- (point)) (1+ (point)))))))))

(defun clean-buffer ()
  "Cleans current buffer of underlining and overstriking"
  (interactive)
  (save-excursion
    ;; Nuke underlining and overstriking (only by the same letter)
    (goto-char (point-min))
    (while (search-forward "\b" nil t)
      (let* ((preceding (char-after (- (point) 2)))
	     (following (following-char)))
	(cond ((= preceding following)
	       ;; x\bx
	       (delete-char -2))
	      ((= preceding ?\_)
	       ;; _\b
	       (delete-char -2))
	      ((= following ?\_)
	       ;; \b_
	       (delete-region (1- (point)) (1+ (point)))))))

    ;; Crunch blank lines
    (goto-char (point-min))
    (while (re-search-forward "\n\n\n\n*" nil t)
      (replace-match "\n\n"))

    ;; Nuke blanks lines at start.
    (goto-char (point-min))
    (skip-chars-forward "\n")
    (delete-region (point-min) (point))))

(defun next-page-top ()
  "move to the start of the next page just like
forward-page (\\[forward-page]).  It then repositions
so that line is at the top of the current buffer."
  (interactive)
  (forward-page)
  (recenter 0))

(fset 'diffc-line
      "./ w=!diff -c gd/ ge/")

(defun manpage ()
  (interactive)
  (mark-whole-buffer)
  (shell-command-on-region (region-beginning) (region-end)
			   "nroff -man | uniq" nil 1)
  (set-mark-command 1)
  (set-mark-command 1)
  (switch-to-buffer-other-window "*Shell Command Output*")
  (clean-buffer))

(defun bye ()
  "make it easy to save-buffers-kill-emacs"
  (interactive)
  (list-processes)
  (save-buffers-kill-emacs))

(defun bury (buf)
  (interactive "bbury buffer: ")
  (bury-buffer buf))

(defun see-chars ()
  "Displays characters typed, terminated by a 3-second timeout."
  (interactive)
  (let ((chars "")
	(inhibit-quit t))
    (message "Enter characters, terminated by 3-second timeout.")
    (while (not (sit-for 3))
      (setq chars (concat chars (list (read-char)))
	    quit-flag nil))		; quit-flag maybe set by C-g
    (message "Characters entered: %s" (key-description chars))))

(defun gdb-setup-frames ()
  "sets up gdb frames"
  (interactive)
  (gdb-frame-registers-buffer)
  (gdb-frame-assembler-buffer)
  (gdb-frame-gdb-buffer))

(fset 'gps_open_packet
   [?\C-\[ ?\C-b ?\C-\[ ?\C-\[ ?: ?\( ?s ?e ?t ?q ?  ?n ?x ?t ?  ?\( ?c ?u ?r ?r ?e ?n ?t ?- ?c ?o ?l ?u ?m ?n ?\) ?\) return ?\C-o ?\C-n ?\C-a ?\C-\[ ?\C-\[ ?: ?\( ?i ?n ?d ?e ?n ?t ?- ?t ?o ?  ?n ?x ?t ?\) return ?\C-p ?\C-e ?\C-\[ ?\\ ?\C-n ?\C-e ?\C-s ?0 ?x ?a ?0 ?\C-x ?\)])
(fset 'gps_convert_time_idx
   [?\C-f ?\C-s ?, ?\C-b ?\C-  ?\C-\[ ?\C-b ?\C-\[ ?w ?\C-e ?\C-\[ ?i ?\C-\[ ?\C-\[ ?: ?\( ?i ?n ?s ?e ?r ?t ?- ?s ?t ?r ?i ?n ?g ?  ?\( ?f ?o ?r ?m ?a ?t ?  ?\" ?% ?d ?\" ?  ?\C-y ?\C-\[ ?b ?\C-d ?\C-d ?# ?x ?\C-e ?\) ?\) ?\C-m ?\C-\[ ?i ?\C-a ?\C-\[ ?\C-f ?\C-\[ ?b ?\C-  ?\C-\[ ?\C-f ?\C-\[ ?w ?\C-e ?\C-\[ ?\C-\[ ?: ?\( ?i ?n ?s ?e ?r ?t ?- ?s ?t ?r ?i ?n ?g ?  ?\( ?f ?o ?r ?m ?a ?t ?  ?\" ?0 ?x ?% ?x ?\" ?  ?\( ?+ ?  ?1 ?c ?2 ?0 ?\C-\[ ?\C-b ?# ?x ?\C-e ?  ?\C-y ?\C-\[ ?\C-b ?\C-d ?\C-d ?# ?x ?\C-e ?\) ?\) ?\) ?\C-m ?\C-n ?\C-a])

(defun apply-named-macro-to-region-lines (top bottom)
  "Apply named keyboard macro to all lines in the region."
  (interactive "r")
  (let ((macro (intern
                (completing-read "kbd macro (name): "
                                 obarray
                                 (lambda (elt)
                                   (and (fboundp elt)
                                        (or (stringp (symbol-function elt))
                                            (vectorp (symbol-function elt))
                                            (get elt 'kmacro))))
                                 t))))
    (apply-macro-to-region-lines top bottom macro)))
