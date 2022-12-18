;;; -*- lexical-binding: t; -*-
(defun read-file ()
  (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n" t))

(defun line (head tail)
  (cond
   ((< (car head) (car tail))
    (--map (list it (cadr head)) (number-sequence (car head) (car tail))))
   ((< (cadr head) (cadr tail))
    (--map (list (car head) it) (number-sequence (cadr head) (cadr tail))))
   ((> (car head) (car tail))
    (--map (list it (cadr head)) (number-sequence (car head) (car tail) -1)))
   ((> (cadr head) (cadr tail))
    (--map (list (car head) it) (number-sequence (cadr head) (cadr tail) -1)))))

(defun parse ()
  (->> (read-file)
       (--map (--map (-map #'string-to-number (split-string it ","))
                     (split-string it "->" t " ")))
       (--map (--reduce-from (append acc (line (-last-item acc) it))
                             (list (car it))
                             (cdr it)))
       (-flatten-n 1)
       (-uniq)))

(defun fall (from rocks sand)
  (let* ((run t)
         (answer nil)
         (obstacles (append rocks sand))
         (lowest-y (cadr (--max-by (> (cadr it) (cadr other)) obstacles)))
         (pos from))
    (while run
      (cond
       ((> (cadr pos) (+ 3 lowest-y)) (setq run nil))
       ((not (-contains-p obstacles (list (car pos) (1+ (cadr pos)))))
        (setq pos (list (car pos) (1+ (cadr pos)))))
       ((not (-contains-p obstacles (list (1- (car pos)) (1+ (cadr pos)))))
        (setq pos (list (1- (car pos)) (1+ (cadr pos)))))
       ((not (-contains-p obstacles (list (1+ (car pos)) (1+ (cadr pos)))))
        (setq pos (list (1+ (car pos)) (1+ (cadr pos)))))
       ((equal from pos) (setq run nil))
       (t (setq answer (append sand (list pos)) run nil))))
    answer))

(defun draw (source rocks sand)
  (let* ((source (if (listp (car source)) source (list source)))
         (items (append rocks sand source))
         (min-x (-min (--map (car it) items)))
         (max-x (-max (--map (car it) items)))
         (min-y (-min (--map (cadr it) items)))
         (max-y (-max (--map (cadr it) items))))
    (--> (--map
          (let ((j it))
            (--map
             (let ((i it))
               (cond
                ((-contains-p rocks (list i j))  "#")
                ((-contains-p sand (list i j))   "O")
                ((-contains-p source (list i j)) "+")
                (t ".")))
             (number-sequence min-x max-x)))
          (number-sequence min-y max-y))
         (-map #'string-join it)
         (string-join it "\n"))))

(defun solve ()
  (interactive)
  (let ((sand (list))
        (rocks (parse))
        (start (list 500 0))
        (new-sand (list))
        (run t))
    (while run
      (setq new-sand (fall start rocks sand))
      (if new-sand
          (setq sand new-sand)
        (setq run nil)))
    (message "%s" (draw start rocks sand))
    (message "%d" (length sand))))

(defun solve2 ()
  (interactive)
  (let* ((sand (list))
         (rocks (parse))
         (floor-y (+ 2 (-max (--map (cadr it) rocks))))
         (rocks (append rocks (--map (list it floor-y) (number-sequence 0 1000))))
         (start (list 500 0))
         (new-sand (list))
         (run t))
    (while run
      (setq new-sand (fall start rocks sand))
      (if new-sand
          (setq sand new-sand)
        (setq run nil)))
    (message "%s" (draw start rocks sand))
    (message "%d" (1+ (length sand)))))
