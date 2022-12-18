;;; -*- lexical-binding: t; -*-
(defun read-file ()
  (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n" t))

(defun parse-sensor (line)
  (->> (split-string line " " t " ")
       (--filter (or (s-starts-with? "x" it) (s-starts-with? "y" it)))
       (--map (cadr (split-string it "=")))
       (--map (replace-regexp-in-string "[,:]" "" it))
       (-map #'string-to-number)))

(defun manhattan (p1 p2)
  (+ (abs (- (car p1) (car p2)))
     (abs (- (cadr p1) (cadr p2)))))

(defun in-region-p (coord sensor)
  (<= (manhattan coord (-take 2 sensor))
      (manhattan (-take 2 sensor) (-drop 2 sensor))))

(defun covered-p (coord sensors)
  (--any-p it (--map (in-region-p coord it) sensors)))

(defun sensor-range (sensor)
  (let ((d (manhattan (-take 2 sensor) (-drop 2 sensor))))
    (list (list (+ d (car sensor)) (cadr sensor))
          (list (car sensor) (+ d (cadr sensor)))
          (list (- (car sensor) d) (cadr sensor))
          (list (car sensor) (- (cadr sensor) d)))))

(defun sensor-touches-row (row sensor)
  (--any-p (eq row it) (--map (cadr (-sort #'< `(,row ,(cadr it) ,(cadr sensor)))) (sensor-range sensor))))

(defun points-in-row (row sensor)
  (let ((points (list))
        (current `(,(car sensor) ,row)))
    (while (in-region-p current sensor)
      (push current points)
      (setq current `(,(1- (car current)) ,row)))
    (setq current `(,(car sensor) ,row))
    (while (in-region-p current sensor)
      (push current points)
      (setq current `(,(1+ (car current)) ,row)))
    points))

(defun scanned-pos-in-row (row sensors)
  (let* ((sensors (--filter (sensor-touches-row row it) sensors))
         (drones (--map (-take 2 it) sensors))
         (beacons (--map (-drop 2 it) sensors)))
    (->> sensors
         (--map (points-in-row row it))
         (-flatten-n 1)
         (--filter (and (not (-contains-p beacons it))
                        (not (-contains-p drones it))))
         (-uniq))))

(defun solve ()
  (interactive)
  (message "%s" (-map #'parse-sensor (read-file)))
  (->> (read-file)
       (-map #'parse-sensor)
       ;; (scanned-pos-in-row 10)
       (scanned-pos-in-row 2000000)
       (length)
       (message "Solution 1: %s")))

(defun lines-of-sensor (sensor)
  (let* ((edges (sensor-range sensor))
         (right (list (1+ (car (nth 0 edges))) (cadr (nth 0 edges))))
         (top (list (car (nth 1 edges)) (1+ (cadr (nth 1 edges)))))
         (left (list (1- (car (nth 2 edges))) (cadr (nth 2 edges))))
         (bottom (list (car (nth 3 edges)) (1- (cadr (nth 3 edges))))))
    `((,top ,right) (,top ,left) (,bottom ,right) (,bottom ,left))))

(defun line-intersection (l1 l2)
  (let ((x1 (caar   l1)) (x3 (caar   l2))
        (x2 (caadr  l1)) (x4 (caadr  l2))
        (y1 (cadar  l1)) (y3 (cadar  l2))
        (y2 (cadadr l1)) (y4 (cadadr l2)))
    `(,(/ (float (- (* (- (* x1 y2)
                   (* y1 x2))
                (- x3 x4))
             (* (- x1 x2)
                (- (* x3 y4)
                   (* y3 x4)))))
          (- (* (- x1 x2)
                (- y3 y4))
             (* (- y1 y2)
                (- x3 x4))))
      ,(/ (float (- (* (- (* x1 y2)
                   (* y1 x2))
                (- y3 y4))
             (* (- y1 y2)
                (- (* x3 y4)
                   (* y3 x4)))))
          (- (* (- x1 x2)
                (- y3 y4))
             (* (- y1 y2)
                (- x3 x4)))))))

(defun all-intersections (lines)
  (let ((i 0)
        (j 0)
        (points (list)))
    (while (< i (length lines))
      (while (< j (length lines))
        (when (not (eq i j))
          (ignore-errors
            (push (line-intersection (nth i lines) (nth j lines)) points)))
        (setq j (1+ j)))
      (setq i (1+ i) j 0))
    points))

(defun square-around-point (x y)
  `((,(1+ x) ,y     ) (,(1- x) ,(1- y))
    (,(1- x) ,y     ) (,(1+ x) ,(1- y))
    (,x      ,(1+ y)) (,(1- x) ,(1+ y))
    (,x      ,(1- y)) (,(1+ x) ,(1+ y))))

(defun solve2 ()
  (interactive)
  (let ((sensors (-map #'parse-sensor (read-file))))
    (->> sensors
         (-map #'lines-of-sensor)
         (-flatten-n 1)
         (all-intersections)
         (--filter (and (<= (car it)  4000000)
                        (<= (cadr it) 4000000)
                        (>= (car it)  0)
                        (>= (cadr it) 0)))
         (--map (-map #'round it))
         (-uniq)
         (--map (square-around-point (car it) (cadr it)))
         (-flatten-n 1)
         (-uniq)
         (--map (square-around-point (car it) (cadr it)))
         (-flatten-n 1)
         (-uniq)
         (--filter (not (covered-p it sensors)))
         (--reduce-from (+ (* 4000000 (car it)) (cadr it)) 0)
         (message "Solution 2: %s"))))
