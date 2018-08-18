;;; config.el --- Fixes bugs

;;; Commentary:
;; This file contains code to fix known bugs with my current Spacemacs config.

;;; Code:

;; Address a bug in MacOS version of Emacs, where powerline separators are drawn using an inappopriate color space
(defvar powerline-image-apple-rgb)
(setq powerline-image-apple-rgb t)

;; Address a bug where semantic-mode and company-mode don't play nicely with
;; each other when typing inside strings and comments.
;; @see https://github.com/company-mode/company-mode/issues/525
(declare-function inside-string-q "ext:inside-string-q")
(declare-function inside-comment-q "ext:inside-comment-q")
(defun dont-call-if-string-or-comment (advised-f &rest args)
  "Only call ADVISED-F with ARGS if POINT is not inside a string or comment."
  (unless (or (inside-string-q) (inside-comment-q))
    (apply advised-f args)))

(advice-add 'semantic-analyze-completion-at-point-function :around #'dont-call-if-string-or-comment)

(provide 'config)
;;; config.el ends here
