;;; funcs.el --- Change themes based on ambient lighting

;;; Commentary:

;;; Code:

(declare-function spacemacs/system-is-mac "ext:spacemacs/system-is-mac")
(declare-function shell-command-to-string "ext:shell-command-to-string")

(defun call-hs (code)
  "Return the result of calling Hammerspoon with the given Lua CODE."
  (when (and (spacemacs/system-is-mac)
             (executable-find "hs"))
    (shell-command-to-string
     (concat "hs -q -c \"" code "\""))))

(defun ambientheme-lux-func-default ()
  "Uses Hammerspoon to determine the ambient brightness detected by your Mac's
light sensor."
  (call-hs "hs.brightness.ambient()"))

(defun ambientheme/ambient-brightness ()
  "Return the approximate Lux value of the ambient brightness detected by your
Mac's sensor."
  (let ((result (funcall ambientheme-lux-func)))
    (if result
        (string-to-number result)
      (progn
        (message "Could not calculate ambient brightness: %s" result)
        nil))))
;; (ambientheme/ambient-brightness)

(cl-defun ambientheme/pick (&optional (dark-theme ambientheme-dark-theme)
                                      (light-theme ambientheme-light-theme))
  "Pick the theme registered with Ambientheme most appropriate for the current
ambient light level, with optional arguments DARK-THEME and LIGHT-THEME acting
as overrides for the corresponding theme."
  (let ((ambience (ambientheme/ambient-brightness)))
    (when ambience
      (if (< ambience ambientheme-threshold)
          dark-theme
        light-theme))))
;; (ambientheme/pick)

(defun ambientheme/pick-and-change-theme ()
  "Change to the theme registered with Ambientheme most appropriate for the
given ambience level."
  (let ((chosen-theme (ambientheme/pick)))
    (when (not (or (eq nil chosen-theme)
                   (eq spacemacs--cur-theme chosen-theme)))
      (spacemacs/load-theme chosen-theme nil t)
      (message "%s theme activated" spacemacs--cur-theme))))
;; (ambientheme/pick-and-change-theme)

(cl-defun ambientheme/init-timer (&key (idle t) (secs 2) (repeat t))
  "Initialize a timer to poll the ambient brightness and change to the most
appropriate theme. The type of timer is determined by IDLE; see
`run-with-idle-timer' and `run-with-timer' for more details."
  (interactive)
  (if idle
      (run-with-idle-timer secs repeat #'ambientheme/pick-and-change-theme)
    (run-with-timer secs repeat #'ambientheme/pick-and-change-theme)))
;; (ambientheme/init-timer)

(defun ambientheme/cancel-timer ()
  "Cancels any and all Ambientheme timers."
  (cancel-function-timers #'ambientheme/pick-and-change-theme))
;; (ambientheme/cancel-timer)

(provide 'funcs)
;;; funcs.el ends here
