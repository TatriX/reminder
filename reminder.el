;;; reminder.el --- Simple notification based reminder

;; Author: TatriX <tatrics@gmail.com>
;; URL: https://github.com/TatriX/reminder.el
;; Keywords: tools, time, reminder, appointments
;; Version: 0.1
;; Package-Requires: ((emacs "24.3") (alert "1.2") (org "9.1"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Simple notification based reminder.

;;; Code:
(require 'alert)
(require 'org)

(defvar reminder--reminders (make-hash-table :test #'equal))
(defvar reminder--reminders-history nil)

(defun reminder-add (time text)
  "Set a reminder via `run-at-time' at TIME with TEXT."
  (interactive (list (org-read-date t t)
                     (completing-read "Text: " nil nil nil nil 'reminder--reminders-history)))
  (let ((timer (run-at-time time nil `(lambda ()
                                        (remhash ,text reminder--reminders)
                                        (alert ,text :persistent t :style 'libnotify)))))
    (puthash text timer reminder--reminders)))

(defun reminder-remove (text)
  "Cancel timer identified by TEXT."
  (interactive (list (completing-read "Text: " reminder--reminders nil t)))
  (cancel-timer (gethash text reminder--reminders))
  (remhash text reminder--reminders)
  (message "%s canceled" text))

(defun reminder-list ()
  "Print reminders."
  (interactive)
  (if (hash-table-empty-p reminder--reminders)
      (message "No reminders")
    (let (buffer)
      ;; TODO: sort collection by time
      (maphash (lambda (text timer)
                 (push (format "%s %s"
                               (format-time-string "%Y.%m.%d | %H:%M |" (timer--time timer))
                               text)
                       buffer))
               reminder--reminders)
      (message-or-box "%s" (string-join buffer "\n")))))

(defun reminder-clear ()
  "Clear all reminders."
  (interactive)
  (mapc #'cancel-timer (hash-table-values reminder--reminders))
  (clrhash reminder--reminders))

(provide 'reminder)
;;; reminder ends here
