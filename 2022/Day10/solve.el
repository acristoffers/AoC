;;; -*- lexical-binding: t; -*-
(defun read-file ()
  (interactive)
  (->> (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n")
       (--filter (not (string-empty-p it)))))

(defun solve ()
  (interactive)
  (let ((X 1))
    (->> (read-file)
         (--map (cond
                 ((string-equal "noop" it) (list X))
                 (t (let ((z X)
                          (y (string-to-number (cadr (split-string it)))))
                      (setq X (+ X y))
                      (list z z)))))
         (-flatten)
         (--map-indexed (cons (1+ it-index) it))
         (--filter (-contains? '(20 60 100 140 180 220) (car it)))
         (--map (* (car it) (cdr it)))
         (-sum))))

(defun solve2 ()
  (interactive)
  (let ((X 1))
    (message "%s"
             (string-join
              (->> (read-file)
                   (--map (cond
                           ((string-equal "noop" it) (list X))
                           (t (let ((z X)
                                    (y (string-to-number (cadr (split-string it)))))
                                (setq X (+ X y))
                                (list z z)))))
                   (-flatten)
                   (-partition 40)
                   (--map (--map-indexed (if (<= (abs (- it-index it)) 1) "#" ".") it))
                   (-map #'string-join))
              "\n"))))
