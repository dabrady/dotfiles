;;; config.el --- Change themes based on macOS system theme

;;; Commentary:

;;; Code:

(defvar systheme-light-theme nil
  "The theme to use when macOS is in light mode.")

(defvar systheme-dark-theme nil
  "The theme to use when macOS is in dark mode.")

(systheme/init-timer)
