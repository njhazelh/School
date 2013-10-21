;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname 9-27_1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
Sept 27, 2012
In-class work
Recursion & Lists
Problem 1
|#

;; Back to Russian Dolls
(define-struct shell (color contents))
;; A RD is one of:
;;   -- String : represents the color
;;               of the solid doll
;;   -- (make-shell String RD)

(define a "yellow")
(define b (make-shell "orange"
                      "yellow"))
(define c (make-shell "red" 
                      (make-shell "orange"
                                  "yellow")))

#|
RECURSIVE TEMPLATE:

(define (rd-temp a-rd)
    (cond [(string? a-rd) ...]
          [else           ... (shell-color a-rd) ...
                              (rd-temp (shell-contents a-rd)) ...]))
|#

;; doll-levels : RD -> Number
;; Purpose     : Takes an RD and returns the number of
;;               dolls inside it.
;; Examples:
;; a -> 0
;; b -> 1
;; c -> 2
(define (doll-levels a-rd)
  (cond [(string? a-rd) 0]
        [else (add1 (doll-levels (shell-contents a-rd))) ]))

;; Tests
(check-expect (doll-levels a) 0)
(check-expect (doll-levels b) 1)
(check-expect (doll-levels c) 2)

;; doll-colors : RD -> List
;; Purpose     : Takes an RD and returns a list of the
;;               doll colors, starting from the outside.
;; Examples:
;; a -> (cons "yellow" empty)
;; b -> (cons "orange" (cons "yellow" empty))
;; c -> (cons "red"    (cons "orange" (cons "yellow" empty)))
(define (doll-colors a-rd)
  (cond [(string? a-rd) (cons a-rd empty)]
        [else           (cons (shell-color a-rd)
                              (doll-colors (shell-contents a-rd)))]))

;; Tests:
(check-expect (doll-colors a) 
              (cons "yellow" empty))
(check-expect (doll-colors b) 
              (cons "orange" (cons "yellow" empty)))
(check-expect (doll-colors c) 
              (cons "red"    (cons "orange" (cons "yellow" empty))))

;; A LoS is one of:
;;   - empty
;;   - (cons String LoS)

#|
LoS Template:
(define (los-temp los)
  (cond [(empty? los) ...]
        [else         ... (first los)           ...
                          (los-temp (rest los)) ...]))
|#

;; total-length : LoS -> Number
;; Purpose      : Takes a LoS and returns the length of
;;                all the strings added together.
(define los1 (cons "a" empty))
(define los2 (cons "a" (cons "b" empty)))
(define los3 (cons "a" (cons "b" (cons "cd" empty))))
;; Examples:
;; (cons "a" empty) -> 1
;; (cons "a" (cons "b" empty)) -> 2
;; (cons "a" (cons "b" (cons "cd" empty))) -> 4
(define (total-length los)
  (cond [(empty? los) 0]
        [else         (+ (string-length (first los)) 
                         (total-length (rest los)))]))

;; Tests:
(check-expect (total-length los1) 1)
(check-expect (total-length los2) 2)
(check-expect (total-length los3) 4)

;; in?     : LoS String -> Boolean
;; Purpose : Given a list of strings and a string s,
;;           checks if s is in the list
;; Examples:
;; los1 "a" -> true
;; los2 "s" -> false
(define (in? los str)
  (cond [(empty? los) false]
        [else (or (string=? (first los)
                            str) 
                  (in? (rest los)
                       str))]))

;; Could also write with if.
#;(define (in? los str)
    (if (empty? los) ;; TEST
        false        ;; THEN
        (or (string=? (first los) ;; ELSE
                      str) 
            (in? (rest los)
                 str))))

;; Tests
(check-expect (in? los1 "a") true)
(check-expect (in? los2 "c") false)

;; replace-string : String String String -> String
;; Purpose        : Takes an old string, a test string, and 
;;                  replacement string. Returns new if test is
;;                  equal to old, else returns old.
;; Reference      : Desgined for use in (replace LoS String String)
;; Examples:
;; "a" "a" "c" -> "c"
;; "a" "b" "c" -> "a"
(define (replace-string str test new)
  (cond [(string=? str test) new]
        [else str]))

;; Tests
(check-expect (replace-string "a" "a" "c") "c")
(check-expect (replace-string "a" "b" "c") "a")

;; replace : LoS String String -> LoS
;; Purpose : Takes a list of strings and replaces the
;;           old string with the new string.
;; Examples:
;; los1 "a" "x" -> (cons "x" empty)
;; los2 "c" "y" -> (cons "a" (cons "b" empty))
(define (replace los old new)
  (cond [(empty? los) empty]
        [else (cons (replace-string (first los) old new)
                    (replace (rest los)
                             old
                             new))]))

;; Tests
(check-expect (replace los1 "a" "x")
              (cons "x" empty))
(check-expect (replace los2 "c" "y")
              (cons "a" (cons "b" empty)))
(check-expect (replace empty "c" "y")
              empty)




