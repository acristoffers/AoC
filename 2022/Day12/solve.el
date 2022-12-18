;;; -*- lexical-binding: t; -*-
(defun read-file ()
  (->> (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n" t " ")
       (-map #'string-to-list)))

(defun at (mapa i j)
  (if (or (< i 0) (< j 0) (>= i (length mapa)) (>= j (length (car mapa))))
      nil (nth j (nth i mapa))))

(defun can-walk? (current neighbour)
  (let ((current (car current))
        (neighbour (car neighbour)))
    (when (eq current ?S) (setq current ?a))
    (when (eq current ?E) (setq current ?z))
    (when (eq neighbour ?E) (setq neighbour ?z))
    (or (eq current neighbour)
        (eq (1+ current) neighbour)
        (> current neighbour))))

(defun fh (node parent target mapa set)
  (let* ((parent-node (apply #'at mapa parent))
         (f (1+ (nth 1 parent-node)))
         (h (+ (abs (- (car target) (car node)))
               (abs (- (cadr target) (cadr node))))))
    (when set
      (setf (elt (elt (elt mapa (car node)) (cadr node)) 1) f)
      (setf (elt (elt (elt mapa (car node)) (cadr node)) 2) h)
      (setf (elt (elt (elt mapa (car node)) (cadr node)) 3) (+ f h))
      (setf (elt (elt (elt mapa (car node)) (cadr node)) 4) parent))
    f))

(defun a-star (start target mapa)
  (let ((open (list start))
        (closed (list))
        (current start))
    (while (not (equal current target))
      (setq current (--min-by (> (nth 3 (apply #'at mapa it))
                                 (nth 3 (apply #'at mapa other)))
                              open))
      (push current closed)
      (setq open (--remove (equal it current) open))
      (--each '((1 0) (0 1) (0 -1) (-1 0))
        (let ((neighbour (list (+ (car it) (car current))
                               (+ (cadr it) (cadr current)))))
          (when (apply #'at mapa neighbour)
            (when (and (not (-contains? closed neighbour))
                       (can-walk? (apply #'at mapa current)
                                  (apply #'at mapa neighbour)))
              (when (or (< (fh neighbour current target mapa nil)
                           (nth 1 (apply #'at mapa neighbour)))
                        (not (-contains? open neighbour)))
                (fh neighbour current target mapa t)
                (when (not (-contains? open neighbour))
                  (push neighbour open)))))))))
  mapa)

(defun walk-back (start target mapa)
  (let ((path (list))
        (current target))
    (while (not (equal current start))
      (push current path)
      (setq current (-last-item (apply #'at mapa current))))
    (push start path)
    path))

(defun solve ()
  (interactive)
  (let* ((file (read-file))
         (start (cdar (--filter (equal ?S (car it))
                                (-flatten-n 1 (--map-indexed
                                               (let ((i it-index))
                                                 (--map-indexed
                                                  (list it i it-index)
                                                  it))
                                               file)))))
         (target (cdar (--filter (equal ?E (car it))
                                 (-flatten-n 1 (--map-indexed
                                                (let ((i it-index))
                                                  (--map-indexed
                                                   (list it i it-index)
                                                   it))
                                                file))))))
    (--> file
         ;; '(char f h f+h parent)
         (--map (--map (list it 0 0 0 start) it) it)
         (a-star start target it)
         (walk-back start target it)
         (length it)
         (1- it)
         (message "Solution 1: %s" it))))

(defun solve2 ()
  (interactive)
  (let* ((file (read-file))
         (target (cdar (--filter (equal ?E (car it))
                                 (-flatten-n 1 (--map-indexed
                                                (let ((i it-index))
                                                  (--map-indexed
                                                   (list it i it-index)
                                                   it))
                                                file))))))
    (->> (-map #'cdr (--filter (equal ?a (car it))
                               (-flatten-n 1 (--map-indexed
                                              (let ((i it-index))
                                                (--map-indexed
                                                 (list it i it-index)
                                                 it))
                                              file))))
         (--filter (eq 0 (cadr it)))
         (--map (let ((start it))
                  (--> (read-file)
                       ;; '(char f h f+h parent)
                       (--map (--map (list it 0 0 0 start) it) it)
                       (a-star start target it)
                       (walk-back start target it)
                       (length it)
                       (1- it))))
         (--filter it)
         (-min)
         (message "Solution 2: %s"))))
