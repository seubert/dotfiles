(setq package-archives '(("ELPA" . "http://tromey.com/elpa/")
                         ("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

(add-to-list 'load-path (expand-file-name "~/.emacs.d/better-defaults"))

(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (shell-command-to-string "$SHELL -i -c 'echo $PATH'")))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

;; check OS type
(cond
 ((string-equal system-type "darwin")   ; Mac OS X
  (require 'cask "/usr/local/Cellar/cask/0.7.0/cask.el")
  (set-exec-path-from-shell-PATH)
  )
 ((string-equal system-type "gnu/linux") ; linux
  (require 'cask "/home/alex/.cask/cask.el")
  )
 )
(cask-initialize)
(require 'pallet)

(require 'better-defaults)
(require 'use-package)

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(load-theme 'solarized-dark)
(set-face-attribute 'default nil
                    :family "Source Code Pro" :height 90 :weight 'normal)

;; Font size key bindings
(global-set-key (kbd "s-=") 'text-scale-increase)	
(global-set-key (kbd "s--") 'text-scale-decrease)

;; Turn on line numbers and hide-show mode
(global-linum-mode t)
(setq-default hs-minor-mode t)
(setq default-tab-width 2)

;; jslint me
(require 'flymake-jshint)
(add-hook 'js-mode-hook (lambda ()
                          (setq-local jshint-configuration-path
                                      (expand-file-name ".jshintrc"
                                                        (locate-dominating-file
                                                         default-directory ".jshintrc")))
                          (flymake-jshint-load)))

(add-to-list 'auto-mode-alist
             '("\\.pt\\'" . (lambda ()
                              (html-mode))))

;; Get rid of the damn ding
(setq visible-bell 1)

;; scss settings
(setq scss-compile-at-save nil)

;; Share clipboard
(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

;; auto-indent correctly, with the sizes I want
(electric-indent-mode +1)
(add-hook 'electric-indent-functions
          (lambda (c) (when (eq 'org-mode major-mode) 'no-indent)))
(setq js-indent-level 2)
(setq css-indent-offset 2)

(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)

;; show time
(setq display-time-day-and-date t
      display-time-24hr-format t)
(display-time)

;; projectile-mode
(projectile-global-mode)

;; org-mode
(require 'org)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(setq org-log-done t)
(setq org-agenda-include-diary t)

;; bind "l;" at the same time to M-x (basically)
(require 'key-chord)
(key-chord-mode 1)
(key-chord-define-global "l;"     'execute-extended-command)

(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)
;; disable ido faces to see flx highlights.
(setq ido-use-faces nil)

(use-package magit
  :bind ("C-c g" . magit-status))

(add-hook 'go-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'gofmt-before-save)
            (setq tab-width 4)
            (setq indent-tabs-mode 1)))

(defun comment-or-uncomment-region-or-line ()
    "Comments or uncomments the region or the current line if there's no active region."
    (interactive)
    (let (beg end)
        (if (region-active-p)
            (setq beg (region-beginning) end (region-end))
            (setq beg (line-beginning-position) end (line-end-position)))
        (comment-or-uncomment-region beg end)))

(key-chord-define-global "[]"     'comment-or-uncomment-region-or-line)

;; Gimme that grunt! The `local` part is because I use a `local` task for
;; stuff that doesn't include uglifying etc. Much faster than prod.
(key-chord-define-global ",." 'grunt)
(setq grunt-cmd "grunt local --no-color")

(defun grunt ()
  "Run grunt"
  (interactive)
  (let* ((grunt-buffer (get-buffer-create "*grunt*"))
        (result (call-process-shell-command grunt-cmd nil grunt-buffer t))
        (output (with-current-buffer grunt-buffer (buffer-string))))
    (cond ((zerop result)
           (message "Grunt completed without errors"))
          (t
           (message nil)
           (split-window-vertically)
           (set-window-buffer (next-window) grunt-buffer)))))

;; vagrant tramp enable!
(eval-after-load 'tramp
  '(vagrant-tramp-enable))

;; ag.el settings
(setq ag-reuse-window 't)
(setq ag-reuse-buffers 't)
(setq ag-highlight-search t)
