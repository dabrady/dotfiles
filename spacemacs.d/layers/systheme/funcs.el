;;; funcs.el --- Change themes based on macOS system theme

;;; Commentary:

;;; Code:

(declare-function spacemacs/system-is-mac "ext:spacemacs/system-is-mac")
(declare-function shell-command-to-string "ext:shell-command-to-string")

(defun eval-applescript (code)
  "Return the result of evaluating the given AppleScript CODE."
  (when (and (spacemacs/system-is-mac)
             (executable-find "osascript"))
    (shell-command-to-string (concat "osascript -e '" code "'"))))

(defun systheme/dark-mode? ()
  "Uses AppleScript to determine if the current system theme is dark."
  (string= "true\n"
           (eval-applescript
            "tell application \"System Events\" to tell appearance preferences to return dark mode")))

(cl-defun systheme/pick (&optional (dark-theme systheme-dark-theme)
                                   (light-theme systheme-light-theme))
  "Pick the theme registered with Systheme most appropriate for the current
system theme, with optional arguments DARK-THEME and LIGHT-THEME acting
as overrides for the corresponding theme."
  (if (systheme/dark-mode?)
    dark-theme
    light-theme))

(defun systheme/sync-theme ()
  "Change to the theme registered with Systheme for the current system theme."
  (let ((chosen-theme (systheme/pick)))
    (when (not (or (eq nil chosen-theme)
                   (eq spacemacs--cur-theme chosen-theme)))
      (spacemacs/load-theme chosen-theme nil t)
      (message "%s theme activated" spacemacs--cur-theme))))

(cl-defun systheme/init-timer (&key (idle t) (secs 2) (repeat t))
  "Initialize a timer to poll the system theme and change to the most
appropriate theme. The type of timer is determined by IDLE; see
`run-with-idle-timer' and `run-with-timer' for more details."
  (interactive)
  (if idle
      (run-with-idle-timer secs repeat #'systheme/sync-theme)
    (run-with-timer secs repeat #'systheme/sync-theme)))

(defun systheme/cancel-timer ()
  "Cancels any and all Systheme timers."
  (cancel-function-timers #'systheme/sync-theme))

(provide 'funcs)
;;; funcs.el ends here
