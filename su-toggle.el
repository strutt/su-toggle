;;; su-toggle.el --- A simple set of functions to toggle between opening files with SU permissions in TRAMP.
;;; Commentary:

;;; Code:

(require 'tramp) ;; I know this is built in, but if we don't have it su-toggle is useless.
(require 's) ;; To manipulate file names.

(defcustom su-toggle-tramp-prefix "/sudo:root@localhost:"
  "The file prefix for su-toggle to insert for opening files as SU with tramp."
  :group 'su-toggle
  :type 'string
  )

(defun su-toggle ()
  "Switch to editing current buffer with super-user permissions."
  (interactive)
  (if (su-toggle--current-buffer-is-su)
      (su-toggle--demote)
    (su-toggle--promote)
    )
  )


(defun su-toggle--current-buffer-is-su ()
  "Check the current buffer file name to see if it has the su-toggle-tramp-prefix."
  (s-contains-p su-toggle-tramp-prefix (buffer-file-name)))


(defun su-toggle--promoted-file-name (filename)
  "Add the su-toggle-tramp-prefix to FILENAME."
  (concat su-toggle-tramp-prefix filename)
  )

(defun su-toggle--demoted-file-name (filename)
  "Remove the su-toggle-tramp-prefix from FILENAME."
  (s-replace su-toggle-tramp-prefix "" filename)
  )

(defun su-toggle--promote ()
  "Open the file with SU permissions and close the buffer without those permissions."
  (if (su-toggle--ready-for-toggle)
      (let ((demoted-buffer (current-buffer))
	    (default-directory "/") ;; overwrite the default-directory otherwise naive string input to find-file won't work
	    )
	(if (find-file (su-toggle--promoted-file-name (buffer-file-name)))
	    (kill-buffer demoted-buffer))
	)
    )
  )

(defun su-toggle--demote ()
  "Open the file without SU permissions and close the buffer with those permissions."
  (if (su-toggle--ready-for-toggle)
      (let ((promoted-buffer (current-buffer)))
	(if (find-file (su-toggle--demoted-file-name (buffer-file-name)))
		       (kill-buffer promoted-buffer)
	))))

(defun su-toggle--ready-for-toggle ()
  "Check whether the current buffer is saved as a file.  If so, prompt the user to save."
  (if (buffer-file-name)
      (if (and (buffer-modified-p)
	       (yes-or-no-p (format "Save %s before su-toggle? " (buffer-file-name))))
	  (progn
	    (save-buffer) t) t )
    (progn
      (message "Can't su-toggle non-existent file.")
      nil
      )
    )
  )

(provide 'su-toggle)
;;; su-toggle.el ends here
