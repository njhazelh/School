;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname 4-4-4) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;;; 4.4.4

;; Determine the number of values where the quadratic equation specified by a,b,c is zero
;; (1,1,1) -> 0
;; (1,0,-1)-> 2
;; (2,4,2) -> 1
;; (3,4,5) -> 0
;; (1,4,4) -> 1
;; (1,3,2) -> 2
(define (how-many a  b c)
  (cond [(> (sqr b) (* 4 a c)) 2]
        [(= (sqr b) (* 4 a c)) 1]
        [(< (sqr b) (* 4 a c)) 0]))

;; If the function was not assumed to be proper, we would also have to account for linear equations, which have 1 solution.


  
  