;;; (subset posix-processes (make-signal-queue
;;;                          wait-for-child-process
;;;                          exec-file
;;;                          signal
;;;                          fork
;;;                          exec))
;;; (subset formats (format))
;;; (subset srfi-1 (fold-right first second))

(define (file-head includes)
  (apply string-append
         `(
"#include <stdio.h>
#include <string.h>
#include <stdlib.h>
"
,@(map (lambda (include)
         (string-append "#include <" (symbol->string include) ">\n"))
       includes)
"#define BOOLEAN unsigned char
#define TRUE 1
#define FALSE 0

typedef struct {
  BOOLEAN somethingp;
  int value;
} maybe_int;

typedef struct {
  char * first;
  maybe_int second;
} pair;

int main() {
  pair values[] = {")))

(define (c-print-array-as-sexp name length)
  (string-append
   "};
  FILE * sexpr_file = fopen(\"" (symbol->string name) ".sexpr\", \"w\");

  fprintf(sexpr_file, \"(\");

  int i;
  for (i=0; i < " (number->string length) "; i++) {\n
    char * scheme_name = values[i].first;
    maybe_int maybe_value = values[i].second;

    if (maybe_value.somethingp) {
      fprintf(sexpr_file,
              \"(\\\"%s\\\" %i)\\n\",
              scheme_name,
              maybe_value.value);
    } else {
      fprintf(sexpr_file,
              \"(\\\"%s\\\" #f)\\n\",
              scheme_name);
    }
  }

  fprintf(sexpr_file, \")\");
  fclose(sexpr_file);
  return 0;
}
"))


(define (create-value-def-pair id+constant)
  (let ((scheme-id (first id+constant))
        (c-macro (second id+constant)))
    (format #f "{\"~a\",\n#ifdef ~a\n{TRUE, ~a}\n#else\n{FALSE, 0}\n#endif\n}"
            scheme-id c-macro c-macro)))

(define (create-array ids+constants)
  (fold-right
   (lambda (x xs)
     (string-append (create-value-def-pair x)
                    (if (equal? xs "")
                        ""
                        ",")
                    xs)) "" ids+constants))

(define (make-c-program name includes ids+constants)
  (string-append (file-head includes)
                 (create-array ids+constants)
                 (c-print-array-as-sexp name (length ids+constants))))

(define (system file? . args)
  (let ((pid? (fork)))
    (if pid?
        (wait-for-child-process pid?)
        (if file? (apply exec-file args) (apply exec args)))))

(define (sexpr-exists? name)
  (any (lambda (x) (string=? (os-string->string x) name))
       (list-directory "./")))

(define (generate-sexpr name includes pairs)
  (call-with-output-file "generate-tty-consts.c"
    (lambda (out)
      (display (make-c-program name includes pairs) out)))
  (system #f "cc" "generate-tty-consts.c")
  (system #t "./a.out")
  (system #f "rm" "a.out" "generate-tty-consts.c"))

(define (get-value-pairs-from-c name includes pairs)
  (let ((file-name (string-append (symbol->string name) ".sexpr")))
    (if (not (sexpr-exists? file-name))
        (generate-sexpr name includes pairs))
    (call-with-input-file file-name
      (lambda (in)
        (read in)))))
