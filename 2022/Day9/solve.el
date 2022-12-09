;;; -*- lexical-binding: t; -*-
(defun read-file ()
  (interactive)
  (->> (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n")
       (--filter (not (string-empty-p it)))))

(defun move-head (head direction)
  (cl-case direction
    ('U (cons (car head) (1+ (cdr head))))
    ('D (cons (car head) (1- (cdr head))))
    ('R (cons (1+ (car head)) (cdr head)))
    ('L (cons (1- (car head)) (cdr head)))))

(defun distance (u v)
  (round (+ (expt (- (car u) (car v)) 2)
            (expt (- (cdr u) (cdr v)) 2))))

(defun sign (x)
  (cond ((eq x 0) 0)
        ((< x 0) -1)
        ((> x 0) 1)))

(defun move-tail (head tail)
  (if (<= (distance head tail) 2)
      tail
    (cons (+ (car tail) (sign (- (car head) (car tail))))
          (+ (cdr tail) (sign (- (cdr head) (cdr tail)))))))

(defmacro --mapc (form list)
  (declare (debug (def-form form)))
  `(mapc (lambda (it) (ignore it) ,form) ,list))

(defun solve ()
  (interactive)
  (let ((head (cons 0 0))
        (tail (cons 0 0))
        (dict (list))
        (-compare-fn #'equal))
    (->> (read-file)
         (-map #'split-string)
         (--map (list (intern (car it)) (string-to-number (cadr it))))
         (--mapc (let ((dir (car it))
                       (n (cadr it)))
                   (--dotimes n
                     (setq head (move-head head dir))
                     (setq tail (move-tail head tail))
                     (push tail dict)))))
    (message "Solution 1: %s" (length (-uniq dict)))))

(defun solve2 ()
  (interactive)
  (let ((snake (--map (cons 0 0) (number-sequence 0 9)))
        (dict (list))
        (-compare-fn #'equal))
    (->> (read-file)
         (-map #'split-string)
         (--map (list (intern (car it)) (string-to-number (cadr it))))
         (--mapc (let ((dir (car it))
                       (n (cadr it)))
                   (--dotimes n
                     (--each-indexed snake
                       (if (eq 0 it-index)
                           (setf (car snake)
                                 (move-head it dir))
                         (setf (elt snake it-index)
                               (move-tail (elt snake (1- it-index)) it)))
                       (push (-last-item snake) dict))))))
    (message "Solution 2: %s" (length (-uniq dict)))))
