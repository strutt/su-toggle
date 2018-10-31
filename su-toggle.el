;;; su-toggle.el --- Emacs functions to toggle editing files with super-user permissions using tramp.

;; Copyright (C) 2018 Ben Strutt

;; Author:  Ben Strutt <ben@benstrutt.net>
;; Version: 0.1
;; Package-Requires: ((s "1.12.0") (tramp "2.3.3.26.1"))
;; Keywords: tramp sudo su
;; URL: http://github.com/strutt/su-toggle

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Emacs can open files as a super-user using tramp.
;; This package provides functions to do that with fewer keystrokes.

;;; Usage:
;; M-x su-toggle



;;; Code:

(require 'tramp)
(require 's)



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
    (su-toggle--promote)))


(defun su-toggle--current-buffer-is-su ()
  "Check the current buffer file name to see if it has the su-toggle-tramp-prefix."
  (s-contains-p su-toggle-tramp-prefix (buffer-file-name)))


(defun su-toggle--promoted-file-name (filename)
  "Add the su-toggle-tramp-prefix to FILENAME."
  (concat su-toggle-tramp-prefix filename))


(defun su-toggle--demoted-file-name (filename)
  "Remove the su-toggle-tramp-prefix from FILENAME."
  (s-replace su-toggle-tramp-prefix "" filename))


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
  "Check whether the current buffer has a file.  If so, prompt the user to save."
  (if (buffer-file-name)
      (if (and (buffer-modified-p)
	       (yes-or-no-p (format "Save %s before su-toggle? " (buffer-file-name))))
	  (progn (save-buffer) t)
	t)
    (progn (message "Can't su-toggle non-existent file.") nil)
    ))

(provide 'su-toggle)
;;; su-toggle.el ends here
