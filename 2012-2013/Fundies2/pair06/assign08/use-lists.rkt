#lang class/2

(require (prefix-in q: "quick-lists.rkt"))
(require (prefix-in s: "slow-lists.rkt"))


;; A [List X] implements ...
;; - accept : [ListVisitor X Y] -> Y
;;   Accept given visitor and visit this list's data.
 
;; A [ListVisitor X Y] implements
;; - visit-mt : -> Y
;;   Visit an empty list.
;; - visit-cons : X [Listof X] -> Y
;;   Visit a cons lists.

;; A (new length%) implements [ListVisitor X Natural].
;; List visitor for computing the length of a list.
(define-class length%
  (define (visit-mt) 0)
  (define (visit-cons x r)
    (add1 (r . accept this))))
 
(define len (new length%))
 
(check-expect (q:empty . accept len) 0)
(check-expect (s:empty . accept len) 0)
(check-expect (q:empty . cons 'c . cons 'b . cons 'a . accept len) 3)
(check-expect (s:empty . cons 'c . cons 'b . cons 'a . accept len) 3)

;; A (new sum%) implements [ListVisitor Number Number].
;; List visitor for computing the sum of a list of numbers.
(define-class sum%
  (define (visit-mt) 0)
  (define (visit-cons n r)
    (+ n (r . accept this))))
 
(define sum (new sum%))
 
(check-expect (q:empty . accept sum) 0)
(check-expect (s:empty . accept sum) 0)
(check-expect (q:empty . cons 3 . cons 4 . cons 7 . accept sum) 14)
(check-expect (s:empty . cons 3 . cons 4 . cons 7 . accept sum) 14)



;; A (new reverse%) implements [ListVisitor X X].
;; List visitor for reversing a list.
(define-class reverse%
  (define (visit-mt) s:empty)
  (define (visit-cons x r)
    (r . accept (new reverse-helper% (s:empty . cons x)))))

;; A (new reverse-helper acc%) implements [ListVisitor X X].
;; A helper List visitor for reversing a list.
(define-class reverse-helper%
  (fields acc)
  
  (define (visit-mt) (this . acc))
  (define (visit-cons x r)
    (r . accept (new reverse-helper% (this . acc . cons x)))))

(define rev (new reverse%))

(check-expect (q:empty . accept rev) s:empty)
(check-expect (q:empty . cons 'c . cons 'b . cons 'a . accept rev)
              (s:empty . cons 'a . cons 'b . cons 'c))


;; A [Fun X Y] implements
;; - apply : X -> Y
;;   Apply this function to given x.


;; A meathod for converting Numbers to Strings
(define-class num->string%
  
  (define (apply x)
    (number->string x)))


;; A [Question X] implements
;; - ask : X -> Boolean
;;   Ask if this predicate holds on x.

(define-class shortstringp%
  
  (define (ask x)
    (< (string-length x) 5)))

;; A (new filter% [Question X]) implements [ListVisitor X [List X]].
;; Filters visited list to produce a list of elements satisfying predicate.

(define-class filter%
  (fields question)
  (define (visit-mt) s:empty)
  (define (visit-cons x r)
      (if (this . question . ask x)
          ((r . accept this) . cons x)
          (r . accept this)))
  
  (define (fold-mt)
    s:empty)
  (define (fold-cons x rest)
    (if (this . question . ask x)
        (rest . cons x)
        rest)))

(define ss-filter (new filter% (new shortstringp%)))

(check-expect (q:empty . cons "Hello World" . cons "Hi" . cons "LOL" . accept ss-filter)
              (s:empty . cons "Hi" . cons "LOL"))
 
;; A (new map% [Fun X Y]) implements [ListVisitor X [List Y]].
;; Maps visited list to produce a list of results of applying the function.
(define-class map%
  (fields fun)
  
  (define (visit-mt) s:empty)
  (define (visit-cons x r)
    ((r . accept this) . cons (this . fun . apply x)))
  
  (define (fold-mt) s:empty)
  (define (fold-cons x rest)
    (rest . cons this . fun . apply x)))

(define numstring (new map% (new num->string%)))

(check-expect (q:empty . cons 5 . cons 3 . cons 1 . accept numstring)
              (s:empty . cons "5" . cons "3" . cons "1"))


;; A [ListFold X Y] implements
;; - fold-mt : -> Y
;;   Process an empty list.
;; - fold-cons : X Y -> Y
;;   Process a cons lists.

;; computes the product of a [List Number]
(define-class prod-fold%
  (define (fold-mt) 1)
  (define (fold-cons n prod)
    (* n prod)))

(check-expect (q:empty . cons 5 . cons 3 . cons 1 . fold (new prod-fold%)) 15)

;; Appends a [List String] together.
(define-class sa-fold%
  (define (fold-mt) "")
  (define (fold-cons s string)
    (string-append s string)))

(check-expect (s:empty . cons "a" . cons "b" . cons "c" . fold (new sa-fold%))
              "cba")

;; A (new list-ref% Number) finds the ith element of a list
;; INVARIANT: must be a visitor or fold on a non-empty list.
(define-class list-ref%
  (fields pos)
  
  ;; We didn't know what to write for the empty class.
  ;; List-ref can only be called on lists on n or greater,
  ;; with n being the nth element in the list.
  #;(define (fold-mt)
    ...)
  
  (define (fold-cons x y)
    (if (= 0 (this . pos))
        x
        (y . fold (new list-ref% (sub1 (this . pos)))))))
  
#;(check-expect (s:empty . cons 'a . cons 'b . cons 'c . fold (new list-ref% 2))
              'b)

