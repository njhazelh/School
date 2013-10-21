;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ps9) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
Douglas Gobron
Problem Set 9h
Due: 11/20/2012 @ 11:59pm
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 21.1.3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; natural-f : Number Y [X Y -> Y] X -> Y
;; Performs the function "op" n times
(define (natural-f n base op to-add)
  (cond [(zero? n) base]
        [else (op to-add
                  (natural-f (sub1 n) base op to-add))]))
;; Tests/Examples:
(check-expect (natural-f 3 empty cons 'a) '(a a a))
(check-expect (natural-f 3 4 + 5) 19)



;; copy : Number X -> [Listof X]
;; Creates a list that contains obj n times.
(define (copy n obj)
  (natural-f n empty cons obj))
;; Tests/Examples:
(check-expect (copy 3 'a) '(a a a))



;; n-adder : Number Number -> Number
;; Add n to x using only (+ 1 ...)
(define (n-adder n x)
  (natural-f n x + 1))
;; Tests/Examples:
(check-expect (n-adder 3 4) 7)



;; n-multiplier : Number Number -> Number
;; Mutiply n by x using only addition.
(define (n-multiplier n x)
  (natural-f n 0 + x))
;; Tests/Examples:
(check-expect (n-multiplier 3 4) 12)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 22.2.1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;gen-map : [X -> Y] -> [[Listof X] -> [Listof Y]]
;; Generates a function that maps op to a list
(define (gen-map op)
  (local ((define (func list)
            (cond [(empty? list) empty]
                  [else (cons (op (first list))
                              (func (rest list)))])))
    func))
;; Tests/Examples:
(check-expect ((gen-map number->string) '(1 2 3)) '("1" "2" "3"))
(check-expect ((gen-map string->number) '("1" "2" "3")) '(1 2 3))
(check-expect ((gen-map (λ (n) (+ n 3))) '(1 2 3)) '(4 5 6))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 22.2.2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; gen-sort : [X X -> Boolean] -> [[Listof X] -> [Listof X]]
;; Sorts the given list in relation to rel-op.
;; Example: (gen-sort >) sorts a list of numbers into decending order.
(define (gen-sort rel-op)
  (local ((define (sort l)
            (local ((define (sort l)
                      (cond [(empty? l) empty]
                            [else (insert (first l) (sort (rest l)))]))
                    (define (insert n l)
                      (cond [(empty? l) (list n)]
                            [(rel-op n (first l)) (cons n l)]
                            [else (cons (first l)
                                        (insert n (rest l)))])))
              (sort l))))
    sort))
;; Tests/Examples:
(check-expect ((gen-sort <) '(3 78 4 1)) '(1 3 4 78))
(check-expect ((gen-sort >) '(3 78 4 1)) '(78 4 3 1))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.1.1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; make-even : Number -> Number
;; Tranforms a natural number, n, into the the n'th even number.
(define (make-even n)
  (* 2 n))
;; Tests/Examples:
(check-expect (make-even 3) 6)
(check-expect (make-even 1) 2)
(check-expect (make-even 0) 0)



;; series-even : Number -> Number
;; sums the first n even numbers.
(define (series-even n)
  (cond [(= n 0) (make-even n)]
        [else (+ (make-even n)
                 (series-even (sub1 n)))]))
;; Tests/Examples:
(check-expect (series-even 9) 90)



;; series-local : [Number -> Number] -> [Number -> Number]
;; Generates a function that sums the elements of the given series.
(define (series-local a-term)
  (local ((define (series n)
            (cond [(= n 0) (a-term n)]
                  [else (+ (a-term n)
                           (series (sub1 n)))])))
    series))
;; Tests/Examples:
(check-expect ((series-local make-even) 9)
              (series-even 9))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.2.1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; a-fives : Number -> Number
;; Takes a natural number and determines the appropriate term in the
;; sequence: 3 + 5(n+1)
(define (a-fives n)
  (if (= n -1)
      3
      (+ 5
         (a-fives (sub1 n)))))
;; Tests/Examples:
(check-expect (a-fives 0) 8)
(check-expect (a-fives 3) 23)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.2.2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; a-fives-closed : Number -> Number
;; Takes a natural number and determines the appropriate term in the
;; sequence: 3 + 5(n+1)
(define (a-fives-closed n)
  (+ 3 (* 5 (add1 n))))
;; Tests/Examples:
(check-expect (a-fives-closed 0) 8)
(check-expect (a-fives-closed 3) 23)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.2.3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define a-fives-3  ((series-local a-fives)  3)) ;;    62
(define a-fives-7  ((series-local a-fives)  7)) ;;   204
(define a-fives-88 ((series-local a-fives) 88)) ;; 20292

;; An infinite series has a sum of +/-infinity, because
;; start+infinity*increment = +/-infinity.  This cannot be calculated.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.2.4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; seq-a-fives : Number -> [Listof Number]
;; Generates a list of the first n numbers in
;; the sequence a-fives.
(define (seq-a-fives n)
  (build-list n a-fives-closed))
;; Tests/Examples:
(check-expect (seq-a-fives 2) '(8 13))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.2.5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; arithmetic-series : Number Number -> [Number -> Number]
;; Creates an arithmetic series with the start at start and
;; each number after incremented by s.
(define (arithmetic-series start s)
  (λ (n) (+ start (* s (add1 n)))))
;; Tests/Examples:
(check-expect ((arithmetic-series 3 5) 0)   (a-fives 0))
(check-expect ((arithmetic-series 3 5) 12) (a-fives 12))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.3.1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; g-fives : Number -> Number
;; recursively determines the corresponding term in the
;; geometric sequence g_n=3*5^n
(define (g-fives n)
  (if (= n 0)
      3
      (* 5
         (g-fives (sub1 n)))))
;; Tests/Examples:
(check-expect (g-fives 0) 3)
(check-expect (g-fives 3) 375)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.3.2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; g-fives-closed : Number -> Number
;; Takes a natural number and determines the appropriate term in the
;; sequence: 3*5^n
(define (g-fives-closed n)
  (* 3 (expt 5 n)))
;; Tests/Examples:
(check-expect (g-fives-closed 0) 3)
(check-expect (g-fives-closed 3) 375)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.3.3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; seq-g-fives : Number -> [Listof Number]
;; Generates a list of the first n numbers in
;; the sequence g-fives.
(define (seq-g-fives n)
  (build-list n g-fives-closed))
;; Tests/Examples:
(check-expect (seq-g-fives 5) '(3 15 75 375 1875))
(check-expect (seq-g-fives 2) '(3 15))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.3.4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; geometric-series : Number Number -> [Number -> Number]
;; Creates an geometic series with the start at start and
;; each number after multiplied by a power of s.
(define (geometric-series start s)
  (λ (n) (* start (expt s n))))
;; Tests/Examples:
(check-expect ((geometric-series 3 5) 0)   (g-fives 0))
(check-expect ((geometric-series 3 5) 12) (g-fives 12))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.3.5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define g-series-3  ((series-local (geometric-series 1 .1))  3)) ;;  1.111
(define g-series-7  ((series-local (geometric-series 1 .1))  7)) ;;  1.1111111
(define g-series-88 ((series-local (geometric-series 1 .1)) 88)) ;;  1.1111...

;; An infinite geometric series can have a sum, because if the ratio is
;; negative then the terms may cancel each other out by flipping between
;; positive and negative.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.3.7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ln-term: Number -> [Number -> Number]
;; Returns a function which can calculates the nth term of a taylor series of
;; ln


;; ln : Number -> Number
;; Calculates the value of ln(x)
(define (ln x)
  (local ((define (ln-taylor i)
            (* (/ 2 (add1 (* 2 i)))
               (expt (/ (- x 1)
                        (+ x 1))
                     (add1 (* 2 i))))))
    ((series-local ln-taylor) 100)))
;; Tests/Examples:
(check-range (abs (- (inexact->exact (ln e)) (log e))) 0 .01)
(check-range (abs (- (inexact->exact (ln 100)) (log 100))) 0 .01)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.3.8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; my-sin : Number -> Number
;; calculates the value of (sin x)
(define (my-sin x)
  (local ((define (! n)
            (cond [(= n 0) 1]
                  [else (* n (! (sub1 n)))]))
          (define (sin-taylor i)
            (local ((define sign (if (even? i) 1 -1)))
              (/ (* sign
                    (expt x (add1 (* 2 i))))
                 (! (add1 (* 2 i)))))))
    ((series-local sin-taylor) 100)))
;; Tests/Examples:
(check-range (abs (- (inexact->exact (my-sin e)) (sin e))) 0 .01)
(check-range (abs (- (inexact->exact (my-sin 0)) (sin 0))) 0 .01)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.3.9 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; greg : Number -> Number
;; Finds the nth term of the pi series.
(define (greg n)
  (local ((define sign (if (even? n) 1 -1)))
    (* sign
       (/ 4
          (add1 (* 2 n))))))
;; Tests/Examples:
(check-expect (greg 0) 4)
(check-expect (greg 1) -4/3)

(define pi-10    ((series-local greg)    10))
(define pi-20    ((series-local greg)    20))
(define pi-100   ((series-local greg)   100))
(define pi-1000  ((series-local greg)  1000))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.4.1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; integrate-kepler : [Number -> Number] Number Number -> Number
;; Finds the area under the function using the function using kepler's
;; rule.
;; Assumed that B >= A
(define (integrate-kepler func a b)
  (local ((define mid (/ (+ b a) 2))
          (define f@mid (func mid))
          (define domain/2 (/ (- b a) 2))
          (define (trapezoid b1 b2 h)
            (* 1/2 h (+ b1 b2))))
    (+ (trapezoid (func a)
                  f@mid
                  domain/2)
       (trapezoid (func b)
                  f@mid
                  domain/2))))
;; Tests/Examples:
(check-expect (integrate-kepler (λ (x) 5)  1 1) 0)
(check-expect (integrate-kepler (λ (x) 5)  0 5) 25)
(check-expect (integrate-kepler (λ (x) x)  0 5) 12.5)
(check-expect (integrate-kepler (λ (x) (sqr x)) -5 5) 125)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 23.4.2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; R : number of rectangles to approximate integral.
(define R 10)

;; integrate : [Number -> Number] Number Number -> Number
;; Calculates the area under the function using rectangle-series method
;; b >= a
(define (integrate func a b)
  (local ((define w (/ (- b a) R)))
    (apply +
           (build-list R
                       (λ (x)
                         (* w
                            (func (* w
                                     x))))))))
;; Tests/Examples: Given R = 10
(check-expect (integrate (λ (x) 5) 0 10) 50)
(check-expect (integrate (λ (x) 5) 1  1)  0)
(check-expect (integrate (λ (x) x) 0 10) 45)

;; As R moves from 10 -> 10000 the (integrate sin 0 pi) gets closer and
;; closer to 2, because it is becomeing more accurate.
(integrate sin 0 pi)


