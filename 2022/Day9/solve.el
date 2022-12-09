;;; -*- lexical-binding: t; -*-
(defun read-file ()
  (interactive)
  (->> (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n")
       (--filter (not (string-empty-p it)))))

(defun move-head (head direction)
  (let ((last-head (-last-item head)))
    (cl-case direction
      ('U (append head (list (cons (car last-head) (1+ (cdr last-head)))) nil))
      ('D (append head (list (cons (car last-head) (1- (cdr last-head)))) nil))
      ('R (append head (list (cons (1+ (car last-head)) (cdr last-head))) nil))
      ('L (append head (list (cons (1- (car last-head)) (cdr last-head))) nil)))))

(defun distance (u v)
  (round (expt (sqrt (+ (expt (- (car u)
                                 (car v)) 2)
                        (expt (- (cdr u)
                                 (cdr v)) 2))) 2)))

(defun sign (x)
  (cond ((eq x 0) 0)
        ((< x 0) -1)
        ((> x 0) 1)))

(defun move-tail (head tail)
  (let ((lh (-last-item head))
        (lt (-last-item tail)))
    (append
     tail
     (if (>= 2 (distance lh lt))
         (list (-last-item tail))
       (list (cons (+ (car lt) (sign (- (car lh) (car lt)))) (+ (cdr lt) (sign (- (cdr lh) (cdr lt)))))))
     nil)))

(defmacro --mapc (form list)
  (declare (debug (def-form form)))
  `(mapc (lambda (it) (ignore it) ,form) ,list))

(defun solve ()
  (interactive)
  (let ((head (list (cons 0 0)))
        (tail (list (cons 0 0)))
        (-compare-fn #'equal))
    (->> (read-file)
         (-map #'split-string)
         (--map (list (intern (car it)) (string-to-number (cadr it))))
         (--mapc (let ((dir (car it))
                       (n (cadr it)))
                   (--dotimes n
                     (setq head (move-head head dir))
                     (setq tail (move-tail head tail))))))
    (message "Solution 1: %s" (length (-uniq tail)))))

(defun solve2 ()
  (interactive)
  (let ((snake (--map (list (cons 0 0)) (number-sequence 0 9)))
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
                               (move-tail (elt snake (1- it-index)) it))))))))
    (message "Solution 2: %s" (length (-uniq (-last-item snake))))))
