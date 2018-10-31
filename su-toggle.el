;;; Commentary
;; A simple set of functions to toggle between opening files as SU permissions

(defun su-toggle ()
  (interactive)
  (if (su-toggle--current-buffer-is-su)
      (su-toggle--demote)
    (su-toggle--promote)
    )
  )


(defun su-toggle--current-buffer-is-su ()
  (s-contains-p "/sudo:root@localhost:" (buffer-file-name)))


(defun su-toggle--promote ()
  (let ((filename (buffer-file-name)) ;; get the current file name
	(non-root-buffer (current-buffer))
	(default-directory "/") ;; overwrite the default-directory otherwise naive string input to find-file won't work
	)
    (if (su-toggle--ready-for-toggle)
	(if (find-file (concat "/sudo:root@localhost:" filename))
	    (kill-buffer non-root-buffer))
      )
    )
  )

(defun su-toggle--demote ()
  (if (su-toggle--ready-for-toggle)
      (let ((root-buffer (buffer-file-name))
	    (non-root-file-name (s-replace "/sudo:root@localhost:" "" root-buffer)))
	(if (find-file non-root-file-name)
	    (kill-buffer root-buffer))
	)
    )
  )

(defun su-toggle--ready-for-toggle ()
  (let ((filename (buffer-file-name))) ;; get the current file name  
	(if filename
	    (if (and (buffer-modified-p)
		     (yes-or-no-p (format "Save %s before su-toggle? " filename)))
		(progn 
		  (save-buffer) t) t )
	  (progn 
	    (message "Can't su-toggle non-existent file.")
	    nil
	    )
	  )
	)
  )













(provide 'su-toggle)

