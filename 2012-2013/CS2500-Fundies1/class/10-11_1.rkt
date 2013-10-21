;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname 10-11_1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
October 11, 2012

Class Work
|#

;; You can now use (list ...)
;; However, when writing data definitions, use cons and empty.


;; -------------------------------------


;; A NSet is one of:
;; -- empty
;; -- (cons Number NSet)
;; Interpretation: represents a "set" of Numbers
;; i.e. order of elements does not matter and
;; elements can repeat.

;; Template:
#; (define (nset-temp set)
     (cond [(empty? set)]
           [else ...]))

;; Example Data:
(define s1 empty)        ;;  { }
(define s2 (list 3))     ;; {3}
(define s3 (list 2 4 1)) ;; {1,2,4}
(define s4 (list 3 4 4)) ;; {3,4}


;;---------------------------------------


;; contains? : NSet Number -> Boolean
;; is the number in the set?
;; Examples:
;;    s1 3 -> false
;;    s2 3 -> true
(define (contains? set num)
  (and (not (empty? set))
       (or (= (first set) num)
           (contains? (rest set) num))))
;; Tests:
(check-expect (contains? s1 3) false)
(check-expect (contains? s2 3) true)
(check-expect (contains? s3 4) true)


;; subset? : NSet NSet -> Boolean
;; Is s-1 a subset of s-2?
;; Examples:
;;
(define (subset? s-1 s-2)
  (or (empty? s-1)
      (and (contains? s-2 (first s-1))
           (subset? (rest s-1) s-2))))
;; Tests:
(check-expect (subset? s2 s4) true)
(check-expect (subset? s1 s4) true)
(check-expect (subset? s3 s4) false)


;; set-equal? : NSet NSet -> Boolean
;; Do both sets have the same elements?
(define (set-equal? s-1 s-2)
  (and (subset? s-1 s-2)
       (subset? s-2 s-1)))
;; Tests:
(check-expect (set-equal? (list 3 5) (list 3 5)) true)
(check-expect (set-equal? (list 5 5) (list 3 5)) false)
(check-expect (set-equal? (list 3 5) (list 5 3)) true)
(check-expect (set-equal? (list 3 5) (list 3 5 7)) false)


;; union : NSet NSet -> NSet
;; s-1 U s-2
;; Examples:
;;
(define (union s-1 s-2)
  (cond [(empty? s-1) b]
        [else (cons (first s-1)
                    (union (rest s-1) s-2))]))