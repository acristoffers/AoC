(defun win? (m)
  (or (list-utils-safe-equal m '(?A ?Y))
      (list-utils-safe-equal m '(?B ?Z))
      (list-utils-safe-equal m '(?C ?X))))

(defun score (m)
  (+ (if (win? m) 6 (if (char-equal (+ (-first-item m) 23) (-last-item m)) 3 0))
     (- (-last-item m) 87)))

(defun solve ()
  (interactive)
  (->> (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n")
       (-filter (lambda (x) (not (string-empty-p x))))
       (-map (lambda (x) (-map #'string-to-char (split-string x " "))))
       (-map #'score)
       (-sum)))

(defun score2 (m)
  (+ (cl-case (-last-item m)
       (?X 0)
       (?Y 3)
       (?Z 6))
     (nth (mod (+ (cl-case (-last-item m)
                    (?X -1)
                    (?Y 0)
                    (?Z 1)) (- (-first-item m) ?A)) 3) '(1 2 3))))

(defun solve2 ()
  (interactive)
  (->> (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n")
       (-filter (lambda (x) (not (string-empty-p x))))
       (-map (lambda (x) (-map #'string-to-char (split-string x " "))))
       (-map #'score2)
       (-sum)))
