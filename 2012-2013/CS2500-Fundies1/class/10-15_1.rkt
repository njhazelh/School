;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname 10-15_1) (read-case-sensitive #t) (teachpacks ((lib "guess.ss" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "guess.ss" "teachpack" "htdp")))))
#|
Nicholas Jones
October 15th, 2012
Class Work

Midterm: 335 Shillman
6pm - 9pm
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; TOPIC: FUNCTIONS DRIVEN BY BOTH INPUTS ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A LON is one of:
;; -- empty
;; -- (cons Number LON)

(define list1 (list 1 2 3))
(define list2 (list 9 8 7))

;; A LOP is one of:
;; -- empty
;; -- (cons Posn LOP)

;; zip : LON LON -> LOP
;; Creates a list of pairs from the two lists in ordered fashion.
;; Lists must be the same length; otherwise, report an error.
;; Examples:
#|
list1            list2            answer
empty            empty            empty
(cons i ra)      empty            error: unequal-length
empty            (cons i ra)      error: unequal-length
|#
(define (zip a b)
  (cond [(and (empty? a) (empty? b)) empty]
        [(or (empty? a) (empty? b)) (error 'zip "Lists of unequal length")]
        [else (cons (make-posn (first a)
                               (first b))
                    (zip (rest a)
                         (rest b)))]))

;; Tests:
(check-expect (zip list1 list2) (list (make-posn 1 9)
                                      (make-posn 2 8)
                                      (make-posn 3 7)))
(check-expect (zip empty empty) empty)
(check-error (zip list1 empty) "zip: Lists of unequal length")
(check-error (zip empty list2) "zip: Lists of unequal length")







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; EQUAL FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; An Atom is on of:
;; -- Number
;; -- Symbol
;; -- String

(define atom1 12)
(define atom2 'c)
(define atom3 "c")

;; atom? : Anything -> Boolean
;; Is the input an atom?
;; Examples:
;;    13  -> true
;;    'c  -> true
;;    "c" -> true
;;    #f  -> false
(define (atom? x)
  (or (number? x)
      (symbol? x)
      (string? x)))
;; Tests:
(check-expect (atom? 13) true)
(check-expect (atom? 'c) true)
(check-expect (atom? "v") true)
(check-expect (atom? true) false)


;; atom=? : Atom Atom -> Boolean
;; Are the two atoms equal?
;; Examples:
;;    atom1 12  -> true
;;    atom2 'c  -> true
;;    atom3 "c" -> true
;;    atom1 'c  -> false
;;    atom2 12  -> false
;;    atom3 12  -> false
(define (atom=? a1 a2)
  (or (and (number? a1)
           (number? a2)
           (= a1 a2))
      (and (symbol? a1)
           (symbol? a2)
           (symbol=? a1 a2))
      (and (string? a1)
           (string? a2)
           (string=? a1 a2))))
;; Tests:
(check-expect (atom=? atom1 12) true)
(check-expect (atom=? atom2 'c) true)
(check-expect (atom=? atom3 "c") true)
(check-expect (atom=? atom1 'c)  false)
(check-expect (atom=? atom2 12)  false)
(check-expect (atom=? atom3 12)  false)







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; MUTUTAL RECURSION ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; An SExp (S-Expression) is one of:
;; -- Atom
;; -- LOS

;; A LOS (list of SExp) is one of:
;; -- empty
;; -- (cons SExp LOS)


;; los=? : LOS LOS -> Boolean
;; Are the two LOS equal?
;; Examples:
(define (los=? los1 los2)
  (cond [(and (empty? los1)
              (empty? los2)) true]
        [(and (cons? los1)
              (empty? los2)) false]
        [(and (empty? los1)
              (cons? los2))  false]
        [else (and (eqwal? (first los1)
                           (first los2))
                   (los=? (rest los1)
                          (rest los2)))]))
;; Tests:





;; eqwal? : SExp SExp -> Boolean
;; Are the two SExp equal?
;; Examples:
;;
(define (eqwal? s1 s2)
  (cond [(and (atom? s1)
              (atom? s2)) (atom=? s1 s2)]
        [(or (and (not (atom? s1))
                  (atom? s2))
             (and (atom? s1)
                  (not (atom? s2)))) false]
        [else (los=? s1 s2)]))
;; Tests:
(check-expect (eqwal? 1 2) #f)


#|
Value of S-Expressions:

Programs are represented in DrRacket and Lisp
as S-Expressions.

'(+ (* 4 5) 80) -> (list '+ (list '* 4 5) 80)
|#




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; QUADRATIC EQUATIION ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; YOU HAVE NOW GRADUATED TO INTERMEDIATE LANGUAGE !!!
;; ACCESS TO "LOCAL" NOW GRANTED FOR USE AT YOUR DISCRETION.

;; roots : Number Number Number -> Posn
;; Solve a function ax^2 + bx + C =0
;; Find the roots of the quadratic equation.
;; Examples:
;;  1 2 1 -> (make-posn -1 -1)
;;  
(define (roots a b c)
  (local ((define (sqrt-d d) (sqrt d))
          (define sd (sqrt-d (- (sqr b) (* 4 a c))))
          (define -b (- b))
          (define 2a (* 2 a)))
  (make-posn (/ (+ -b sd)
                2a)
             (/ (- -b sd)
                2a))))
;; Tests:
(check-expect (roots 1 2 1) (make-posn -1 -1))



;; A NELon is one of:
;; -- (cons Number empty)
;; -- (cons Number NELon)

;; biggest : NELon -> Number
;; Return biggest number in list.
(define (biggest nelon)
  (local ((define (max n1 n2)
            (if (>= n1 n2) n1 n2)))
  (cond [(empty? (rest nelon)) (first nelon)]
        [else (max (first nelon)
                   (biggest (rest nelon)))])))


;; Test equation to make big list
(define (fill-list start end)
  (if (>= start end)
      empty 
      (cons start 
            (fill-list (add1 start)
                             end))))

;; Tests
(check-expect (biggest (list 3 4 6 120 78 30)) 120)
(check-expect (biggest (list 67 89 20 1 102 32498)) 32498)
(check-expect (biggest (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27)) 27)
(check-expect (biggest (fill-list 0 70000)) 69999)

;;; OR

;; biggest2 : NELon -> Number
;; Return biggest number in list.
(define (biggest2 nelon)
  (cond [(empty? (rest nelon)) (first nelon)]
        [else (local ((define ans (biggest (rest nelon))))
              (cond [(< (first nelon) ans) ans]
                    [else (first nelon)]))]))

;; Tests
(check-expect (biggest2 (list 3 4 6 120 78 30)) 120)
(check-expect (biggest2 (list 67 89 20 1 102 32498)) 32498)
(check-expect (biggest2 (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27)) 27)
(check-expect (biggest2 (fill-list 0 70000)) 69999)


#| -----------------------------------------------------------
======================= SYTLE CHOICE NOTE ====================
 
If a helper function is useless anywhere else, define as local
else define globally. Also, a local functions should be simple
to understand.

------------------------------------------------------------|#


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; ABSTRACTION ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define an abstract operation function to operate on a list.

;; Observation: You can pass functions as variables!!!!
;; THIS MEANS SCHEME IS A HIGHER ORDER LANGUAGE

;; ABSTRACT DATA DEFINITION
;; A [List of X] is one of:
;; -- empty
;; -- (cons X [List of X])

;; process : Operation Data [List of Data] -> Data
;; Processes the list with the operation defined by op.
(define (process op base list)
  (cond [(empty? list) base]
        [else (op (first list)
                  (process op
                           base
                           (rest list)))]))



;;; THERE IS A BUILT IN FUNCTION LIKE PROCESS CALLED foldr (fold from right)