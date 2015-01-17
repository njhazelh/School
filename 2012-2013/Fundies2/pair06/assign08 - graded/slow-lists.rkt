#lang class/2

(provide empty)

;; A [List X] implements
;; - cons : X -> [List X]
;;   Cons given element on to this list.
;; - first : -> X
;;   Get the first element of this list 
;;   INVARIANT: (only defined on non-empty lists).
;; - rest : -> [List X]
;;   Get the rest of this 
;;   INVARIANT: (only defined on non-empty lists).
;; - list-ref : Natural -> X
;;   Get the ith element of this list 
;;   INVARIANT: (only defined for lists of i+1 or more elements)
;; - length : -> Natural
;;   Compute the number of elements in this list.
 
;; - accept : [ListVisitor X Y] -> Y
;;   Accept given visitor and visit this list's data.

;; - fold : [ListFold X Y] -> Y
;;   Accept given fold and process this list's data.

;; empty is a [List X] for any X.

;; A Slow-List if one of:
;; - (new mt%)
;; - (new cons% X Slow-List)


(define-class mt%
  
  ;; accept : [ListVisitor X Y] -> Y
  ;; Accept a given visitor and visit this list's data
  (define (accept visitor)
    (visitor . visit-mt))
  
  
  ;; - fold : [ListFold X Y] -> Y
  ;; Accept given fold and process this list's data.
  (define (fold visitor)
    (visitor . fold-mt))
  
  ;; length : -> Number
  ;; The length of the list
  (define (length) 0)
  ;; Examples/Tests
  (check-expect ((new mt%) . length) 0)
  
  
  ;; cons : X -> Slow-List
  ;; adds X to the list
  (define (cons e)
    (new cons% e this))
  ;; Examples/Tests
  (check-expect ((new mt%) . cons 'a) (new cons% 'a (new mt%))))



(define-class cons%
  (fields cfirst crest)
  
  
  ;; accept : [ListVisitor X Y] -> Y
  ;; Accept a given visitor and visit this list's data
  (define (accept visitor)
    (visitor . visit-cons (this . first) (this . rest)))
  
  ;; - fold : [ListFold X Y] -> Y
  ;; Accept given fold and process this list's data.
  (define (fold visitor)
    (visitor . fold-cons (this . first) (this . rest . fold visitor)))
  
  ;; cons : X -> Slow-List
  ;; Adds X to the list
  (define (cons e)
    (new cons% e this))
  ;; Examples/Tests
  (check-expect (TEST_LIST . cons 'd)
                (new cons% 'd (new cons% 'a 
                                   (new cons% 'b (new cons% 'c (new mt%))))))
  
  ;; first : -> X
  ;; The first element in the list
  (define (first) (this . cfirst))
  ;; Examples/Tests
  (check-expect (TEST_LIST . first) 'a)
  
  
  ;; rest : -> Slow-List
  ;; The rest of the elements in the list
  (define (rest) (this . crest))
  ;; Examples/Tests
  (check-expect (TEST_LIST . rest)
                (new cons% 'b (new cons% 'c (new mt%))))
  
  
  ;; list-ref : Number -> X
  ;; Gets the ith X from the list
  ;; INVARIANT: The Number must be less than the length of the list
  ;;            and greater than or equal to 0
  (define (list-ref n)
    (if
      (= n 0)
      (this . cfirst)
      (this . crest . list-ref (sub1 n))))
  ;; Examples/Tests
  (check-expect (TEST_LIST . list-ref 0) 'a)
  (check-expect (TEST_LIST . list-ref 1) 'b)
  (check-expect (TEST_LIST . list-ref 2) 'c)
  
  
  ;; length : -> Number
  ;; The length of the list
  (define (length)
    (+ 1 (this . crest . length)))
  ;; Examples/Tests
  (check-expect (TEST_LIST . length) 3))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tests Galore!  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define empty (new mt%))

(define ls (empty . cons 'a . cons 'b . cons 'c . cons 'd . cons 'e))
 
(check-expect (empty . length) 0)
(check-expect (ls . length) 5)
(check-expect (ls . first) 'e)
(check-expect (ls . rest . first) 'd)
(check-expect (ls . rest . rest . first) 'c)
(check-expect (ls . rest . rest . rest . first) 'b)
(check-expect (ls . rest . rest . rest . rest . first) 'a)
 
(check-expect (ls . list-ref 0) 'e)
(check-expect (ls . list-ref 1) 'd)
(check-expect (ls . list-ref 2) 'c)
(check-expect (ls . list-ref 3) 'b)
(check-expect (ls . list-ref 4) 'a)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Testable Constnts  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A Slow-List for testing
(define TEST_LIST (new cons% 'a (new cons% 'b (new cons% 'c (new mt%)))))