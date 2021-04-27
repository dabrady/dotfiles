;;; packages.el --- The init for my-spaceline config
;
;;; Commentary:
;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `my-spaceline-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `my-spaceline/init-PACKAGE' to load and initialize the package.
;;
;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `my-spaceline/pre-init-PACKAGE' and/or
;;   `my-spaceline/post-init-PACKAGE' to customize the package as it is loaded.
;
;;; Code:
(defconst my-spaceline-packages
  '(
    all-the-icons
    spaceline ; Owned by spacemacs-ui-visual, don't init
    spaceline-all-the-icons
    ))

(defun my-spaceline/init-all-the-icons ()
  "Initialize the all-the-icons package."
  (use-package all-the-icons
    :defer t
    :config (setq neo-theme 'icons)))

(defun my-spaceline/post-init-spaceline ()
  "Do some post-initialization setup of spaceline."
  ; Color the mode-line according to the current Evil state.
  (defvar spaceline-highlight-face-func "ext:spaceline-highlight-face-func")
  (setq spaceline-highlight-face-func 'spaceline-highlight-face-evil-state))

(defun my-spaceline/init-spaceline-all-the-icons ()
  (use-package spaceline-all-the-icons
    :after spaceline
    :config (progn
              (spaceline-all-the-icons-theme)
              (spaceline-all-the-icons--setup-neotree)
              (spaceline-all-the-icons--setup-git-ahead)
              (spaceline-all-the-icons--setup-package-updates)
              (spaceline-all-the-icons--setup-paradox)

              (spaceline-toggle-all-the-icons-bookmark-on)

              (setq spaceline-all-the-icons-icon-set-modified 'toggle)
              (setq spaceline-all-the-icons-icon-set-bookmark 'heart)
              (setq spaceline-all-the-icons-icon-set-dedicated 'pin)
              (setq spaceline-all-the-icons-icon-set-window-numbering 'solid)
              (setq spaceline-all-the-icons-icon-set-eyebrowse-workspace 'circle)
              (setq spaceline-all-the-icons-icon-set-multiple-cursors 'caret)
              (setq spaceline-all-the-icons-icon-set-flycheck-slim 'solid)
              (setq spaceline-all-the-icons-icon-set-git-stats 'diff-icons)
              (setq spaceline-all-the-icons-icon-set-sun-time 'sun/moon)

              (setq spaceline-all-the-icons-separator-type 'slant))))
 ;;; packages.el ends here
