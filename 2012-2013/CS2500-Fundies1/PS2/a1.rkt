;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname a1) (read-case-sensitive #t) (teachpacks ((lib "guess.ss" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "guess.ss" "teachpack" "htdp")))))
;;; PS2 A1

;; Finds the number of units of insulin that a person needs
;;    considering their current blood sugar level
;; (bsl,insulin): (0,0) (115,1) (300,10)
(define (insulin-needed bsl)
  (cond [(< bsl 115) 0]
        [else (+ (floor (/ (- bsl 115) 20)) 1)]))

(check-expect (insulin-needed 100) 0)
(check-expect (insulin-needed 170) 3)
(check-expect (insulin-needed 190) 4)
(check-expect (insulin-needed 200) 5)

;; Finds the pay depending on the number of hours worked
;;   according to equation P = 11.25T +40
;; (time,pay):(0,40) (1,51.25) (2,62.5)
(define (pay time)
  (+ (* time 11.25) 40))

(check-expect (pay 2)   62.5)
(check-expect (pay 10) 152.5)
(check-expect (pay 100) 1165)