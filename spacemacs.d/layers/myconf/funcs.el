;;; funcs.el --- Random functions

;;; Commentary:
;; This file contains a smattering of utility functions supporting my use of Spacemacs.

;;; Code:

(defun set-indent (n)
  "Set indentation level to N for various major modes."
  "(Some modes are set to N+2 for aesthetic reasons.)"
  ;; N-offsets
  (setq c-basic-offset n) ; java/c/c++

  (setq coffee-tab-width n) ; coffeescript

  (setq javascript-indent-level n) ; javascript-mode
  (setq js-indent-level n) ; js-mode
  (setq js2-basic-offset n) ; js2-mode, in latest js2-mode, it's alias of js-indent-level

  (setq typescript-indent-level n) ; typescript

  (setq web-mode-markup-indent-offset n) ; web-mode, html tag in html file
  (setq web-mode-css-indent-offset n) ; web-mode, css in html file
  (setq web-mode-code-indent-offset n) ; web-mode, js code in html file

  (setq css-indent-offset n) ; css-mode

  (setq sh-basic-offset n) ; sh-mode

  ;; (N + 2)-offsets
  (setq go-tab-width (+ 2 n)) ; go-mode
  )

;; For things like blog posts
(defun datestamp ()
  "Insert an ISO formatted date-time."
  (interactive)
  (insert (shell-command-to-string "echo -n `gdate -Iminutes`")))

(defun change-jira (ticket-number)
  "Change the current JIRA ticket context to TICKET-NUMBER."
  (interactive "sChange JIRA context to: ")
  (setenv "JIRA_CURRENT"
          (shell-command-to-string
           (format "source ~/.oh-my-zsh/custom/functions/jira.zsh && cj %s >/dev/null && printf $JIRA_CURRENT"
                   ticket-number))))

(provide 'funcs)
;;; funcs.el ends here
