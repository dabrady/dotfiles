;;; packages.el --- yafolding layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Daniel Brady <daniel.brady@dbrady-mbpr.local>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; A private layer for the 'yafolding' package.
;; https://github.com/zenozeng/yafolding.el

;;; Code:

(defconst yafolding-packages
  '(yafolding))

(defun yafolding/init-yafolding ()
  "Initialize the yafolding package"
  (use-package yafolding)
  (add-hook 'before-save-hook 'yafolding-show-all))
;;; packages.el ends here
