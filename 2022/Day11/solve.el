;;; -*- lexical-binding: t; -*-
(defun read-file ()
  (interactive)
  (->> (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n\n")
       (--filter (not (string-empty-p it)))))

(defmacro --mapc (form list)
  (declare (debug (def-form form)))
  `(mapc (lambda (it) (ignore it) ,form) ,list))

(defun lambdize (tokens)
  (lambda (it) (funcall (intern (cadr tokens))
                        it
                        (if (string-equal "old" (caddr tokens)) it
                          (string-to-number (caddr tokens))))))

(defun parse-monkey (str)
  (append
   (->> (--filter (not (string-empty-p it)) (split-string str "\n"))
        (-map #'string-trim)
        (cdr)
        (--map (cond
                ((string-prefix-p "Starting items" it)
                 (--map (string-to-number (string-trim it)) (split-string (cadr (split-string it ":")) ",")))
                ((string-prefix-p "Operation" it)
                 (lambdize (-map #'string-trim
                                 (--filter
                                  (not (string-empty-p it))
                                  (split-string (cadr (split-string it "=")) " ")))))
                ((string-prefix-p "Test" it)
                 (string-to-number (-last-item (split-string it " "))))
                ((string-prefix-p "If" it)
                 (string-to-number (-last-item (split-string it " ")))))))
   (list 0) nil))

(defun solve ()
  (interactive)
  (let ((monkeys (-map #'parse-monkey (read-file))))
    (--dotimes 20
      (--mapc
       (let ((monkey it))
         (--mapc
          (let* ((worry it)
                 (new-worry (/ (funcall (nth 1 monkey) worry) 3))
                 (next-monkey (nth (if (eq 0 (mod new-worry (nth 2 monkey))) 3 4) monkey)))
            (setf (elt monkey 5) (1+ (elt monkey 5)))
            (setf (elt (elt monkeys next-monkey) 0)
                  (append (elt (elt monkeys next-monkey) 0) (list new-worry) nil)))
          (nth 0 monkey))
         (setf (elt monkey 0) (list)))
       monkeys))
    (-product (-take 2 (-sort #'> (-map #'-last-item monkeys))))))

(defun solve2 ()
  (interactive)
  (let* ((monkeys (-map #'parse-monkey (read-file)))
         (modulo (-product (--map (nth 2 it) monkeys))))
    (--dotimes 10000
      (--mapc
       (let ((monkey it))
         (--mapc
          (let* ((worry it)
                 (new-worry (mod (funcall (nth 1 monkey) worry) modulo))
                 (next-monkey (nth (if (eq 0 (mod new-worry (nth 2 monkey))) 3 4) monkey)))
            (setf (elt monkey 5) (1+ (elt monkey 5)))
            (setf (elt (elt monkeys next-monkey) 0)
                  (append (elt (elt monkeys next-monkey) 0) (list new-worry) nil)))
          (nth 0 monkey))
         (setf (elt monkey 0) (list)))
       monkeys))
    (-product (-take 2 (-sort #'> (-map #'-last-item monkeys))))))
