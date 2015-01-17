#lang class/1

;; Exercise 3: Quick Lists ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A [List X] implements
;; - cons : X -> [List X]
;;   Cons given element on to this list.
;; - first : -> X
;;   Get the first element of this list (only defined on non-empty lists).
;; - rest : -> [List X]
;;   Get the rest of this (only defined on non-empty lists).
;; - list-ref : Natural -> X
;;   Get the ith element of this list
;;   Note: (only defined for lists of i+1 or more elements).
;; - length : -> Natural
;;   Compute the number of elements in this list.
 
;; Empty -----------------------------------------------------------------------

;; empty is a [List X] for any X.

(define-class empty%
  
  ;; Template
  #;(define (empty-temp ...) ...)

  ;; - cons : X -> [List X]
  ;;   Cons given element on to this list.
  (define (cons x)
    (new qcons% (new size% 1 0 0) x empty empty))
  
  (check-expect (empty . cons 1) 
                (new qcons% newtree 1 empty empty))

  ;; - length : -> Natural
  ;;   Compute the number of elements in this list.
  (define (length) 0)
  
  (check-expect (empty . length) 0))

;; Examples
(define empty (new empty%))

;; Size and QCons --------------------------------------------------------------

;; A Size is a (new size% Nat Nat Nat)
;; Interp: stores the sizes of the trees and forests in QCons

(define-class size%
  (fields top left right)
  
  ;; - length : -> Natural
  ;; Interp: calculates the size/length of the list
  (define (length) (+ (field top) (field left) (field right))))

;; Examples
(define newtree (new size% 1 0 0))
(define 3tree (new size% 1 1 1))
  
;; A QCons is a (new node% Size X [List X] [List X]
;; Invariant: A quick list is a forest of increasingly large full binary trees.
;; Invariant: With the possible exception of the first two trees,
;;            every successive tree is strictly larger.
(define-class qcons%
  (fields size top left right)
  
  ;; - cons : X -> [List X]
  ;;   Cons given element onto this list.
  #;(define (cons x)
    (cond [(equal? this empty) (this . cons)]
          [(equal? (field left) empty)
           (new qcons% ((field size) . cons) x 
                (new qcons% newtree (field top) empty empty) (field right))]
          [(equal? (field right) empty)
           (new qcons% ((field size) . cons) x
                (new qcons% newtree (field top) empty empty)
                (new qcons% newtree (field left) empty empty))]
          [else (new qcons% ((field size) . cons) x
                     ((field left) . cons (field top))
                     ((field right) . cons (field left))
  
    
  ;; - first : -> X
  ;;   Get the first element of this list (only defined on non-empty lists)
  (define (first) (field top))
   
  (check-expect (qconsc . first) 'c)
  ;;(check-expect (ls . first) 'e)
                
  ;; - rest : -> [List X]
  ;;   Get the rest of this (only defined on non-empty lists).
   
  ;; - list-ref : Natural -> X
  ;;   Get the ith element of this list
  ;;   Note: (only defined for lists of i+1 or more elements)
  (define (list-ref n)
    (cond [(or (zero? n)(and (equal? empty (this . left))
                             (equal? empty (this . right)))) (field top)]
          [(= n (this . size . left)) (this . left . top)]
          [(< n (this . size . left))(this . left . list-ref n)]
          [else (this . right . list-ref 
                      (- (- n (this . size . top)) (this . size . right)))]))
  
  (check-expect (qconsg . list-ref 0) 'g)
  (check-expect (qconsg . list-ref 1) 'f)
  (check-expect (qconsg . list-ref 2) 'e)
  (check-expect (qconsg . list-ref 3) 'd)
  (check-expect (qconsg . list-ref 4) 'c)
  (check-expect (qconsg . list-ref 5) 'b)
  (check-expect (qconsg . list-ref 6) 'a)
#|
  (check-expect (ls . list-ref 0) 'e)
  (check-expect (ls . list-ref 1) 'd)
  (check-expect (ls . list-ref 2) 'c)
  (check-expect (ls . list-ref 3) 'b)
  (check-expect (ls . list-ref 4) 'a)
|#
  ;; - length : -> Natural
  ;;   Compute the number of elements in this list
  (define (length)
    (if (equal? this empty) 0 ((field size) . length)))
          
  (check-expect (qconsc . length) 3)
  ;;(check-expect (ls . length) 5)
  )
          
;; Examples
(define qconsa (new qcons% (new size% 1 0 0) 'a empty empty))

(define qconsb (new qcons% (new size% 1 1 0) 'b 
                    (new qcons% (new size% 1 0 0) 'a empty empty) empty))

(define qconsc (new qcons% (new size% 1 1 1) 'c 
                    (new qcons% (new size% 1 0 0) 'b empty empty) 
                    (new qcons% (new size% 1 0 0) 'a empty empty)))

(define qconsg (new qcons% (new size% 1 3 3) 'g 
                    (new qcons% (new size% 1 1 1) 'd 
                         (new qcons% (new size% 1 0 0) 'f empty empty)
                         (new qcons% (new size% 1 0 0) 'e empty empty))
                    (new qcons% (new size% 1 1 1) 'c
                         (new qcons% (new size% 1 0 0) 'b empty empty)
                         (new qcons% (new size% 1 0 0) 'a empty empty))))
                                                        
;;(define ls (empty . cons 'a . cons 'b . cons 'c . cons 'd . cons 'e))

  