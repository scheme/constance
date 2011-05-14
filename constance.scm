(define-syntax define-constance
  (lambda (e rename c)
    (define (get-value-pairs-from-c name x y) y)
    (let* ((alist-name (cadr e))
           (c-headers  (caddr e))
           (pairs      (cdddr e))
           (alist      (map (lambda (pair)
                              (cons (car pair) (cadr pair)))
                            pairs))
           (results    (get-value-pairs-from-c alist-name c-headers alist)))
      `(,(rename 'begin)
        ,@(map (lambda (pair)
                 `(,(rename 'define) ,(car pair) ,(cdr pair)))
               results)))))

;; (define-constance IDENTIFIER [LISTOF SYMBOL] [ASSOC-LIST SYMBOL STRING])
;; (define-constance alist-name c-headers (list (id . c-macro) ...))
;; =>
;; (define alist-name
;;   (list (id . value)
;;         ...))
;; where value is the value of c-macro in the environment of a c program with
;; the header files specified by c-headers
