;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname 11-19_1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
11-19-2012

Class Work

Y-COMBINATOR LECTURE
|#
#|
#|
let = simple version of local define
e.g. (let ((x exp)) body) -> rewrite ((λ (x) body) exp)
let and define are not primitive, λ is.


|#

;; len : defined as a variable
;; finds the length of a list
(define len (λ (xs)
               (if (empty? xs)
                   0
                   (add1 (len (rest xs))))))

;; remove define.
(let ((len (λ (xs)
             (if (empty? xs)
                 0
                 (add1 (len (rest xs)))))))
  (len '(3 4 2)))

;; remove let
((λ (len) (len '(3 4 2)))
 (λ (xs) ;; This is len, which is passed to the program as a var.
   (if (empty? xs)
       0
       (add1 (len (rest xs))))))


;; puzzle
;; what does (λ (x) (x x)) do?
;; what does ((λ (x) (x x)) (λ (y) (y y)))
;; -- infinite loop.

;; fixed point
;; f(x) then fixed point is the value which f(x) returns unchanged.
;; e.g. f(x) = x^2 + x - 3
;;      f(z) = z? z = (sqrt 3) <= fixed point

;; length function
(define f (λ (len)
            (λ (xs) (if (empty? xs) 0 (add1 (len (rest xs)))))))

;; Death function
(define DF (λ (x) (/ 1 0)))

;; func that works for lists of length 0
(f DF)

;; fun that works for lists of length 0 or 1
(f (f DF))

;; ...

;; len is the fixed point of f.


;;;;;

;;; want to find a fixed point.
;; suppose have magic function g such that (g g) = fixed point.
;; Generator = [Generator -> Generator]
;; G for Generator
;; G : Generator -> Generator

;; (f (G G)) = (G G)
;; only don't have a G.
;; suppose we do.
;; (λ (G) (F (G G))) : Generator -> Answer
;; so
#;((λ (G) (F (G G)))
   (λ (G) (F (G G))))
;; is the answer

#;((λ (f) ((λ (G) (f (G G)))
           (λ (G) (f (G G)))))
   (λ (len) (λ (xs) (if (empty? xs) 0 (add1 (rest xs))))))

|#
;; (f (y f)) = (y f)
;; (y f) = ((λ (G) (F (G G)))
;;          (λ (G) (F (G G))))

;; The Complicated way to write 120.
(((λ (F)
    ((λ (G)
       (F (λ (X)
            ((G G) X))))
     (λ (G)
       (F (λ (X)
            ((G G) X))))))
  (λ (fact)
    (λ (n)
      (if (zero? n)
          1
          (* n
             (fact (sub1 n)))))))
 5)

#|
(define Y (λ (F) ((λ (G) (F (λ (X) ((G G) X))))
                  (λ (G) (F (λ (X) ((G G) X)))))))

;; Church Encodings
(define tru (λ (a b) a))
(define fals (λ (a b) b))

(λ (b) (b 3 5)) ;; select from 3 and 5

(define not.v1 (λ (b) (λ (x y) (b x y))))
(define not.v2 (λ (b) (b fals tru)))

(define mak-posn (λ (x y) (λ (f) (f x y))))
(define get-x (λ (p) (p (λ (a b) a))))
(define get-y (λ (p) (p (λ (a b) b))))
(get-x (mak-posn 3 4))
(get-y (mak-posn 3 4))


;; A CNum (Church Numeral) =  [X -> X] -> [X -> X]
;; (n f) = f^n
(define z (λ (f) (λ (x) x)))
(define add-one (λ (cn) (λ (f) (λ (x) (f ((cn f) x))))))




|#













