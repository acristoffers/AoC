;;; -*- lexical-binding: t; -*-
(defun read-file ()
  (split-string (buffer-substring-no-properties (point-min) (point-max)) "\n" t " "))

(defun parse (node commands) ;; returns (children remaining-commands)
  (let ((ret nil))
    (while (and (not ret) commands)
      (let* ((current-command (car commands))
             (next-commands (cdr commands))
             (cmd (nth 1 (split-string (car current-command))))
             (args (cdr current-command)))
        (pcase cmd
          ("cd" (pcase (-last-item (split-string (car current-command)))
                  (".." (setq ret t))
                  (dir (setq node (--remove (string-equal dir (-first-item it)) node))
                       (let ((result (parse (list) next-commands)))
                         (setq node (append node (list (list dir (car result))))
                               next-commands (-last-item result))))))
          ("ls" (setq node (append
                            (->> args
                                 (--filter (string-prefix-p "dir" it))
                                 (--map (list (-last-item (split-string it)) (list))))
                            (->> args
                                 (--filter (not (string-prefix-p "dir" it)))
                                 (--map (split-string it))
                                 (--map (list (-last-item it) (string-to-number (car it)))))))))
        (setq commands next-commands))))
  (list node commands))

(defun folder-size (node)
  (->> node
       (-map #'-last-item)
       (--map (if (numberp it) it (folder-size it)))
       (-sum)))

(defun folder-size-recurse (node)
  (flatten-list
   (append (list (folder-size node))
           (->> node
                (-map #'-second-item)
                (-filter #'listp)
                (-map #'folder-size-recurse)))))

(defun solve ()
  (interactive)
  (->> (read-file)
       (-partition-before-pred (lambda (it) (string-prefix-p "$" it)))
       (cdr)
       (parse (list))
       (car)
       (folder-size-recurse)
       (--filter (<= it 100000))
       (-sum)
       (message "Solution 1: %d")))

(defun solve2 ()
  (interactive)
  (let ((sizes (->> (read-file)
                    (-partition-before-pred (lambda (it) (string-prefix-p "$" it)))
                    (cdr)
                    (parse (list))
                    (car)
                    (folder-size-recurse))))
    (message "Solution 2: %d" (-min (--filter (>= it (- 30000000 (- 70000000 (-max sizes)))) sizes)))))
