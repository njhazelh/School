#lang class/0

;; Exercise 2.2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Definition (Leaf) -----------------------------------------------------------

;; A Leaf is a (new leaf% Number)
;; A Leaf is also a TernaryTree
(define-class leaf%
  (fields x)
  
  ; size : -> Number
  ; returns 1 because a Leaf holds 1 number
  (define (size) 1)
  
  (check-expect (send leaf2 size) 1)
  
  ; sum : -> Number
  ; returns x
  (define (sum) (field x))
  
  (check-expect (send leaf2 sum) 3)
  
  ; product : -> Number
  ; returns x
  (define (prod) (field x))
  
  (check-expect (send leaf2 prod) 3)
  
  ; contains? : Number -> Boolean
  ; is a given number in the Leaf?
  (define (contains? n)
    (= (field x) n))
  
  (check-expect (send leaf1 contains? 1) true)
  (check-expect (send leaf1 contains? 2) false)
  
  ; map : [Number -> X] -> Leaf
  ; applies a function to the number in the Leaf
  (define (map f)
    (new leaf% (f (field x))))
  
  (check-expect (send leaf1 map add1) (new leaf% 2))
  (check-expect (send (new leaf% -1) map abs) (new leaf% 1))
  
  ; max : -> Number
  ; returns x
  (define (max) (field x))
  
  (check-expect (send leaf2 max) 3))

;; Examples
(define leaf1 (new leaf% 1))
(define leaf2 (new leaf% 3))

;; Definition (TernaryTree) ----------------------------------------------------

;; A TernaryTree is one of:
;; - (new node% TernaryTree TernaryTree TernaryTree)
;; - Leaf
;; Note: There are no empty TernaryTrees
(define-class node%
  (fields x y z)
  
  ; size : -> Number
  ; determines how many Numbers are in the TernaryTree
  (define (size)
    (cond [(number? (send this x)) (send this size)]
          [else (+ (send (field x) size)
                   (send (field y) size)
                   (send (field z) size))]))
  
  (check-expect (send tree1 size) 1)
  (check-expect (send tree2 size) 3)
  (check-expect (send tree4 size) 7)
  
  ; sum : -> Number
  ; determines the sum of the Numbers in the TernaryTree
  (define (sum)
    (cond [(number? (send this x)) (send this sum)]
          [else (+ (send (field x) sum)
                   (send (field y) sum)
                   (send (field z) sum))]))
  
  (check-expect (send tree1 sum) 1)
  (check-expect (send tree2 sum) 6)
  (check-expect (send tree4 sum) 28)
  
  ; prod : -> Number
  ; determines the product of the Numbers in the TernaryTree
  (define (prod)
    (cond [(number? (send this x)) (send this prod)]
          [else (* (send (field x) prod)
                   (send (field y) prod)
                   (send (field z) prod))]))
  
  (check-expect (send tree1 prod) 1)
  (check-expect (send tree3 prod) 120)
  (check-expect (send tree4 prod) (* 6 120 7))
  
  ; contains? : Number -> Boolean
  ; is a given number in the TernaryTree?
  (define (contains? n)
    (cond [(number? (send this x)) (send this contains? n)]
          [else (or (send (field x) contains? n)
                   (send (field y) contains? n)
                   (send (field z) contains? n))]))
  
  (check-expect (send tree1 contains? 1) true)
  (check-expect (send tree2 contains? 5) false)
  (check-expect (send tree4 contains? 5) true)
  
  ; map : [Number -> X] -> TernaryTree
  ; applies a function to every number in the TernaryTree  
  (define (map f)
    (cond [(number? (send this x)) (send this map f)]
          [else (new node% (send (field x) map f)
                   (send (field y) map f)
                   (send (field z) map f))]))
  
  (check-expect (send tree1 map add1) (new leaf% 2))
  (check-expect (send tree2 map sub1)
                (new node% (new leaf% 0) (new leaf% 1) (new leaf% 2)))
  (check-expect (send tree4 map add1)
                (new node% 
                     (new node% (new leaf% 2)(new leaf% 3)(new leaf% 4))
                     (new node% (new leaf% 5)(new leaf% 6)(new leaf% 7))
                     (new leaf% 8)))
  
  ; max : -> Number
  ; returns the largest number in the TernaryTree
  (define (max)
    (local ((define (max-num a b c)
              (cond [(and (> a b) (> a c)) a]
                    [(and (> b a) (> b c)) b]
                    [(and (> c a) (> c b)) c])))
    (cond [(number? (send this x))(send this max)]
          [else (max-num (send (field x) max)
                         (send (field y) max)
                         (send (field z) max))])))
  
  (check-expect (send tree1 max) 1)
  (check-expect (send tree4 max) 7))

;; Examples
(define tree1 leaf1)
(define tree2 (new node% (new leaf% 1) (new leaf% 2) (new leaf% 3)))
(define tree3 (new node% (new leaf% 4) (new leaf% 5) (new leaf% 6)))
(define tree4 (new node% tree2 tree3 (new leaf% 7)))
