;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname 11-1_1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
Class-work

November 1, 2012
|#

;; Makeup lab this Sunday @ 6pm.

;; SExp = Symbol | [Listof SExp]


;; flatten-list -> [Listof SExp] -> [Listof Symbol]
;; Extracts all the symbols from the list in order
#;(define (flatten-list l)
  (cond [(empty? l) empty]
        [else (append (flatten (first l))
                      (flatten-list (rest l)))]))

;; flatten-list -> [Listof SExp] -> [Listof Symbol]
;; Extracts all the symbols from the list in order
(define (flatten-list l)
  (foldr (λ (sexp rest) (append (flatten sexp) rest)) empty l))
;; Tests/Examples:
(check-expect (flatten-list '(a b c)) '(a b c))
(check-expect (flatten-list '()) empty)
(check-expect (flatten-list '((a b) c d (e ((f))))) '(a b c d e f))
 
 
 
;; flatten : SExp -> [Listof Symbol]
;; Extract all the symbols of the SXep in order
#;(define (flatten se)
  (cond [(symbol? se) (list se)]
        [else (flatten-list se)]))

(define (flatten sexp)
  (cond [(symbol? sexp) (list sexp)]
        [else (apply append (map flatten sexp))]))
;;Tests/Examples:
(check-expect (flatten 'a) '(a))
(check-expect (flatten '()) empty)
(check-expect (flatten '((a b) c d (e ((f)))))
              '(a b c d e f))





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SETS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Set a list of anything without repetition.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-struct X (left right))


;; contains? : Set Anything -> Boolean
;; is elt a memb er of the set?
(define (contains? s x)
  (ormap (λ (anything) (equal? x anything)) s))

;;subset? : Set Set -> Boolean
;; Is xs a subset of ys
(define (subset? xs ys)
  (andmap (λ (x) (contains? ys x))
          xs))

;; set=? : Set Set -> Set
;; Are the two sets equal?
(define (set=? xs ys)
  (and (subset? xs ys)
       (subset? ys xs)))

;; intersect : Set Set -> Set
;; Create the set that contians the elements
;; that cthe wwo sets share
(define (intersect xs ys)
  (local ((define (in-xs? y) (contains? xs y)))
    (filter in-xs? ys)))

;; union : Set Set -> Set
;; Create the set that contains the elements of both
#;(define (union xs ys)
    (local ((define (not-in-xs? y) (not (contains? xs y))))
      (append xs (filter not-in-xs? ys))))

;; union : Set Set -> Set
;; Create the set that contains the elements of both
(define (union xs ys)
    (foldr (λ (y ans)
             (if (contains? ans y)
                 ans
                 (cons y ans)))
           xs
           ys))

;; cartesian : Set Set -> Set
;; Create all the possible (make-X xs ys) of elements
;; xs from set1 and s2 from s2
(define (cartesian xs ys)
  (apply append
         (map (λ (x)
                (map (λ (y) (make-X x y))
                     ys))
              xs)))



;; Examples:
(define car '(bmw ford vw))
(define nats (λ (x) (and (integer? x)
                         (>= 
                         )
(define evens (lambda (x) (even? x)))
(define odds '(1 3 5 7 9))
(define symbols '(a b c d e f g))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Set = Anything -> Boolean
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; contains? : Set Anything -> Boolean
;; is elt a member of the set?
(define (contains? s elt)
  (s elt))

;;subset? : Set Set -> Boolean
;; Is xs a subset of ys

;; set=? : Set Set -> Set
;; Are the two sets equal?

;; intersect : Set Set -> Set
;; Create the set that contians the elements
;; that cthe wwo sets share
(define (intersect s t)
  (lambda (x) (and (s x)
                   (s t))))

;; union : Set Set -> Set
;; Create the set that contains the elements of both
(define (union s t)
  (lambda (x) (or (s x)
                   (s t))))


(define (add-elt s y)
  (lambda x) (or (equal? y x) (s x)))

;; WHEN TESTING RANDOM FUNCTIONS TEST BY PROPERTIES.





