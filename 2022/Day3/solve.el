(defun read-file ()
  (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n" t " "))

(defun solve ()
  (interactive)
  (->> (read-file)
       (--map (let ((c (car (-intersection
                             (string-to-list (substring it 0 (/ (length it) 2)))
                             (string-to-list (substring it (/ (length it) 2 -1)))))))
                (cond ((and (<= c ?z) (>= c ?a)) (- c 96))
                      (t (+ 27 (- c ?A))))))
       (-sum)
       (message "Solution 1: %d")))

(defun solve2 ()
  (interactive)
  (->> (read-file)
       (--map-indexed (list it-index it))
       (--partition-after-pred (= (mod (car it) 3) 2))
       (--map (-flatten (-map #'-last-item it)))
       (--map (-map #'string-to-list it))
       (--map (-intersection (-intersection
                              (-first-item it)
                              (-second-item it))
                             (-last-item it)))
       (-flatten)
       (--map (cond ((and (<= it ?z) (>= it ?a)) (- it 96))
                    (t (+ 27 (- it ?A)))))
       (-sum)
       (message "Solution 2: %d")))
