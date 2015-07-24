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

(defun jshint-init ()
  (setq-local jshint-configuration-path
              (expand-file-name ".jshintrc"
                                (locate-dominating-file
                                 default-directory ".jshintrc")))
  (flymake-jshint-load))

;; jslint me
(require 'flymake-jshint)
(add-hook 'js-mode-hook 'jshint-init)

;; React
(add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))
(defadvice web-mode-highlight-part (around tweak-jsx activate)
  (if (equal web-mode-content-type "jsx")
      (let ((web-mode-enable-part-face nil))
        ad-do-it)
    ad-do-it))
(setq web-mode-code-indent-offset 2)
(setq web-mode-markup-indent-offset 2)
(add-hook 'web-mode-hook 'jshint-init)

(setq python-shell-interpreter "python3")

;; Templates for Pyramid :/
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

(setenv "PATH" (concat "~/.cabal/bin:" (getenv "PATH")))
(setenv "PATH" (concat "/opt/ghc/7.8.4/bin:" (getenv "PATH")))
(add-to-list 'exec-path "~/.cabal/bin")
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(custom-set-variables '(haskell-tags-on-save t))
(custom-set-variables
  '(haskell-process-suggest-remove-import-lines t)
  '(haskell-process-auto-import-loaded-modules t)
  '(haskell-process-log t))
(eval-after-load 'haskell-mode '(progn
  (define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-or-reload)
  (define-key haskell-mode-map (kbd "C-c C-z") 'haskell-interactive-switch)
  (define-key haskell-mode-map (kbd "C-c C-n C-t") 'haskell-process-do-type)
  (define-key haskell-mode-map (kbd "C-c C-n C-i") 'haskell-process-do-info)
  (define-key haskell-mode-map (kbd "C-c C-n C-c") 'haskell-process-cabal-build)
  (define-key haskell-mode-map (kbd "C-c C-n c") 'haskell-process-cabal)
  (define-key haskell-mode-map (kbd "SPC") 'haskell-mode-contextual-space)))
(eval-after-load 'haskell-cabal '(progn
  (define-key haskell-cabal-mode-map (kbd "C-c C-z") 'haskell-interactive-switch)
  (define-key haskell-cabal-mode-map (kbd "C-c C-k") 'haskell-interactive-mode-clear)
  (define-key haskell-cabal-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
  (define-key haskell-cabal-mode-map (kbd "C-c c") 'haskell-process-cabal)))
(custom-set-variables '(haskell-process-type 'cabal-repl))

(autoload 'ghc-init "ghc" nil t)
(autoload 'ghc-debug "ghc" nil t)
(add-hook 'haskell-mode-hook (lambda () (ghc-init)))

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
