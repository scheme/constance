(define-syntax define-constance
  (lambda (e rename c)
    (let* ((alist-name (cadr e))
           (c-headers  (caddr e))
           (pairs      (cadddr e))
           (results    (get-value-pairs-from-c alist-name c-headers pairs)))
      `(,(rename 'begin)
        ,@(map (lambda (pair)
                 `(,(rename 'define) ,(string->symbol (first pair))
                                     ,(second pair)))
               results)))))

;; (define-constance alist-name
;;   (headers ...)
;;   ((id c-macro)
;;    (id2 c-macro2)
;;    ...))
;; =>
;; (begin (define id value)
;;        (define id2 value2))
;; where value is the value of c-macro in the environment of a c program with
;; the header files specified by c-headers
