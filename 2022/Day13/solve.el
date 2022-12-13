;;; -*- lexical-binding: t; -*-
(defun read-file ()
  (interactive)
  (->> (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n")
       (--filter (not (string-empty-p it)))))

(defun compare (it other)
  (cond
   ((and (numberp it) (numberp other)) (cond ((< it other) -1)
                                             ((eq it other) 0)
                                             (t 1)))
   ((and (numberp it) (listp other)) (compare (list it) other))
   ((and (listp it) (numberp other)) (compare it (list other)))
   ;; From now on, both are lists. I won't keep checking for that.
   ((and (seq-empty-p it) (not (seq-empty-p other))) -1)
   ((and (not (seq-empty-p it)) (seq-empty-p other)) 1)
   ((and (seq-empty-p it) (seq-empty-p other)) 0)
   (t (let ((v (compare (pop it) (pop other))))
        (while (and (eq 0 v) it other)
          (setq v (compare (pop it) (pop other))))
        (cond
         ((and (eq v 0) (length> it (length other))) 1)
         ((and (eq v 0) (length< it (length other))) -1)
         (t v))))))

(defun solve ()
  (interactive)
  (->> (read-file)
       (--map (string-replace "[" "(" it))
       (--map (string-replace "]" ")" it))
       (--map (string-replace "," " " it))
       (--map (eval (car (read-from-string (concat "'" it)))))
       (-partition 2)
       (--map (compare (car it) (cadr it)))
       (--map-indexed (list (1+ it-index) it))
       (--filter (< (cadr it) 1))
       (-map #'car)
       (-sum)
       (message "Solution 1: %d")))

(defun solve2 ()
  (interactive)
  (->> (read-file)
       (--map (string-replace "[" "(" it))
       (--map (string-replace "]" ")" it))
       (--map (string-replace "," " " it))
       (--map (eval (car (read-from-string (concat "'" it)))))
       (append '(((2))) '(((6))))
       (--sort (eq -1 (compare it other)))
       (--map-indexed (list (1+ it-index) it))
       (--filter (or (equal (cadr it) '((2))) (equal (cadr it) '((6)))))
       (-map #'car)
       (-product)
       (message "Solution 2: %s")))
