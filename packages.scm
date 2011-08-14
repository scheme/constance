(define-structure constance-syntax-help (export get-value-pairs-from-c)
  (open scheme
        (subset posix-processes (wait-for-child-process
                                 exec-file
                                 fork
                                 exec))
        (subset posix-files (list-directory))
        (subset os-strings (os-string->string))
        (subset formats (format))
        (subset srfi-1 (fold-right first second any)))
  (files constance-syntax-help))

(define-structure constance (export (define-constance :syntax))
  (open scheme)
  (for-syntax (open scheme
                    constance-syntax-help
                    (subset srfi-1 (first second))))
  (files constance))
