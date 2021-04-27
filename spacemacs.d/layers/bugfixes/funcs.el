;;; funcs.el --- Random functions used by this layer

;;; Commentary:
;; This file contains a smattering of utility functions supporting this layer.

;;; Code:
(defun inside-string-q ()
  "Return non-nil if inside a string, else nil.
Result depends on syntax table's string quote character."
  (interactive)
  (nth 3 (syntax-ppss)))

(defun inside-comment-q ()
  "Return non-nil if inside a comment, else nil.
Result depends on syntax table's comment character."
  (interactive)
  (nth 4 (syntax-ppss)))

(provide 'funcs)
;;; funcs.el ends here
