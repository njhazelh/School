#lang class/0


(define max-num max) ;; redefining the max function

;; A TernaryTree is one of
;; - TernaryNode
;; - TernaryLeaf
;; and implements:
;; size : -> Number
;; How many numbers are in the tree?
;; sum : -> Number
;; What is the sum of numbers in the tree?
;; prod : -> Number
;; What is the product of the numbers in the tree?
;; contains? : Number -> Boolean
;; Does the tree contain the number?
;; map : [Number -> Number] -> TernaryTree
;; Apply a function to all numbers in the tree
;; max : -> Number
;; What is the highest number in the tree?

;; A TernaryNode is a (new tern-node% Number TernaryTree TernaryTree TernaryTree)
(define-class tern-node%
  (fields value left middle right)
  
  ;; Template:
  #; (define (tern-node%-temp)
       (send this value)  ...
       (send this left)   ...
       (send this middle) ...
       (send this right)  ...)
  
  ;; size : -> Number
  ;; How many numbers are in the tree?
  (define (size)
    (+ 1
       (send (send this left) size)
       (send (send this middle) size)
       (send (send this right) size)))
  ;; Tests/Examples:
  (check-expect (send tree1 size) 4)
  (check-expect (send tree2 size) 10)
  
  ;; sum : -> Number
  ;; What is the sum of the numbers in the tree?
  (define (sum)
    (+ (send this value)
       (send (send this left) sum)
       (send (send this middle) sum)
       (send (send this right) sum)))
  ;; Tests/Examples:
  (check-expect (send tree1 sum) 10)
  (check-expect (send tree2 sum) 55)
  
  ;; prod : -> Number
  ;; What is the product of the numbers in the tree?
  (define (prod)
    (* (send this value)
       (send (send this left) prod)
       (send (send this middle) prod)
       (send (send this right) prod)))
  ;; Tests/Examples:
  (check-expect (send tree1 prod) 24)
  (check-expect (send tree2 prod) 3628800)
  
  ;; contains? : Number -> Boolean
  ;; Does the tree contain the number?
  (define (contains? num)
    (or (=(send this value) num)
        (send (send this left) contains? num)
        (send (send this middle) contains? num)
        (send (send this right) contains? num)))
  ;; Tests/Examples:
  (check-expect (send tree1 contains? 0) false)
  (check-expect (send tree1 contains? 1) true)
  (check-expect (send tree1 contains? 20) false)
  (check-expect (send tree1 contains? 1) true)
  
  ;; map : [Number -> Number] -> TernaryTree
  ;; Apply a function to all numbers in the tree
  (define (map func)
    (new tern-node%
         (func (send this value))
         (send (send this left) map func)
         (send (send this middle) map func)
         (send (send this right) map func)))
  ;; Tests/Examples:
  (check-expect (send tree1 map add1)
                (new tern-node%
                     2
                     (new tern-leaf% 3)
                     (new tern-leaf% 4)
                     (new tern-leaf% 5)))
  (check-expect (send tree1 map sub1)
                (new tern-node%
                     0
                     (new tern-leaf% 1)
                     (new tern-leaf% 2)
                     (new tern-leaf% 3)))
  (check-expect (send tree2 map add1)
                (new tern-node%
                     2
                     (new tern-node%
                          3
                          (new tern-leaf% 4)
                          (new tern-leaf% 5)
                          (new tern-leaf% 6))
                     (new tern-leaf% 7)
                     (new tern-node%
                          8
                          (new tern-leaf% 9)
                          (new tern-leaf% 10)
                          (new tern-leaf% 11))))
  (check-expect (send tree2 map sub1)
                (new tern-node%
                     0
                     (new tern-node%
                          1
                          (new tern-leaf% 2)
                          (new tern-leaf% 3)
                          (new tern-leaf% 4))
                     (new tern-leaf% 5)
                     (new tern-node%
                          6
                          (new tern-leaf% 7)
                          (new tern-leaf% 8)
                          (new tern-leaf% 9))))
  ;; max : -> Number
  ;; What is the highest number in the tree?
  (define (max)
    (max-num (send this value)
         (send (send this left) max)
         (send (send this middle) max)
         (send (send this right) max)))
  ;; Tests/Examples:
  (check-expect (send tree1 max) 4)
  (check-expect (send tree2 max) 10))


;; A TernaryLeaf is a (new tern-leaf% Number)
(define-class tern-leaf%
  (fields number)
  
  ;; Template:
  #; (define (tern-leaf%-temp)
       (send this number) ...)
  
  ;; size : -> Number
  ;; How many numbers are in the tree?
  (define (size)
    1)
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 0) size) 1)
  (check-expect (send (new tern-leaf% 2) size) 1)
  
  ;; sum : -> Number
  ;; What is the sum of the numbers in the tree?
  (define (sum)
    (send this number))
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 0) sum) 0)
  (check-expect (send (new tern-leaf% 2) sum) 2)
  
  ;; prod : -> Number
  ;; What is the product of the numbers in the tree?
  (define (prod)
    (send this number))
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 0) prod) 0)
  (check-expect (send (new tern-leaf% 2) prod) 2)
  
  ;; contains? : Number -> Boolean
  ;; Does the tree contain the number?
  (define (contains? num)
    (= num (send this number)))
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 3) contains? 3) true)
  (check-expect (send (new tern-leaf% 3) contains? 1) false)
  
  ;; map : [Number -> Number] -> ternaryTree
  ;; Apply a function to all numbers in the tree
  (define (map func)
    (new tern-leaf%
         (func (send this number))))
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 3) map add1)
                (new tern-leaf% 4))
  (check-expect (send (new tern-leaf% 3) map sub1)
                (new tern-leaf% 2))
  
  ;; max : -> Number
  ;; What is the highest number in the tree?
  (define (max)
    (send this number))
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 0) max) 0)
  (check-expect (send (new tern-leaf% 2) max) 2))


;; Examples:
(define tree1 (new tern-node%
                   1
                   (new tern-leaf% 2)
                   (new tern-leaf% 3)
                   (new tern-leaf% 4)))
(define tree2 (new tern-node%
                   1
                   (new tern-node%
                        2
                        (new tern-leaf% 3)
                        (new tern-leaf% 4)
                        (new tern-leaf% 5))
                   (new tern-leaf% 6)
                   (new tern-node%
                        7
                        (new tern-leaf% 8)
                        (new tern-leaf% 9)
                        (new tern-leaf% 10))))