;; saws-mode.el for SourceAnywhere Standalone
;; Copyright (C) 2010 MINDBODY
;; Author: Paul English

(defvar saws-server "127.0.0.1")
(defvar saws-port "7779")
(defvar saws-repository "TODO")
(defvar saws-username "TODO")
(defvar saws-password "TODO")

(defun saws-command (command params)
  (let ((project (first (split-string  (substring (file-name-directory (buffer-file-name)) 15) "/")))
        (project-dir (substring (file-name-directory (buffer-file-name)) 15 (- (length (file-name-directory (buffer-file-name))) 1))))
    (setq command-str (concat "SAWSCmd.exe " command " "
                                              "-server " saws-server " "
                                              "-port " saws-port " "
                                              "-username \"" saws-username "\" "
                                              "-pwd \"" saws-password "\" "
                                              "-repository " saws-repository " "
                                              "-prj $/" project-dir " "
                                              params))
    (message command-str)
    (message (shell-command-to-string command-str))))

(defun saws-check-out-file (file)
  (interactive "b")
  (let ((cleaned-file (car (last (split-string file "/"))))
        (workdir (file-name-directory (buffer-file-name))))
    (saws-command "CheckOutFile"
                  (concat "-workdir \"" workdir "\" "
                          "-file \"" cleaned-file "\" ")))
  (toggle-read-only -1))

(defun saws-undo-check-out-file (file)
  (interactive "b")
  (let ((cleaned-file (car (last (split-string file "/"))))
        (workdir (file-name-directory (buffer-file-name))))
    (saws-command "UndoCheckOutFile"
                  (concat "-workdir \"" workdir "\" "
                          "-file \"" cleaned-file "\" ")))
  (revert-buffer)
  (toggle-read-only 1))

(defun saws-check-in-file (file input-comment)
  (interactive "b\nsComment: ")
  (let ((cleaned-file (car (last (split-string file "/"))))
        (workdir (file-name-directory (buffer-file-name))))
    (saws-command "CheckInFile"
                  (concat "-workdir \"" workdir "\" "
                          "-file \"" cleaned-file "\" "
                          "-comment \"" input-comment "\" ")))
  (toggle-read-only 1))

(defun saws-get-latest-file (input-file)
  (interactive "b")
  (let ((cleaned-file (car (last (split-string file "/"))))
        (workdir (file-name-directory (buffer-file-name))))
    (saws-command "GetLatestFile"
                  (concat "-workdir \"" workdir "\" "
                          "-file \"" cleaned-file "\" ")))
  (revert-buffer))

(defun saws-add-file (&optional input-file)
  (interactive)
  (input-if (not (boundp 'file))
      (setq file (buffer-file-name)))
  (setq csproj (second (split-string  (substring (file-name-directory file) 15) "/")))
  (setq csproj-file (concat "c:/iis/wwwroot/mb/" csproj "/" csproj ".csproj"))
  (saws-add-to-csproj csproj-file file)
  (let ((workdir (file-name-directory file))
        (project (first (split-string  (substring (file-name-directory file) 15) "/")))
        (project-dir (substring (file-name-directory file) 15 (- (length (file-name-directory file)) 1))))
(message (shell-command-to-string (concat "SAWSCmd.exe AddFile "
                                     "-server " saws-server " "
                                     "-port " saws-port " "
                                     "-username \"" saws-username "\" "
                                     "-pwd \"" saws-password "\" "
                                     "-repository " saws-repository " "
                                     "-prj $/" project-dir " "
                                     "-workdir \"" workdir "\" "
                                     "-file \"" (file-name-nondirectory file) "\" "))))
)

(defun saws-add-folder (&optional input-file)
  (interactive)
  (if (not (boundp 'input-file))
      (setq file (buffer-file-name)))
  ;; TODO change from file to folder
  (setq csproj (second (split-string  (substring (file-name-directory file) 15) "/")))
  (setq csproj-file (concat "c:/iis/wwwroot/mb/" csproj "/" csproj ".csproj"))
  ;; TODO add folder to csproj xml
  (let ((workdir (file-name-directory file))
        (project (first (split-string  (substring (file-name-directory file) 15) "/")))
        (project-dir (substring (file-name-directory file) 15 (- (length (file-name-directory file)) 1))))
(message (shell-command-to-string (concat "SAWSCmd.exe AddFolder "
                                     "-server " saws-server " "
                                     "-port " saws-port " "
                                     "-username \"" saws-username "\" "
                                     "-pwd \"" saws-password "\" "
                                     "-repository " saws-repository " "
                                     "-prj $/" project-dir " "
                                     "-workdir \"" workdir "\" "
                                     "-file \"" (file-name-nondirectory file) "\" "))))

  )

(defun saws-delete-file (&optional input-file)
  (interactive)
  (if (not (boundp 'input-file))
      (setq file (buffer-file-name)))

  (setq csproj (second (split-string  (substring (file-name-directory file) 15) "/")))
  (setq csproj-file (concat "c:/iis/wwwroot/mb/" csproj "/" csproj ".csproj"))

  (saws-remove-from-csproj csproj-file file)

  (let ((workdir (file-name-directory file))
        (project (first (split-string  (substring (file-name-directory file) 15) "/")))
        (project-dir (substring (file-name-directory file) 15 (- (length (file-name-directory file)) 1))))
(message (shell-command-to-string (concat "SAWSCmd.exe Delete "
                                     "-server " saws-server " "
                                     "-port " saws-port " "
                                     "-username \"" saws-username "\" "
                                     "-pwd \"" saws-password "\" "
                                     "-repository " saws-repository " "
                                     "-prj $/" project-dir " "
                                     "-workdir \"" workdir "\" "
                                     "-file \"" (file-name-nondirectory file) "\" ")))))

(defun saws-add-to-csproj (proj-file file)
  "These attempt to keep the Visual Studio project files in check since we're going against the flow so much"
  (saws-check-out-file proj-file)
  (let (csproj-buffer)
    (setq csproj-buffer (find-file proj-file))
    (setq include (substring file (length (file-name-directory proj-file))))
    (buffer-end 1)
    (search-backward "<Content Include")
    (move-end-of-line 1)
    (insert "\n")
    (insert (concat "<Content Include=\"" include "\" />"))
    (save-buffer)
    (kill-buffer csproj-buffer))
  (saws-check-in-file proj-file (concat "Added file: " file)))

(defun saws-remove-from-csproj (proj-file file)
  "These attempt to keep the Visual Studio project files in check since we're going against the flow so much"
  (saws-check-out-file proj-file)
  (let (csproj-buffer)
    (setq csproj-buffer (find-file proj-file))
    (setq include (substring file (length (file-name-directory proj-file))))
    (goto-char (point-min))
    (search-forward include)
    (move-beginning-of-line 1)
    (kill-line 2)
    (save-buffer)
    (kill-buffer csproj-buffer))
  (saws-check-in-file proj-file (concat "Removed file: " file)))

(global-set-key (kbd "C-c s o") 'saws-check-out-file)
(global-set-key (kbd "C-c s i") 'saws-check-in-file)
(global-set-key (kbd "C-c s u") 'saws-undo-check-out-file)
(global-set-key (kbd "C-c s g") 'saws-get-latest-file)
;;(global-set-key (kbd "C-c s i") 'saws-get-file-info)
(global-set-key (kbd "C-c s h") 'saws-get-file-history)
(global-set-key (kbd "C-c s a") 'saws-add-file)
