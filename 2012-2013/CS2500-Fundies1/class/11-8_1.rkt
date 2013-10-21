;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname 11-8_1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

;; [Listof X] [X Y -> Y] Y -> Y
(define (thing lon op init)
  (local [(define (thing-acc lon a)
            (cond [(empty? lon) a]
                  [(cons? lon)
                   (thing-acc (rest lon) (op (first lon)
                                             a))]))]
    (thing-acc lon init)))
;; Abstraction Applications
(define (prod lon) (thing lon * 1))
(define (sum lon) (thing lon + 0))
(define (len los) (thing los (λ (s n) (add1 n)) 0))
;; Tests/Examples
(check-expect (prod '(1 2 3 4)) 24)
(check-expect (sum '(1 2 3 4)) 10)
(check-expect (len (list "a" "b" "c")) 3)

;; midpoint
(define (midpoint a b)
  (/ (+ a b) 2))

;; sign-change?
(define (sign-change? a b)
  (or (and (positive? a)
           (negative? b))
      (and (negative? a)
           (positive? b))))

;; find-root : [Number -> Number] Number Number -> Number
;; Find an x value which makes the function zero.
;; ASSUME:
;; F is continuous
;; (positive? f(a)) => (negative? f(b))
;; (negative? f(a)) => (positive? f(b))
;; a <= b
;; Zooms range until size is less than epsilon
;; When range reached, returns +/- deltaX/2
(define EPSILON .000000000000000000000000000001)
(define (find-root f a b)
  (cond [(<= (- b a) EPSILON) (midpoint a b)]
        [else
         (local [(define f@a (f a))
                 (define f@b (f b))
                 (define m (midpoint a b))
                 (define f@m (f m))]
           (cond [(zero? f@a) a]
                 [(zero? f@b) b]
                 [(sign-change? f@a f@m)
                  (find-root f a m)]
                 [else
                  (find-root f m b)]))]))
;; Tests/Examples:
(find-root sin -3 3)
(find-root cos  1 3)
(find-root (λ (n) (- (expt n 4) 5)) 0 12)




