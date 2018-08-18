;;; config.el --- Change themes based on ambient lighting

;;; Commentary:

;;; Code:

(defvar ambientheme-threshold 10
  "The Lux threshold value to use when picking the appropriate theme.")

(defvar ambientheme-light-theme nil
  "The theme to use when there is plenty of light.")

(defvar ambientheme-dark-theme nil
  "The theme to use when in low-light conditions.")

(defvar ambientheme-lux-func 'ambientheme-lux-func-default
  "An override function for providing the Lux value measuring the current ambient lighting.")

(ambientheme/init-timer)
