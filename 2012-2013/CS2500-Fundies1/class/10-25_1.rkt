;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname 10-25_1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
In-class work
Fundamental Computer Science I
October 25th 2012
|#

;; Local define : when it's evaluated
#;(define (bar x)
  (cond [(= x 5) (local ((define res (error 'pop "error")))
                   (cond [(= x 5) 0]
                         [else 0]))]))

;; NOTE: RES IS EVALUATED AS SOON AS (= x 5)

;; my-length : [Listof X] -> Number
;; Computer the number of elements in input list
(define (my-length xs)
  (cond [(empty? xs) 0]
        [else (add1 (my-length (rest xs)))]))

;; my-length : [Listof X] -> Number
;; Computer the number of elements in input list
(define (my-length-2 xs)
  (foldr (λ (x len) (add1 len))
         0
         xs))



;; self-collide : Posn [Listof Posn] -> Boolean
(define (self-colide? head body)
  (ormap (λ (piece) (posn? head piece)) body))


;; Look at APPLY
(build-list 20 (λ (n) (sqr (add1 n))))
(apply + (build-list 20 (λ (n) (sqr (add1 n)))))

