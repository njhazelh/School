;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname 4-4-1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;;; 4.4.1

;; Get the interest for a year given a fixed input at the beginning of the year
;; Interest rate varies with initial amount
;; in: 1000 5000 10000
;; out:  40  225   500

(define (interest amount)
  (cond [(<= amount 1000) (* amount .04)]
        [(<= amount 5000) (* amount .045)]
        [else (* amount .05)])
  