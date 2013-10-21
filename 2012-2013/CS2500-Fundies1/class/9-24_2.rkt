;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname sept24-2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
9/24/2012
Class Notes and Work
Problem 2: Recursion
|#

;; Matryoshka dolls
(define-struct shell (contents))
#|
A RD (russian doll) is one of:
    -- 'solid
    -- (make-shell 'solid)
    -- (make-shell (make-shell 'solid))
    -- ...

Template:
(define (rd-template rd)
   (cond [(and (symbol? rd) (symbol=? rd 'solid)) ... ]
         [(symbol? (shell-contents rd))           ... ]
         [(shell?  (shell-contents rd))           ... ]))
|#

;; doll-levels-short : RD -> Number
;; Takes an RD and produces the number of
;; dolls inside it
;; Examples:
;;     'solid                           -> 0
;;     (make-shell 'solid)              -> 1
;;     (make-shell (make-shell 'solid)) -> 2
(define (doll-levels-short rd)
  (cond [(and (symbol? rd) (symbol=? rd 'solid)) 0 ]
        [(symbol? (shell-contents rd))           1 ]
        [(shell?  (shell-contents rd))           2 ]))
;; Tests:
(check-expect (doll-levels-short 'solid)                           0)
(check-expect (doll-levels-short (make-shell 'solid))              1)
(check-expect (doll-levels-short (make-shell (make-shell 'solid))) 2)

#|
WANT ABILILTY TO HAVE INFINITE DOLLS!!!

An RD is one of:
    -- 'solid   <-- base case
    -- (make-shell RD)

Recursive templates in next class
|#