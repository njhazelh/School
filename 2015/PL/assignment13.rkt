#lang pl 13

;;; ==================================================================
;;; Syntax

#| The BNF:
   <TOY> ::= <num>
           | <id>
           | { set! <id> <TOY> }
           | { bind {{ <id> <TOY> } ... } <TOY> <TOY> ... }
           | { bindrec {{ <id> <TOY> } ... } <TOY> <TOY> ... }
           | { fun { <id> ... } <TOY> <TOY> ... }
           | { rfun { <id> ... } <TOY> <TOY> ... }
           | { if <TOY> <TOY> <TOY> }
           | { <TOY> <TOY> ... }
|#

;; A matching abstract syntax tree datatype:
(define-type TOY
  [Num  Number]
  [Id   Symbol]
  [Set  Symbol TOY]
  [Bind    (Listof Symbol) (Listof TOY) (Listof TOY)]
  [BindRec (Listof Symbol) (Listof TOY) (Listof TOY)]
  [Fun  (Listof Symbol) (Listof TOY)]
  [RFun (Listof Symbol) (Listof TOY)]
  [Call TOY (Listof TOY)]
  [If   TOY TOY TOY])

(: unique-list? : (Listof Any) -> Boolean)
;; Tests whether a list is unique, guards Bind and Fun values.
(define (unique-list? xs)
  (or (null? xs)
      (and (not (member (first xs) (rest xs)))
           (unique-list? (rest xs)))))

