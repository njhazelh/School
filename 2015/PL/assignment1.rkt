;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname assignment1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Class:      CS 4400 - Programming Languages
Professor:  Eli Barzilay
Assignment: 1
Student:    Nicholas Jones
Date:       1/17/2015
|#

;;======================================================================
;; Problem 2
;;======================================================================

;; near? : Number Number Number -> Boolean
;; Are the 3 numbers within an interval of 2?
(define (near? x y z)
  (let ([high (max x y z)]
        [low (min x y z)])
    (<= (- high low)
        2)))
;; Tests/Examples
(near? 1 -1 1)
(not (near? 2 -2 2))
(near? 0 0 0)
(near? 1 1 1)
(near? 1 2 3)
(near? 1 3 2)
(near? 3 2 1)
(near? 3 1 2)
(near? 2 3 1)
(near? 2 1 3)
(not (near? 0 0 3))

;;======================================================================
;; Problem 3
;;======================================================================

;; count-xs*: [Listof Symbol] Number -> Number
;; A helper that counts the x symbols using an accumulator
;; This is a helper for count-xs
(define (count-xs* list acc)
  (cond [(empty? list) acc]
        [else (count-xs* (rest list)
                         (if (symbol=? 'x (first list))
                             (add1 acc)
                             acc))]))
;; Tests/Examples:
(equal? (count-xs* empty 0) 0)
(equal? (count-xs* empty 1) 1)
(equal? (count-xs* '(x) 0) 1)
(equal? (count-xs* '(x) 1) 2)

;; count-xs: [Listof Symbol] -> Number
;; How many x symbols are in the list?
(define (count-xs list)
  (count-xs* list 0))
;; Tests/Examples:
(equal? (count-xs empty) 0)
(equal? (count-xs '(x)) 1)
(equal? (count-xs '(x x x)) 3)
(equal? (count-xs '(y y y)) 0)
(equal? (count-xs '(x y x)) 2)
(equal? (count-xs '(x y z x)) 2)

;;======================================================================
;; Problem 4
;;======================================================================

;; ascending?: [Listof Number] -> Boolean
;; Are the numbers in the list ascending from left to right?
(define (ascending? list)
  (or (empty? list)
      (= (length list) 1)
      (and (<= (first list) (second list))
           (ascending? (rest list)))))
;; Tests/Examples
(ascending? empty)
(ascending? '(1))
(ascending? '(1 1))
(ascending? '(1 2))
(ascending? '(1 1 2))
(not (ascending? '(2 1)))
(ascending? '(1 2 3 4 5 6 7))
(not (ascending? '(1 2 3 4 5 6 0)))

;;======================================================================
;; Problem 5
;;======================================================================

;; zip2*: [Listof A] [Listof B] [Listof [List A B]]
;;        -> [Listof [List A B]]
;; Combine two lists together such that A_n and B_n are paired
;; together using an accumulator.
;; Lists must be of equal length
;; This is a helper for zip2.
(define (zip2* list1 list2 acc)
  (cond [(empty? list1) (reverse acc)]
        [else (zip2* (rest list1)
                     (rest list2)
                     (cons (list (first list1)
                                 (first list2))
                           acc))]))
;; Tests/Examples:
(equal? (zip2* empty empty empty) empty)
(equal? (zip2* '(1) '(x) empty) '((1 x)))
(equal? (zip2* '(x) '(1) empty) '((x 1)))
(equal? (zip2* (list 1 2 3) (list 'a 'b 'c) empty)
        (list (list 1 'a) (list 2 'b) (list 3 'c)))

;; zip2: [Listof A] [Listof B] -> [Listof [List A B]]
;; Combine two lists together such that A_n and B_n are paired together
;; Lists must be of equal length
(define (zip2 list1 list2)
  (zip2* list1 list2 empty))
;; Tests/Examples
(equal? (zip2 empty empty) empty)
(equal? (zip2 '(1) '(x)) '((1 x)))
(equal? (zip2 '(x) '(1)) '((x 1)))
(equal? (zip2 (list 1 2 3) (list 'a 'b 'c))
        (list (list 1 'a) (list 2 'b) (list 3 'c)))

;;======================================================================
;; Problem 6
;;======================================================================

(define my-picture 66)
(define my-other-pictures null)

;;======================================================================
;; Problem 7
;;======================================================================

(define minutes-spent 60) ; Here and there.