;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname 11-5_1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
Class Work

Remember, remember, the ....

Accumulators
   -- When realize not enough information, (need past info).
Generative Recursion
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                    ACCUMULATORS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; app: Append
#;(define (app ls1 ls2)
  (cond [(empty? ls1) ls2]
        [(cons? ls1)
         (cons (first ls1)
               (app (rest ls1)
                    ls2))]))

;; rev: [Listof Number] -> [Listof Number]
;; Reverse given list of Numbers
#;(define (rev ls)
  (cond [(empty? ls) ls]
        [(cons? ls)
         (append (rev (rest ls))
                 (list (first ls)))]))
;; Tests/Examples:
#;(check-expect (rev '(1 2 3)) '(3 2 1))
#;(check-expect (rev empty) empty)

;; INEFFICENT!!!!!
;; Must traverse serveral times just to do one number
#;(time (first (rev (make-list 1000000 'x)))) ;; TAKES WAY TOO LONG.


;;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/


;; rev/a
;; Computes (append (rev ls) a)
(define (rev/a ls a)
  (cond [(empty? ls) a]
        [(cons? ls)
         (rev/a (rest ls)
                (cons (first ls)
                      a))]))
;; Tests/Examples
(check-expect (rev/a '(1 2 3) '(6 5 4))
              '(3 2 1 6 5 4))
  


;; rev : [Listof Number] -> [Listof Number]
;; Reverses a list of Numbers
(define (rev ls)
  (rev/a ls empty))
;; Tests/Examples:
(check-expect (rev '(1 2 3)) '(3 2 1))
(check-expect (rev empty) empty)
(time (first (rev (make-list 100000 'x))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; INEFFICIENT AGAIN!!!!
;; rel->abs : [Listof Number] -> [Listof Number]
;; Takes a list of relative distances and combines them to find
;; the absolute distances covered.
#;(define (rel->abs ls)
  (cond [(empty? ls) empty]
        [(cons? ls)
         (local [(define (add-first n)
                   (+ (first ls) n))]
           (cons (first ls)
                 (map add-first
                      (rel->abs (rest ls)))))]))
;; Tests/Examples:
#;(check-expect (rel->abs '(1 2 3)) '(1 3 6))


;;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/


;; MUCH BETTER: ONLY RECURSES ONCE!
;; rel->abs/a : [Listof Number] Number -> [Listof Number]
;; Acccumulates the absolute distance traveled so far.
(define (rel->abs/a ls a)
  (cond [(empty? ls) empty]
        [(cons? ls)
         (cons (+ (first ls) a)
               (rel->abs/a (rest ls)
                           (+ (first ls) a)))]))



;; rel->abs :  [Listof Number] -> [Listof Number]
(define (rel->abs ls)
  (rel->abs/a ls 0))
;; Tests/Examples:
(check-expect (rel->abs '(1 2 3)) '(1 3 6))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               GENERATIVE RECURSION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#;(define (gen-template in)
    (cond [(trivial1? in) solution1]
          [(trivial2? in) solution2]
          ...
          [(complex? in)
           (put-together
            (gen-template (gen-subproblem1 in))
            (gen-template (gen-subproblem2 in)))]))




;; slow-expt : Natural Natural ->  Natural
;; Compute n^m
(define (slow-expt n m)
  (cond [(zero? m) 1]
        [else
         (* n
            (slow-expt n (sub1 m)))]))
;; Tests/Examples:
(check-expect (slow-expt 5 0) 1)
(check-expect (slow-expt 3 4) 81)
#;(time (number? (slow-expt 5 100000))) ;; 5772 real time


;;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

(define (half num)
  (quotient num 2))

;; THIS VERSION RAPIDLY CUTS DOWN THE NUMBER OF MULTIPLICATIONS
;; fast-expt : Natural Natural ->  Natural
;; Compute n^m
(define (fast-exp n m)
  (cond [(zero? m) 1]
        [(even? m)
         (sqr (fast-exp n (half m)))]
        [else
         (* n
            (fast-exp n (sub1 m)))]))
;; Tests/Examples:
(check-expect (fast-exp 5 0) 1)
(check-expect (fast-exp 3 4) 81)
(time (number? (fast-exp 5 100000))) ;; 15 real time


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; insert : Number [Listof Number] -> [Listof Number]
;; Inserts a number into the correct location in the list
(define (insert num slon)
  (cond [(empty? slon) (list num)]
        [(cons? slon)
         (cond [(> num (first slon))
                (cons (first slon)
                      (insert num (rest slon)))]
               [else (cons num slon)])]))

;; sort : [Listof Number] -> [Listof Number]
;; Sort list of numbers into accending order
(define (my-sort lon)
  (cond [(empty? lon) empty]
        [(cons? lon)
         (insert (first lon)
                 (my-sort (rest lon)))]))
;; Test/Examples:
(check-expect (my-sort empty) empty)
(check-expect (my-sort '(10 9 8 7 6 5 4 3 2 1)) '(1 2 3 4 5 6 7 8 9 10)) 


;;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
;;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/


;; qsort : [Listof Number] -> [Listof Number]
;; Faster way to sort
;; Original version enters infinite loop: Needs a termination argument.
(define (qsort lon)
  (cond [(empty? lon) empty]
        [else
         (local [(define pivot (first lon))
                 (define biggers (filter (λ (n) (> n pivot)) lon))
                 (define equals (filter (λ (n) (= n pivot)) lon))
                 (define smallers (filter (λ (n) (< n pivot)) lon))]
           (append (qsort smallers)
                   equals
                   (qsort biggers)))]))
;; Tests/Examples:
(check-expect (qsort '(2 1)) '(1 2))
(check-expect (qsort '(10 9 8 7 6 5 4 3 2 1)) '(1 2 3 4 5 6 7 8 9 10))
(check-expect (qsort (build-list 1000 (λ (n) (- 1000 n 1))))
              (build-list 1000 (λ (n) n)))


;; msort
(define (msort lon)
  (cond [(empty? lon) 