(: parse-sexpr : Sexpr -> TOY)
;; to convert s-expressions into TOYs
(define (parse-sexpr sexpr)
  (match sexpr
    [(number: n)    (Num n)]
    [(symbol: name) (Id name)]
    [(cons 'set! more)
     (match sexpr
       [(list 'set! (symbol: name) new) (Set name (parse-sexpr new))]
       [else (error 'parse-sexpr "bad `set!' syntax in ~s" sexpr)])]
    [(cons (and binder (or 'bind 'bindrec)) more)
     (match sexpr
       [(list _ (list (list (symbol: names) (sexpr: nameds)) ...)
              (sexpr: body0) (sexpr: body) ...)
        (if (unique-list? names)
            ((if (eq? 'bind binder) Bind BindRec)
             names
             (map parse-sexpr nameds)
             (map parse-sexpr (cons body0 body)))
            (error 'parse-sexpr "duplicate `~s' names: ~s" binder names))]
       [else (error 'parse-sexpr "bad `~s' syntax in ~s"
                    binder sexpr)])]
    [(cons (and funner (or 'fun 'rfun)) more)
     (match sexpr
       [(list _ (list (symbol: names) ...)
              (sexpr: body0) (sexpr: body) ...)
        (if (unique-list? names)
            ((if (eq? 'fun funner) Fun RFun)
             names
             (map parse-sexpr (cons body0 body)))
            (error 'parse-sexpr "duplicate `~s' names: ~s" funner names))]
       [else (error 'parse-sexpr "bad `~s' syntax in ~s"
                    funner sexpr)])]
    [(cons 'if more)
     (match sexpr
       [(list 'if cond then else)
        (If (parse-sexpr cond) (parse-sexpr then) (parse-sexpr else))]
       [else (error 'parse-sexpr "bad `if' syntax in ~s" sexpr)])]
    [(list fun (sexpr: args) ...) ; other lists are applications
     (Call (parse-sexpr fun)
           (map parse-sexpr args))]
    [else (error 'parse-sexpr "bad syntax in ~s" sexpr)]))

(: parse : String -> TOY)
;; Parses a string containing an TOY expression to a TOY AST.
(define (parse str)
  (parse-sexpr (string->sexpr str)))

;;; ==================================================================
;;; Values and environments

(define-type ENV
  [EmptyEnv]
  [FrameEnv FRAME ENV])

(define-type VAL
  [BogusV]
  [RktV  Any]
  [FunV  (Listof Symbol) (ENV -> VAL) ENV Boolean] ; `byref?' flag
  [PrimV ((Listof VAL) -> VAL)])

;; a frame is an association list of names and values.
(define-type FRAME = (Listof (List Symbol (Boxof VAL))))

;; a single bogus value to use wherever needed
(define the-bogus-value (BogusV))

(: raw-extend : (Listof Symbol) (Listof (Boxof VAL)) ENV -> ENV)
;; extends an environment with a new frame, given names and value
;; boxes
(define (raw-extend names boxed-values env)
  (if (= (length names) (length boxed-values))
      (FrameEnv (map (lambda ([name : Symbol] [boxed-val : (Boxof VAL)])
                       (list name boxed-val))
                     names boxed-values)
                env)
      (error 'raw-extend "arity mismatch for names: ~s" names)))

(: extend : (Listof Symbol) (Listof VAL) ENV -> ENV)
;; extends an environment with a new frame (given plain values).
(define (extend names values env)
  (raw-extend names (map (inst box VAL) values) env))

(: extend-rec : (Listof Symbol) (Listof (ENV -> VAL)) ENV -> ENV)
;; extends an environment with a new recursive frame (given
;; expressions).
;;
;; (define (extend-rec names exprs env)
;;   ;; note: no need to check the lengths here, since this is only
;;   ;; called for `bindrec', and the syntax make it impossible to have
;;   ;; different lengths
;;   (let* ([boxes   (map (lambda (x) (box the-bogus-value)) exprs)]
;;          [new-env (raw-extend names boxes env)])
;;     (for-each (lambda ([box : (Boxof VAL)] [expr : TOY])
;;                 (set-box! box (eval expr new-env)))
;;               boxes exprs)
;;     new-env))
;;
;; Slightly simpler version, as we've seen in class:
;;
(define (extend-rec names c-exprs env)
  (define new-env
    (extend names (map (lambda (_) the-bogus-value) c-exprs) env))
  ;; note: no need to check the lengths here, since this is only
  ;; called for `bindrec', and the syntax make it impossible to have
  ;; different lengths
  (for-each (lambda ([name : Symbol] [expr : (ENV -> VAL)])
              (set-box! (lookup name new-env) (expr new-env)))
            names c-exprs)
  new-env)

(: lookup : Symbol ENV -> (Boxof VAL))
;; looks for a name in an environment, searching through each frame.
(define (lookup name env)
  (cases env
    [(EmptyEnv) (error 'lookup "no binding for ~s" name)]
    [(FrameEnv frame rest)
     (let ([cell (assq name frame)])
       (if cell
           (second cell)
           (lookup name rest)))]))

(: unwrap-rktv : VAL -> Any)
;; helper for `racket-func->prim-val': unwrap a RktV wrapper in
;; preparation to be sent to the primitive function
(define (unwrap-rktv x)
  (cases x
    [(RktV v) v]
    [else (error 'racket-func "bad input: ~s" x)]))

(: racket-func->prim-val : Function -> (Boxof VAL))
;; converts a racket function to a primitive evaluator function which
;; is a PrimV holding a ((Listof VAL) -> VAL) function.  (the
;; resulting function will use the list function as is, and it is the
;; list function's responsibility to throw an error if it's given a
;; bad number of arguments or bad input types.)
(define (racket-func->prim-val racket-func)
  (define list-func (make-untyped-list-function racket-func))
  (box (PrimV (lambda (args)
                (RktV (list-func (map unwrap-rktv args)))))))

;; The global environment has a few primitives:
(: global-environment : ENV)
(define global-environment
  (FrameEnv (list (list '+ (racket-func->prim-val +))
                  (list '- (racket-func->prim-val -))
                  (list '* (racket-func->prim-val *))
                  (list '/ (racket-func->prim-val /))
                  (list '< (racket-func->prim-val <))
                  (list '> (racket-func->prim-val >))
                  (list '= (racket-func->prim-val =))
                  ;; values
                  (list 'true  (box (RktV #t)))
                  (list 'false (box (RktV #f))))
            (EmptyEnv)))

;;; ==================================================================
;;; Evaluation

(: compiler-enabled? : (Boxof Boolean))
;; a global flag that can disable the compiler
(define compiler-enabled? (box #f))

(: compile-body : (Listof TOY) -> (ENV -> VAL))
;; evaluates a list of expressions, returns the last value.
(define (compile-body exprs)
  ;; note: relies on the fact that the body is never empty
  (let ([1st (compile (first exprs))]
        [rst (if (not (null? (rest exprs)))
                 (compile-body (rest exprs))
                 null)])
    (if (null? rst)
        (lambda ([env : ENV]) (1st env))
        (lambda ([env : ENV]) (let ([_ (1st env)])
                                (rst env))))))

(: compile-get-boxes : (Listof TOY) -> (ENV -> (Listof (Boxof VAL))))
;; utility for applying rfun
(define (compile-get-boxes exprs)
  (: compile-getter : TOY -> (ENV -> (Boxof VAL)))
  (define (compile-getter expr)
    (cases expr
      [(Id name)
       (lambda ([env : ENV]) (lookup name env))]
      [else
       (lambda ([env : ENV])
         (error 'eval
                "rfun application with a non-identifier: ~s"
                expr))]))
  (unless (unbox compiler-enabled?)
    (error 'compile "compiler disabled"))
  (let ([getters (map compile-getter exprs)])
    (lambda (env)
      (map (lambda ([g : (ENV -> (Boxof VAL))]) (g env)) getters))))


(: compile : TOY -> (ENV -> VAL))
;; compiles TOY expressions.
(define (compile expr)
  ;; convenient helper
  (: runner : ENV -> ((ENV -> VAL) -> VAL))
  (define (runner env) (lambda (compiled) (compiled env)))
  (unless (unbox compiler-enabled?)
    (error 'compile "compiler disabled"))
  (cases expr
    [(Num n)   (lambda ([env : ENV]) (RktV n))]
    [(Id name) (lambda ([env : ENV]) (unbox (lookup name env)))]
    [(Set name new)
     (let ([compiled (compile new)])
       (lambda ([env : ENV])
         (set-box! (lookup name env) (compiled env))
         the-bogus-value))]
    [(Bind names exprs bound-body)
     (let ([compiled-exprs (map compile exprs)]
           [c-body (compile-body bound-body)])
       (lambda ([env : ENV])
         (c-body (extend names (map (runner env) compiled-exprs)
                         env))))]
    [(BindRec names exprs bound-body)
     (let ([c-exprs (map compile exprs)]
           [c-body (compile-body bound-body)])
       (lambda ([env : ENV])
         (c-body (extend-rec names c-exprs env))))]
    [(Fun names bound-body)
     (let ([c-body (compile-body bound-body)])
       (lambda ([env : ENV]) (FunV names c-body env #f)))]
    [(RFun names bound-body)
     (let ([c-body (compile-body bound-body)])
       (lambda ([env : ENV]) (FunV names c-body env #t)))]
    [(Call fun-expr arg-exprs)
     (let ([c-fun (compile fun-expr)]
           [c-args (map compile arg-exprs)]
           [c-boxes (compile-get-boxes arg-exprs)])
       (lambda ([env : ENV])
         (let ([fval (c-fun env)]
               ;; delay evaluating the arguments
               [arg-vals (lambda () (map (runner env) c-args))])
           (cases fval
             [(PrimV proc) (proc (arg-vals))]
             [(FunV names c-body fun-env byref?)
              (c-body (if byref?
                          (raw-extend names
                                      (c-boxes env)
                                      fun-env)
                          (extend names (arg-vals) fun-env)))]
             [else (error 'eval "function call with a non-function: ~s"
                          fval)]))))]
    [(If cond-expr then-expr else-expr)
     (let ([c-cond (compile cond-expr)]
           [c-then (compile then-expr)]
           [c-else (compile else-expr)])
       (lambda ([env : ENV])
         ((if (cases (c-cond env)
                [(RktV v) v] ; Racket value => use as boolean
                [else #t])   ; other values are always true
              c-then
              c-else) env)))]))
;; Tests
(test (begin (set-box! compiler-enabled? #f)
             (compile (parse "3")))
      =error> 
      "compiler disabled")
(test (begin (set-box! compiler-enabled? #f)
             (compile-get-boxes (list (Id 'x))))
      =error>
      "compiler disabled")

(: run : String -> Any)
;; compiles and runs a TOY program contained in a string
(define (run str)
  (set-box! compiler-enabled? #t)
  (let ([compiled (compile (parse str))])
    (set-box! compiler-enabled? #f)
    (let ([result (compiled global-environment)])
      (cases result
        [(RktV v) v]
        [else (error 'run
                     "the program returned a bad value: ~s"
                     result)]))))

;;; ==================================================================
;;; Tests

(test (run "{{fun {x} {+ x 1}} 4}")
      => 5)
(test (run "{bind {{add3 {fun {x} {+ x 3}}}} {add3 1}}")
      => 4)
(test (run "{bind {{add3 {fun {x} {+ x 3}}}
                   {add1 {fun {x} {+ x 1}}}}
              {bind {{x 3}} {add1 {add3 x}}}}")
      => 7)
(test (run "{bind {{identity {fun {x} x}}
                   {foo {fun {x} {+ x 1}}}}
              {{identity foo} 123}}")
      => 124)
(test (run "{bind {{x 3}}
              {bind {{f {fun {y} {+ x y}}}}
                {bind {{x 5}}
                  {f 4}}}}")
      => 7)
(test (run "{{{fun {x} {x 1}}
              {fun {x} {fun {y} {+ x y}}}}
             123}")
      => 124)

;; More tests for complete coverage
(test (run "{bind x 5 x}")      =error> "bad `bind' syntax")
(test (run "{fun x x}")         =error> "bad `fun' syntax")
(test (run "{if x}")            =error> "bad `if' syntax")
(test (run "{}")                =error> "bad syntax")
(test (run "{bind {{x 5} {x 5}} x}") =error> "duplicate*bind*names")
(test (run "{fun {x x} x}")     =error> "duplicate*fun*names")
(test (run "{+ x 1}")           =error> "no binding for")
(test (run "{+ 1 {fun {x} x}}") =error> "bad input")
(test (run "{+ 1 {fun {x} x}}") =error> "bad input")
(test (run "{1 2}")             =error> "with a non-function")
(test (run "{{fun {x} x}}")     =error> "arity mismatch")
(test (run "{if {< 4 5} 6 7}")  => 6)
(test (run "{if {< 5 4} 6 7}")  => 7)
(test (run "{if + 6 7}")        => 6)
(test (run "{fun {x} x}")       =error> "returned a bad value")

;; assignment tests
(test (run "{set! {+ x 1} x}")  =error> "bad `set!' syntax")
(test (run "{bind {{x 1}} {set! x {+ x 1}} x}") => 2)

;; `bindrec' tests
(test (run "{bindrec {x 6} x}") =error> "bad `bindrec' syntax")
(test (run "{bindrec {{fact {fun {n}
                              {if {= 0 n}
                                1
                                {* n {fact {- n 1}}}}}}}
              {fact 5}}")
      => 120)

;; tests for multiple expressions and assignment
(test (run "{bind {{make-counter
                     {fun {}
                       {bind {{c 0}}
                         {fun {}
                           {set! c {+ 1 c}}
                           c}}}}}
              {bind {{c1 {make-counter}}
                     {c2 {make-counter}}}
                {* {c1} {c1} {c2} {c1}}}}")
      => 6)
(test (run "{bindrec {{foo {fun {}
                             {set! foo {fun {} 2}}
                             1}}}
              {+ {foo} {* 10 {foo}}}}")
      => 21)

;; `rfun' tests
(test (run "{{rfun {x} x} 4}") =error> "non-identifier")
(test (run "{bind {{swap! {rfun {x y}
                            {bind {{tmp x}}
                              {set! x y}
                              {set! y tmp}}}}
                   {a 1}
                   {b 2}}
              {swap! a b}
              {+ a {* 10 b}}}")
      => 12)

;; test that argument are not evaluated redundantly
(test (run "{{rfun {x} x} {/ 4 0}}") =error> "non-identifier")
(test (run "{5 {/ 6 0}}") =error> "non-function")

;;; ==================================================================

(define minutes-spent 180)