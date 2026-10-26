;;; extract-agda-input.el --- Dump the fully-resolved Agda input method to Lua
(load-file (expand-file-name "agda-input.el" default-directory))

;; hash-table-keys was added in Emacs 29.1.
(unless (fboundp 'hash-table-keys)
  (defun hash-table-keys (table)
    "Return a list of keys in TABLE."
    (let (keys)
      (maphash (lambda (k _v) (push k keys)) table)
      keys)))

(defun agda--lua-escape (s)
  "Escape S for use in a Lua double-quoted string."
  (let ((out ""))
    (dolist (c (string-to-list s) out)
      (setq out
            (concat out
                    (cond ((= c ?\")  "\\\"")
                          ((= c ?\\)  "\\\\")
                          ((= c ?\n)  "\\n")
                          ((< c 32)   (format "\\%03d" c))
                          (t          (char-to-string c))))))))

(defun agda--translation-list (trans)
  "Normalize TRANS to a list of strings.
TRANS may be:
- an integer character code          -> (\"X\")
- a string                            -> split into one-char strings
- a vector of strings or of integers  -> list of strings
- a list of integers                  -> list of strings"
  (cond
   ((integerp trans) (list (char-to-string trans)))
   ((stringp trans)  (mapcar #'char-to-string (string-to-list trans)))
   ((vectorp trans)
    (mapcar (lambda (x) (if (integerp x) (char-to-string x) x))
            (append trans nil)))
   ((listp trans)
    (mapcar (lambda (x) (if (integerp x) (char-to-string x) x)) trans))
   (t (error "Unexpected translation type: %S" trans))))

(let ((by-key (make-hash-table :test 'equal)))
  ;; pair = (KEY-SEQUENCE . TRANSLATION)  <-- car = key, cdr = translation
  (dolist (pair (agda-input-get-translations "Agda"))
    (let* ((key      (car pair))
           (chars    (agda--translation-list (cdr pair)))
           (existing (gethash key by-key)))
      (puthash key (append existing chars) by-key)))

  (with-temp-file "agda_input_data.lua"
    (insert "-- Auto-generated from agda-input.el. Do not edit.\n")
    (insert "-- Regenerate with extract-agda-input.el.\n")
    (insert "return {\n")
    (dolist (key (sort (hash-table-keys by-key) #'string<))
      (insert (format "  [\"%s\"] = {\n" (agda--lua-escape key)))
      (dolist (c (gethash key by-key))
        (insert (format "    \"%s\",\n" (agda--lua-escape c))))
      (insert "  },\n"))
    (insert "}\n"))

  ;; Sanity report on stderr.
  (let ((n-keys 0) (n-trans 0))
    (maphash (lambda (_k v)
               (cl-incf n-keys)
               (cl-incf n-trans (length v)))
             by-key)
    (message "agda-input: %d keys, %d total translations" n-keys n-trans)))
