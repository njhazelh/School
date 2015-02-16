#lang pl 04

#| BNF for the ALGAE language:
     <ALGAE> ::= <num>
               | { + <ALGAE> ... }
               | { * <ALGAE> ... }
               | { - <ALGAE> <ALGAE> ... }
               | { / <ALGAE> <ALGAE> ... }
               | True
               | False
               | { <  <ALGAE> <ALGAE> }
               | { =  <ALGAE> <ALGAE> }
               | { <= <ALGAE> <ALGAE> }
               | { not <ALGAE> <ALGAE> }
               | { and <ALGAE> <ALGAE> }
               | { or  <ALGAE> <ALGAE> }
               | { with { <id> <ALGAE> } <ALGAE> }
               | { if <ALGAE> <ALGAE> <ALGAE> }
               | <id>
|#

;; ALGAE abstract syntax trees
(define-type ALGAE
  [Num  Number]
  [Bool Boolean]
  [Add  (Listof ALGAE)]
  [Mul  (Listof ALGAE)]
  [Sub  ALGAE (Listof ALGAE)]
  [Div  ALGAE (Listof ALGAE)]
  [Less ALGAE ALGAE]
  [Equal ALGAE ALGAE]
  [LessEq ALGAE ALGAE]
  [Id   Symbol]
  [With Symbol ALGAE ALGAE]
  [If ALGAE ALGAE ALGAE])

