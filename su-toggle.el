;;; Commentary
;; A simple set of functions to toggle between opening files as SU permissions

(defun su-toggle ()
  (interactive)

  (let (filename (buffer-file-name))
    (if (s-contains-p "/sudo:root@localhost:")
	(su-demote)
      (su-promote)
      )
    )
  )



(defun su-promote ()
  (interactive)
  (let ((filename (buffer-file-name)) ;; get the current file name
	(non-root-buffer (current-buffer))
	(default-directory "/") ;; overwrite the default-directory otherwise naive string input to find-file won't work
	)
    (if (not filename)
	(message "Can't open non-existent file with SU permissions.")
      
      (progn
	(if (and (buffer-modified-p)
		 (yes-or-no-p (format "Save %s before opening as root? " filename) ))
	    (save-buffer))
	(if (find-file (concat "/su:root@localhost:" filename))
	    (kill-buffer non-root-buffer))
	)
      )
    )
  )

(defun su-demote ()
  (interactive)
  (let ((filename (buffer-file-name)) ;; get the current file name
	(root-buffer (current-buffer))
	)
    (if (not filename)
	(message "Can't opened non-existent file without SU permissions.")
      (progn
	(if (and (buffer-modified-p)
		 (yes-or-no-p (format "Save %s before opening as non-root? " filename) ))
	    (save-buffer))
	(let ((non-root-file-name (s-replace "/su:root@localhost:" "" filename)))
	  (message non-root-file-name)
	  (if (find-file non-root-file-name)
	      (kill-buffer root-buffer))
	  )
	)
      )
    )
  )

(provide 'su-toggle)

