(defun read-file ()
  (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n" t " "))

(defun solve ()
  (interactive)
  (let ((file (string-to-list (car (read-file)))))
    (->> file
         (--take-while (list-utils-dupes (-slice file it-index (+ it-index 4))))
         (length)
         (+ 4)
         (message "Solution 1: %s"))))

(defun solve2 ()
  (interactive)
  (let ((file (string-to-list (car (read-file)))))
    (->> file
         (--take-while (list-utils-dupes (-slice file it-index (+ it-index 14))))
         (length)
         (+ 14)
         (message "Solution 2: %s"))))
