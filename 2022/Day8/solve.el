;;; -*- lexical-binding: t; -*-
(defun read-file ()
  (interactive)
  (->> (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n")
       (--filter (not (string-empty-p it)))))

(defun is-visible (i j grid gridt)
  (let* ((value (nth j (nth i grid)))
         (at-left   (-max (append '(0) (-slice (nth i grid)  0    j) nil)))
         (at-right  (-max (append '(0) (-slice (nth i grid)  (1+ j)) nil)))
         (at-top    (-max (append '(0) (-slice (nth j gridt) 0    i) nil)))
         (at-bottom (-max (append '(0) (-slice (nth j gridt) (1+ i)) nil))))
    (if (or (eq i 0)
            (eq j 0)
            (eq i (1- (length grid)))
            (eq j (1- (length grid)))
            (< (min at-left at-right at-bottom at-top) value))
        1 0)))

(defun scenic-score (i j grid gridt)
  (let* ((value (nth j (nth i grid)))
         (at-left   (car (--partition-after-pred (>= it value) (reverse (-slice (nth i grid)  0    j)))))
         (at-right  (car (--partition-after-pred (>= it value) (-slice (nth i grid)  (1+ j)))))
         (at-top    (car (--partition-after-pred (>= it value) (reverse (-slice (nth j gridt) 0    i)))))
         (at-bottom (car (--partition-after-pred (>= it value) (-slice (nth j gridt) (1+ i))))))
    (list at-left at-right at-top at-bottom)))

(defun -transpose (A)
  (let ((T (--map (--map 0 it) A)))
    (--each-indexed A
      (let ((i it-index))
        (--each-indexed it
          (let ((j it-index))
            (setf (elt (elt T j) i) (nth j (nth i A)))))))
    T))

(defun solve ()
  (interactive)
  (let* ((bf (--map (--map (- it ?0) (string-to-list it)) (read-file)))
         (bt (-transpose bf))
         (bs (--map (--map 1 it) bf)))
    (--each-indexed bf
      (let ((i it-index))
        (--each-indexed it
          (let ((j it-index))
            (setf (elt (elt bs i) j) (is-visible i j bf bt))))))
    (message "Solution 1: %d" (-sum (-flatten bs)))))

(defun solve2 ()
  (interactive)
  (let* ((bf (--map (--map (- it ?0) (string-to-list it)) (read-file)))
         (bt (-transpose bf))
         (bs (--map (--map 1 it) bf)))
    (--each-indexed bf
      (let ((i it-index))
        (--each-indexed it
          (let ((j it-index))
            (setf (elt (elt bs i) j) (-product (-map #'length (scenic-score i j bf bt))))))))
    (message "Solution 2: %d" (-max (-flatten bs)))))
