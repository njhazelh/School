;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname 5-1-2) (read-case-sensitive #t) (teachpacks ((lib "guess.ss" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "guess.ss" "teachpack" "htdp")))))
;;; 5.1.2

;; Checks the guess with the target
;; (1,2) -> 'TooSmall
;; (2,1) -> 'TooLarge
;; (2,2) -> 'Perfect
(define (check-guess guess target)
  (cond [(< guess target) 'TooSmall]
        [(> guess target) 'TooLarge]
        [else 'Perfect]))