(: Not : ALGAE -> ALGAE)
;; Define a pseudo-type Not to match the unary logic operator
(define (Not x)
  (If x (Bool #f) (Bool #t)))

(: Or : ALGAE ALGAE -> ALGAE)
;; Define a pseudo-type Or to match the binary logic operator
(define (Or x y)
  (If x (Bool #t) y))

(: And : ALGAE ALGAE -> ALGAE)
;; Define a pseudo-type And to match the binary logic operator
(define (And x y)
  (If x y (Bool #f)))

(: parse-sexpr : Sexpr -> ALGAE)
;; to convert s-expressions into ALGAEs
(define (parse-sexpr sexpr)
  ;; utility for parsing a list of expressions
  (: parse-sexprs : (Listof Sexpr) -> (Listof ALGAE))
  (define (parse-sexprs sexprs) (map parse-sexpr sexprs))
  (match sexpr
    [(number: n)    (Num n)]
    ['True (Bool true)]
    ['False (Bool false)]
    [(symbol: name) (Id name)]
    [(cons 'with more)
     (match sexpr
       [(list 'with (list (symbol: name) named) body)
        (With name (parse-sexpr named) (parse-sexpr body))]
       [else (error 'parse-sexpr "bad `with' syntax in ~s" sexpr)])]
    [(list 'not arg) (Not (parse-sexpr arg))]
    [(list 'or arg1 arg2) (Or (parse-sexpr arg1)
                              (parse-sexpr arg2))]
    [(list 'and arg1 arg2) (And (parse-sexpr arg1)
                                (parse-sexpr arg2))]
    [(list '+ (sexpr: args) ...)
     (Add (parse-sexprs args))]
    [(list '* (sexpr: args) ...)
     (Mul (parse-sexprs args))]
    [(list '- fst (sexpr: args) ...)
     (Sub (parse-sexpr fst) (parse-sexprs args))]
    [(list '/ fst (sexpr: args) ...)
     (Div (parse-sexpr fst) (parse-sexprs args))]
    [(list '< num1 num2)
     (Less (parse-sexpr num1) (parse-sexpr num2))]
    [(list '= num1 num2)
     (Equal (parse-sexpr num1) (parse-sexpr num2))]
    [(list '<= num1 num2)
     (LessEq (parse-sexpr num1) (parse-sexpr num2))]
    [(list 'if pred trueBranch falseBranch)
     (If (parse-sexpr pred)
         (parse-sexpr trueBranch)
         (parse-sexpr falseBranch))]
    [else (error 'parse-sexpr "bad syntax in ~s" sexpr)]))


(: parse : String -> ALGAE)
;; parses a string containing an ALGAE expression to an ALGAE AST
(define (parse str)
  (parse-sexpr (string->sexpr str)))

#| Formal specs for `subst':
   (`N' is a <num>, 'B' is a True/False, 'P' is a <BOOL>,
      `E1', `E2', are <ALGAE>s, `x' is some <id>,
       'y' is a *different* <id>)
      N[v/x]                = N
      B[v/x]                = B
      {+ E ...}[v/x]        = {+ E[v/x] ...}
      {* E ...}[v/x]        = {* E[v/x] ...}
      {- E1 E ...}[v/x]     = {- E1[v/x] E[v/x] ...}
      {/ E1 E ...}[v/x]     = {/ E1[v/x] E[v/x] ...}
      y[v/x]                = y
      x[v/x]                = v
      {< E1 E2}[v/x]        = {< E1[v/x] E2[v/x]}
      {= E1 E2}[v/x]        = {= E1[v/x] E2[v/x]}
      {<= E1 E2}[v/x]       = {<= E1[v/x] E2[v/x]}
      {with {y E1} E2}[v/x] = {with {y E1[v/x]} E2[v/x]}
      {with {x E1} E2}[v/x] = {with {x E1[v/x]} E2}
      {if P E1 E2}[v/x]     = {if P[v/x] E1[v/x] E2[v/x]}
|#

(: subst : ALGAE Symbol ALGAE -> ALGAE)
;; substitutes the second argument with the third argument in the
;; first argument, as per the rules of substitution; the resulting
;; expression contains no free instances of the second argument
(define (subst expr from to)
  ;; convenient helper -- no need to specify `from' and `to'
  (: subst* : ALGAE -> ALGAE)
  (define (subst* x) (subst x from to))
  ;; helper to substitute lists
  (: substs* : (Listof ALGAE) -> (Listof ALGAE))
  (define (substs* exprs) (map subst* exprs))
  (cases expr
    [(Num n)        expr]
    [(Bool b)       expr]
    [(Less n1 n2)   (Less (subst* n1) (subst* n2))]
    [(Equal n1 n2)  (Equal (subst* n1) (subst* n2))]
    [(LessEq n1 n2) (LessEq (subst* n1) (subst* n2))]
    [(Add args)     (Add (substs* args))]
    [(Mul args)     (Mul (substs* args))]
    [(Sub fst args) (Sub (subst* fst) (substs* args))]
    [(Div fst args) (Div (subst* fst) (substs* args))]
    [(Id name)      (if (eq? name from) to expr)]
    [(If pred tBrnch fBrnch) (If (subst* pred)
                                 (subst* tBrnch)
                                 (subst* fBrnch))]
    [(With bound-id named-expr bound-body)
     (With bound-id
           (subst* named-expr)
           (if (eq? bound-id from)
               bound-body
               (subst* bound-body)))]))

#| 
'N' is a <num>
'B' is a True/False

Formal specs for `eval':
     eval(N)            = N
     eval(B)            = B
     eval({< E1 E2})    = evalN(E1) < evalN(E2)
     eval({= E1 E2})    = evalN(E1) = evalN(E2)
     eval({<= E1 E2})   = evalN(E1) <= evalN(E2)
     eval({+ E ...})    = evalN(E) + ...
     eval({* E ...})    = evalN(E) * ...
     eval({- E})        = -evalN(E)
     eval({/ E})        = 1/evalN(E)
     eval({- E1 E ...}) = evalN(E1) - (evalN(E) + ...)
     eval({/ E1 E ...}) = evalN(E1) / (evalN(E) * ...)
     eval(id)           = error!
     eval({not E})      = eval({if E False True})
     eval({and E1 E2})  = eval({if E1 E2 False})
     eval({or E1 E2})   = eval({if E1 True E2})
     eval({with {x E1} E2}) = eval(E2[eval(E1)/x])
     eval({if P E1 E2}) = if evalB(P) is true, eval(E1), else eval(E2)
     evalN(E) = eval(E) if it is a number, error otherwise
     evalB(E) = eval(E) if it is a boolean, error otherwise
|#

(: eval-number : ALGAE -> Number)
;; helper for `eval': verifies that the result is a number
(define (eval-number expr)
  (let ([result (eval expr)])
    (if (number? result)
        result
        (error 'eval-number "need a number when evaluating ~s, but got ~s"
               expr result))))

(: eval-boolean : ALGAE -> Boolean)
;; helper for `eval': verifies that the result is a boolean
(define (eval-boolean expr)
  (let ([result (eval expr)])
    (if (boolean? result)
        result
        (error 'eval-number "need a boolean when evaluating ~s, but got ~s"
               expr result))))

(: value->algae : (U Number Boolean) -> ALGAE)
;; converts a value to an ALGAE value (so it can be used with `subst')
(define (value->algae val)
  (cond [(number? val) (Num val)]
        [(boolean? val) (Bool val)]
        ;; Note: since we use Typed Racket, the type checker makes sure
        ;; that this function is never called with something that is not
        ;; in its type, so there's no need for an `else' branch.
        ;; (Strictly speaking, there's no need for the last predicate
        ;; (which is the only one here until you extend this), but it's
        ;; left in for clarity)
        ;; [else (error 'value->algae "unexpected value: ~s" val)]
        ))
;; The following test is also not needed.  In the untyped version, it
;; was needed because the error could not be achieved through `eval' --
;; which is exactly why the above type works.
;; ;; test for an otherwise unreachable error:
;; (test (value->algae null) =error> "unexpected value")

(: eval : ALGAE -> (U Number Boolean))
;; evaluates ALGAE expressions by reducing them to numbers
(define (eval expr)
  (cases expr
    [(Num n) n]
    [(Bool b) b]
    [(Less n1 n2)   (< (eval-number n1) (eval-number n2))]
    [(Equal n1 n2)  (= (eval-number n1) (eval-number n2))]
    [(LessEq n1 n2) (<= (eval-number n1) (eval-number n2))]
    [(Add args) (foldl + 0 (map eval-number args))]
    [(Mul args) (foldl * 1 (map eval-number args))]
    [(Sub fst args)
     (if (null? args)
         (- (eval-number fst))
         (foldl + (eval-number fst) (map - (map eval-number args))))]
    [(Div fst args)
     (let ((fstNum (eval-number fst))
           (argNums (map eval-number args))
           (argsEmpty (null? args)))
       (cond [(and argsEmpty (not (zero? fstNum)))
              (/ fstNum)]
             [(and (not argsEmpty) (not (ormap zero? argNums)))
              (* fstNum (foldl * 1 (map / argNums)))]
             [else (error 'eval "division by zero: ~s" expr)]))]
    [(If p tBrnch fBrnch)
     (if (eval-boolean p) (eval tBrnch) (eval fBrnch))]
    [(With bound-id named-expr bound-body)
     (eval (subst bound-body
                  bound-id
                  ;; see the above `value->algae' helper
                  (value->algae (eval named-expr))))]
    [(Id name) (error 'eval "free identifier: ~s" name)]))

(: run : String -> (U Number Boolean))
;; evaluate an ALGAE program contained in a string
(define (run str)
  (eval (parse str)))

;; tests
(test (run "5") => 5)
(test (run "{- 5}") => -5)
(test (run "{/ 2}") => 1/2)
(test (run "{- 10 2 -2 4 2}") => 4)
(test (run "{/ 100 2 2 5}") => 5)
(test (run "{+ 5 5}") => 10)
(test (run "{+}") => 0)
(test (run "{*}") => 1)
(test (run "{+ 5 5 5 5 5}") => 25)
(test (run "{* 1 2 3 4}") => 24)
(test (run "{with {x {+ 5 5}} {+ x x}}") => 20)
(test (run "{with {x 5} {+ x x}}") => 10)
(test (run "{with {x {+ 5 5}} {with {y {- x 3}} {+ y y}}}") => 14)
(test (run "{with {x 5} {with {y {- x 3}} {+ y y}}}") => 4)
(test (run "{with {x 5} {+ x {with {x 3} 10}}}") => 15)
(test (run "{with {x 5} {+ x {with {x 3} x}}}") => 8)
(test (run "{with {x 5} {+ x {with {y 3} x}}}") => 10)
(test (run "{with {x 5} {with {y x} y}}") => 5)
(test (run "{with {x 5} {with {x x} x}}") => 5)
(test (run "{* 4 5}") => 20)
(test (run "{- 4 3}") => 1)
(test (run "{/ 20 4}") => 5)
(test (run "{with {x 5} {* x 5}}") => 25)
(test (run "{with {x 25} {/ x 5}}") => 5)
(test (run "{uhhh 3 4}") =error> "bad syntax in ")
(test (run "{+ x 3}") =error> "free identifier: ")
(test (run "{with {3 4} {+ 3 4}}") =error> "bad `with' syntax in ")
(test (run "{- 0 -1 1}") => 0)
(test (run "{/ 0}") =error> "division by zero")
(test (run "{/ 4 1 1 1 1 0}") =error> "division by zero")
(test (run "{/ 20 1 3 0 3}") =error> "division by zero")
(test (run "{/ 0 1 2 3 4}") => 0)
(test (run "{< 3 4}") => true)
(test (run "{< 4 4}") => false)
(test (run "{< 4 3}") => false)
(test (run "{= 1 1}") => true)
(test (run "{= 2 1}") => false)
(test (run "{= 1 2}") => false)
(test (run "{<= 1 2}") => true)
(test (run "{<= 2 2}") => true)
(test (run "{<= 2 1}") => false)
(test (run "{if True 1 2}") => 1)
(test (run "{if False 1 2}") => 2)
(test (run "{if {< 1 2} {+ 3 4} {* 3 4}}") => 7)
(test (run "{if {< {+ 1 2} 4} {+ 3 4} {* 3 4}}") => 7)
(test (run "{with {x 5} True}") => true)
(test (run "{with {x 5} {< 1 2}}") => true)
(test (run "{with {x 5} {= 1 2}}") => false)
(test (run "{with {x 5} {<= 1 2}}") => true)
(test (run "{with {x 5} {if {= x 5} 1 2}}") => 1)
(test (run "{with {x 5} {if {= x 6} 1 2}}") => 2)
(test (run "{with {x {< 1 2}} x}") => true)
(test (run "{if 3 1 2}") =error> "need a boolean")
(test (run "{+ True 1 2}") =error> "need a number")
(test (run "{not True}") => false)
(test (run "{not False}") => true)
(test (run "{and True True}") => true)
(test (run "{and True False}") => false)
(test (run "{and False True}") => false)
(test (run "{and False False}") => false)
(test (run "{or True True}") => true)
(test (run "{or True False}") => true)
(test (run "{or False True}") => true)
(test (run "{or False False}") => false)

(define minutes-spent 240)