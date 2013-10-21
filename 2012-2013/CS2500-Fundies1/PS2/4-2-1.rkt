;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname 4-2-1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;;; 4.2.1

;; Is the result between 3 and 7 inclusive: (3,7]
;; 1 - false, 3 - false, 6 - true, 7 - true, 9 -false
(define (problem-1 x)
  (and (> x 3) (<= x 7)))

;; Is the result between 3 inclusive and 7 inclusive: [3,7]
;; 1 - false, 3 - true, 6 - true, 7 - true, 9 -false
(define (problem-2 x)
  (and (>= x 3) (<= x 7)))

;; Is the result between 3 inclusive and 9 [3,9)
;; 1 - false, 3 - true, 6 - true, 7 - true, 9 -false
(define (problem-3 x)
  (and (>= x 3) (< x 9)))

;; Is the result between (1,3) or (9,11)
;; 0-false, 1-false, 2-true, 3-false, 6-false, 9-false, 10-true, 11-false, 12-false
(define (problem-4 x)
  (or (and (> x 1) (< x 3)) (and (> x 9) (< x 11))))

;; Is the number outside of [1,3]
;; 0-true, 1-false, 2-false, 3-false, 4-true
(define (problem-5 x)
  (not (and (>= x 1) (<= x 3))))