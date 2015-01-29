#lang pl 02

#|
Class:      CS 4400 - Programming Languages
Professor:  Eli Barzilay
Assignment: 2
Student:    Nicholas Jones
Date:       1/24/2015
|#


;; =====================================================================
;; Problem 1 A
;; =====================================================================

#|
LIST ::= <null>
       | {cons <LE> <LIST>}
       | {list <LE> ...}
       | {append <LIST> ...}

ATOM ::= <num>
       | <sym>

LE ::= <ATOM>
     | <LIST>
|#

;; =====================================================================
;; Problem 1 B
;; =====================================================================

#| BNF for the AE language:
   <AE> ::= <num>
          | { <AE> + <AE> }
          | { <AE> - <AE> }
          | { <AE> * <AE> }
          | { <AE> / <AE> }
|#

;; AE abstract syntax trees
(define-type AE
  [Num Number]
  [Add AE AE]
  [Sub AE AE]
  [Mul AE AE]
  [Div AE AE])

(: parse-sexpr : Sexpr -> AE)
;; to convert s-expressions into AEs
;; Uses infix syntax
(define (parse-sexpr sexpr)
  (match sexpr
    [(number: n) (Num n)]
    [(list lhs '+ rhs) (Add (parse-sexpr lhs) (parse-sexpr rhs))]
    [(list lhs '- rhs) (Sub (parse-sexpr lhs) (parse-sexpr rhs))]
    [(list lhs '* rhs) (Mul (parse-sexpr lhs) (parse-sexpr rhs))]
    [(list lhs '/ rhs) (Div (parse-sexpr lhs) (parse-sexpr rhs))]
    [else (error 'parse-sexpr "bad syntax in ~s" sexpr)]))

(: parse : String -> AE)
;; parses a string containing an AE expression to an AE AST
(define (parse str)
  (parse-sexpr (string->sexpr str)))

(: eval : AE -> Number)
;; consumes an AE and computes the corresponding number
(define (eval expr)
  (cases expr
    [(Num n)   n]
    [(Add l r) (+ (eval l) (eval r))]
    [(Sub l r) (- (eval l) (eval r))]
    [(Mul l r) (* (eval l) (eval r))]
    [(Div l r) (let ([right (eval r)])
                 (if (= right 0)
                     999
                     (/ (eval l) (eval r))))]))

(: run : String -> Number)
;; evaluate an AE program contained in a string
(define (run str)
  (eval (parse str)))

;; tests
(test (run "3") => 3)
(test (run "{3 + 4}") => 7)
(test (run "{{3 - 4} + 7}") => 6)
(test (run "{1 / 0}") => 999)
(test (run "{3 * 4}") => 12)
(test (run "{10 / 2}") => 5)
(test (run "raisins") =error> "bad syntax")

;; =====================================================================
;; Problem 1 C
;; =====================================================================

#|
It is not clear which set is performed first.  If the left set is
performed first, the answer is 6, since get returns 2.  If the right
is performed first, the answer is 3, since get returns 1.  I would add
that operations are performed from left to right.  This would clarify
the semantics.
|#


#|
<SET> ::= { set <MAE> }

<VAL> ::= <num>
        | { + <MAE> <MAE> }
        | { - <MAE> <MAE> }
        | { * <MAE> <MAE> }
        | { / <MAE> <MAE> }
        | get

<MAE> ::= <VAL> 
        | <STORE>
        | { seq <STORE> ... <VAL> }
|#

;; =====================================================================
;; Problem 2
;; =====================================================================

(: square : Number -> Number)
;; Multiply x by itself
(define (square x)
  (* x x))
;; Tests/Examples
(test (square 0) => 0)
(test (square 1) => 1)
(test (square 2) => 4)
(test (square 3) => 9)

(: sum-of-squares :  (Listof Number) -> Number)
;; Square all numbers list and add them together
(define (sum-of-squares list)
  (foldr + 0 (map square list)))
;; Tests/Examples
(test (sum-of-squares null) => 0)
(test (sum-of-squares (list 1 1 1 1)) => 4)
(test (sum-of-squares (list 2)) => 4)
(test (sum-of-squares (list 1 2 3 4)) => 30)

;; =====================================================================
;; Problem 3 A
;; =====================================================================

(define-type BINTREE
  [Node BINTREE BINTREE]
  [Leaf Number])

;; =====================================================================
;; Problem 3 B
;; =====================================================================

(: tree-map : (Number -> Number) BINTREE -> BINTREE)
;; Map a function, f, to all values, n_i, on the tree.
;; ie. replace each n_i with (f n_i)
(define (tree-map f tree)
  (cases tree
    [(Leaf num) (Leaf (f num))]
    [(Node left right) (Node (tree-map f left)
                             (tree-map f right))]))
;; Tests/Examples
(test (tree-map add1 (Leaf 0)) => (Leaf 1))
(test (tree-map sub1 (Leaf 1)) => (Leaf 0))
(test (tree-map add1 (Node (Leaf 0) (Leaf 1)))
      => (Node (Leaf 1) (Leaf 2)))
(test (tree-map add1 (Node (Node (Leaf 0)
                                 (Leaf 1))
                           (Leaf 2)))
      => (Node (Node (Leaf 1)
                     (Leaf 2))
               (Leaf 3)))

;; =====================================================================
;; Problem 3 C
;; =====================================================================

(: tree-fold : (All (A) ((A A -> A) (Number -> A) BINTREE -> A)))
;; This is basically foldl for Binary trees.
(define (tree-fold combiner leafFunc tree)
  (cases tree
    [(Node left right) (combiner (tree-fold combiner leafFunc left)
                                 (tree-fold combiner leafFunc right))]
    [(Leaf num) (leafFunc num)]))
;; Tests/Examples
(test (tree-fold string-append number->string (Leaf 0)) => "0")
(test (tree-fold string-append number->string (Node (Leaf 0)
                                                    (Leaf 1)))
      => "01")

(: tree-flatten : BINTREE -> (Listof Number))
;; flattens a binary tree to a list of its values in
;; left-to-right order
(define (tree-flatten tree)
  (tree-fold (inst append Number) (inst list Number) tree))
;; Tests/Examples
(test (tree-flatten (Leaf 0)) => (list 0))
(test (tree-flatten (Node (Node (Leaf 0)
                                (Leaf 1))
                          (Node (Leaf 2)
                                (Leaf 3))))
      => (list 0 1 2 3))

;; =====================================================================
;; Problem 3 D
;; =====================================================================

(: mirror-node : BINTREE BINTREE -> BINTREE)
;; Mirror a Node.
;; Put the left on the right, and the right on the left.
(define (mirror-node left right)
  (Node right left))
;; Tests/Examples
(test (mirror-node (Leaf 0) (Leaf 1)) => (Node (Leaf 1) (Leaf 0)))

(: tree-reverse : BINTREE -> BINTREE)
;; Flatten the tree into a list in right-to-left order
(define (tree-reverse tree)
  (tree-fold mirror-node Leaf tree))
;; Tests/Examples
(test (reverse (tree-flatten (Leaf 0)))
      => (tree-flatten (tree-reverse (Leaf 0))))
(test (reverse (tree-flatten (Node (Leaf 0) (Leaf 1))))
      => (tree-flatten (tree-reverse (Node (Leaf 0) (Leaf 1)))))
(test (reverse (tree-flatten (Node (Node (Leaf 0)
                                         (Leaf 1))
                                   (Leaf 2))))
      => (tree-flatten
          (tree-reverse (Node (Node (Leaf 0)
                                    (Leaf 1))
                              (Leaf 2)))))

;; =====================================================================
;; Problem 4
;; =====================================================================

(define minutes-spent 150)