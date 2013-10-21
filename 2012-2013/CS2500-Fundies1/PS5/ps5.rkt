;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname ps5) (read-case-sensitive #t) (teachpacks ((lib "convert.ss" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "convert.ss" "teachpack" "htdp")))))
#|
Nicholas Jones
Zach Wassall

Problem Set 5h
Due: 10/10/2012
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Problem A1 ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct weather (zip humidity high low))
;; A Weather is a (make-weather String Number Number Number)
;; Intepretation: 
;;  The weather's zip is the 5-digit zip code where the data was collected.
;;  The weather's humidity is a percentage.
;;  The weather's high and low represent the day's high and low
;;    temperatures in Fahrenheit.
;; Template:
#; (define (wr-temp wr)
     ... (weather-zip      wr) ...
     ... (weather-humidity wr) ...
     ... (weather-high     wr) ...
     ... (weather-low      wr) ...)
;; Examples:
(define wr1 (make-weather "19348"  50 90 85))
(define wr2 (make-weather "00000"  10 32 15))
(define wr3 (make-weather "00000" 100 78 70))






;;;;;;;;;;;;;;;;;;;;;
;;;;;; Part 1 ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;

;; A LoWR is one of:
;;    - empty
;;    - (cons Weather LoWR)
;; Template:
#;(define (lowr-temp list)
    (cond [(empty? list) ...]
          [else ... (weather-zip      (first list)) ...
                ... (weather-humidity (first list)) ...
                ... (weather-high     (first list)) ...
                ... (weather-low      (first list)) ...]))
;; Examples:
(define lowr1 empty)
(define lowr2 (cons wr1 empty))
(define lowr3 (cons wr1 (cons wr2 empty)))
(define lowr4 (cons wr1 (cons wr2 (cons wr3 empty))))






;;;;;;;;;;;;;;;;;;;;;
;;;;;; Part 2 ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;

;; HELPER FUNCTION
;; muggy?  : Weather Number Number -> Boolean
;; Purpose : Are the humidity and high temp >=
;;           humidity-theshold and temp-threshold
;;           respectively?
;; Examples:
;;    wr1 100 100 -> false
;;    wr1  60  10 -> false
;;    wr1  10  10 -> true
(define (muggy? weather humid-threshold temp-threshold)
  (and (>= (weather-humidity weather)
           humid-threshold)
       (>= (weather-high weather)
           temp-threshold)))
;; Tests:
(check-expect (muggy? wr1 100 100) false)
(check-expect (muggy? wr1  60  10) false)
(check-expect (muggy? wr1  10  10) true)



;; muggy   : LoWR Number Number -> LoWR
;; Purpose : Consumes a list of Weathers and
;;           returns a sublist of Weathers from it where humidity is
;;           >= humid-threshold (expressed as a percent)
;;           and high-temp is >= temp-threshold (degrees farenheit).
;; Examples:
;;    lowr1 100 100 -> empty
;;    lowr2  50  10 -> empty
;;    lowr2  10  10 -> lowr2
;;    lowr4  50  70 -> (list wr1 wr3)
(define (muggy lowr humid-threshold temp-threshold)
  (cond [(empty? lowr) empty]
        [(muggy? (first lowr) humid-threshold temp-threshold)
         (cons (first lowr) (muggy (rest lowr)
                                   humid-threshold
                                   temp-threshold))]
        [else (muggy (rest lowr)
                     humid-threshold
                     temp-threshold)]))
;; Tests:
(check-expect (muggy lowr1 100 100) empty)
(check-expect (muggy lowr2  60  10) empty)
(check-expect (muggy lowr2  10  10) lowr2)
(check-expect (muggy lowr4  50  70) (list wr1 wr3))





;;;;;;;;;;;;;;;;;;;;;
;;;;;; Part 3 ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;

;; HELPER FUNCTION
;; adjust-temp  : Weather Number -> Weather
;; Purpose      : Takes a Weather and returns the weather
;;                with high and low increased by the adjustment.
;; Examples:
;;    wr1 10 -> (make-weather 19348  50 100 95)
;;    wr2 20 -> (make-weather 00000  10  52 35)
(define (adjust-temp weather adjustment)
  (make-weather (weather-zip weather)
                (weather-humidity weather)
                (+ (weather-high weather)
                   adjustment)
                (+ (weather-low weather)
                   adjustment)))
;; Tests:
(check-expect (adjust-temp wr1 10) (make-weather "19348"  50 100 95))
(check-expect (adjust-temp wr2 20) (make-weather "00000"  10  52 35))



;; adjust-temps : LoWR String Number -> LoWR
;; Purpose      : Takes a list of weather records called lowr,
;;                a string called zip representing the zip code,
;;                and a number called adjustment, and produces a
;;                list of weather records that contains all the records
;;                in lowr but with the high and low temperatures in any
;;                record with zip code zip replaced by high + adjustment
;;                and low + adjustment.
;; Examples:
;;    lowr1 00000 4 -> empty
;;    lowr2 19348 5 -> (list (make-weather 19348 50 95 90))
;;    lowr3 00000 3 -> (list wr1 (make-weather 00000 10 37 20))
(define (adjust-temps lowr zip adjustment)
  (cond [(empty? lowr) empty]
        [(string=? zip (weather-zip (first lowr)))
         (cons (adjust-temp (first lowr)
                            adjustment)
               (adjust-temps (rest lowr)
                             zip
                             adjustment))]
        [else (cons (first lowr)
                    (adjust-temps (rest lowr)
                                  zip
                                  adjustment))]))
;; Tests:
(check-expect (adjust-temps lowr1 "00000" 4)
              empty)
(check-expect (adjust-temps lowr2 "19348" 5)
              (list (make-weather "19348" 50 95 90)))
(check-expect (adjust-temps lowr3 "00000" 3)
              (list wr1 (make-weather "00000" 10 35 18)))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; Problem A2 ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A LoN is one of:
;;    - empty
;;    - (cons Number LoN)

;; Template
#;(define (lon-temp lon)
    (cond [(empty? lon) ...]
          [else ... (lon-temp (rest lon) ...)]))

;; A Evens-Interval is one of:
;;    - 'invalid-interval
;;    - 'none
;;    - LoN

;; Template:
#; (define (ei-temp ei)
     (cond [(cons? ei) ...]
           [(symbol=? 'invalid-interval ei)
            ...]
           [else ...]))

;; HELPER FUNCTION
;; find-evens-in-int : Number Number -> LoN
;; Purpose           : Starts with a number and adds every even number
;;                     until it is >= the end number.
;; Examples:
;;    1  7 -> (list 2 4 6)
;;    1  1 -> empty
;;    2 10 -> (list 2 4 6 8)
(define (list-evens-in-interval start end)
  (cond [(>= start end) empty]
        [(= (modulo start 2)
            1)
         (list-evens-in-interval (add1 start)
                                 end)]
        [else
         (cons start
               (list-evens-in-interval (+ start 2)
                                       end))]))
;; Tests:
(check-expect (list-evens-in-interval 1 7) (list 2 4 6))
(check-expect (list-evens-in-interval 1 1) empty)
(check-expect (list-evens-in-interval 2 10) (list 2 4 6 8))


;; HELPER FUNCTION
;; even-in-interval? : Number Number -> Boolean
;; Purpose            : returns true if there are evens in
;;                       the half open interval given.
;; Examples:
;;    1 3 -> true
;;    1 2 -> false
(define (even-in-interval? start end)
  (or (= (modulo start 2) 0)
      (> (- end start) 1)))
;; Tests:
(check-expect (even-in-interval? 1 3) true)
(check-expect (even-in-interval? 1 2) false)



;; evens-in-interval : Number Number -> Evens-Interval
;; Purpose           : Takes a half open interval. If start is
;;                     >= end, then returns 'invalid-interval. If
;;                     no evens in interval, returns 'none. Else,
;;                     returns a list of the evens in the interval.
;; Examples:
;;    (evens-in-interval 0  1) -> 'invalid-interval
;;    (evens-in-interval 1  2) -> 'none
;;    (evens-in-interval 2 10) -> (list 2 4 6 8)
(define (evens-in-interval start end)
  (cond [(>= start end) 'invalid-interval]
        [(not (even-in-interval? start end)) 'none]
        [else (list-evens-in-interval start end)]))
;; Tests:
(check-expect (evens-in-interval 1  0) 'invalid-interval)
(check-expect (evens-in-interval 1  2) 'none)
(check-expect (evens-in-interval 2 10) (list 2 4 6 8))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Calc ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;==================================================================;;
;;                        Data Definitions                          ;;
;;==================================================================;;

#|
An Operation is one of:
   - '+
   - '-
   - '*
   - '/
|#
#; (define (op-temp op)
     (cond [(symbol=? op '-) ...]
           [(symbol=? op '+) ...]
           [(symbol=? op '*) ...]
           [(symbol=? op '/) ...]))

;; A Variable is a String

#|
A Arithmetic-Expression is one of:
    - Number
    - Variable
    - (make-expression Arithmetic-Expression Operation Arithmetic-Expression)
|#

(define-struct arith-expr (first operator last))

;; Template:
#; (define (ae-temp ae)
     (cond [(number? ae) ...]
           [(String? ae) ...]
           [(arith-expr? ae) ... (ae-temp-first    ae) ...
                             ... (ae-temp-operator ae) ...
                             ... (ae-temp-last     ae) ...]))
           

;; Data Examples:
(define ex1 (make-arith-expr 3 '+ 4))                        ;; 3+ 4 = 7
(define ex2 (make-arith-expr (make-arith-expr 3 '* 4) '+ 4)) ;; 3*4+4 = 16
(define ex3 (make-arith-expr                                 ;; -4/4 - 3*4 = -13
             (make-arith-expr (make-arith-expr 0 '- 4)
                              '/
                              4) 
             '- 
             (make-arith-expr 3
                              '*
                              4)))


;;==================================================================;;
;;                         Start Functions                          ;;
;;==================================================================;;


;; eval-arith : Arithmetic-Expression -> Number
;; Purpose    : Evaluates the given Arithmetic-Expression.
;; Examples:
;;    ex1 ->   7
;;    ex2 ->  16
;;    ex3 -> -13
(define (eval-arith expr)
  (cond [(number? expr) expr] ;; Base number
        [(symbol=? (arith-expr-operator expr) '+) ;; Performs Addition
         (+ (eval-arith (arith-expr-first expr))
            (eval-arith (arith-expr-last  expr)))]
        [(symbol=? (arith-expr-operator expr) '-) ;; Performs Subtraction
         (- (eval-arith (arith-expr-first expr))
            (eval-arith (arith-expr-last  expr)))]
        [(symbol=? (arith-expr-operator expr) '*) ;; Performs Multiplication
         (* (eval-arith (arith-expr-first expr))
            (eval-arith (arith-expr-last  expr)))]
        [(symbol=? (arith-expr-operator expr) '/) ;; Performs Division
         (/ (eval-arith (arith-expr-first expr))
            (eval-arith (arith-expr-last  expr)))]))



;; Tests
(check-expect (eval-arith ex1) 7)
(check-expect (eval-arith ex2) 16)
(check-expect (eval-arith ex3) -13)





#|
plug-in : Arithmetic-Expression Number -> Number
Purpose : Plugs in the given value for all.
Examples:
    "x" "x" 4 -> 4
    (make-arith-expr "x" '+ 3) "x" 4 -> (make-arith-expr 4 '+ 3)

    (make-arith-expr (make-arith-expr (make-arith-expr 0 '- "y") '/"x") 
                     '- 
                     (make-arith-expr 3 '* "y"))
    "y"
     2 -> (make-arith-expr (make-arith-expr (make-arith-expr 0 '- 2) '/ "x") 
                           '- 
                           (make-arith-expr 3 '* 2)
|#
(define (plug-in expr var plug)
  (cond [(number? expr) expr] ;; Base number
        [(and (string? expr)
              (string=? var expr))
         plug]                ;; Replace variable
        [(string? expr) expr] ;; Leave variable
        [else (make-arith-expr (plug-in (arith-expr-first expr) var plug)
                               (arith-expr-operator expr)
                               (plug-in (arith-expr-last expr) var plug))]))


;; Tests
(check-expect (plug-in "x" "x" 4) 4)  ;; X=4 : X -> 4

(check-expect (plug-in (make-arith-expr "x" '+ 3) "x" 4) ;; X=4 : X+3 -> 4+3
              (make-arith-expr  4  '+ 3))

(check-expect (plug-in (make-arith-expr (make-arith-expr (make-arith-expr 0 '- "y") '/ "x") ;; Y=3 : -Y/X - 3*Y -> -2/X - 3*2
                        '- 
                        (make-arith-expr 3 '* "y"))
                       "y"
                       2)
              (make-arith-expr (make-arith-expr (make-arith-expr 0 '- 2) '/ "x") 
               '- 
               (make-arith-expr 3 '* 2)))








#|
;#######################################################
;#                  POCKET CALCULATOR                  #
;#######################################################


; DATA DEFINITIONS
;-----------------------------------------------

#| WITHOUT VARIABES --------------------
;; An Expression is one of:
;;   - Number
;;   - (make-neg Expression)
;;   - (make-add Expression Expression)
;;   - (make-sub Expression Expression)
;;   - (make-mul Expression Expression)
;;   - (make-div Expression Expression)
;;
;; TEMPLATE
#|
(define (exp-temp a-exp)
  ... (eval-arith a-exp) ... )
|#
|#;-------------------------------------



;| WITH VARIABLES ----------------------
;; An Expression is one of:
;;   - Number
;;   - String   (this is a variable name)
;;   - (make-neg Expression)
;;   - (make-add Expression Expression)
;;   - (make-sub Expression Expression)
;;   - (make-mul Expression Expression)
;;   - (make-div Expression Expression)
;;
;; TEMPLATE
#|
(define (exp-temp a-exp)
  ... (eval-arith a-exp) ... )
|#
;#;-------------------------------------



(define-struct neg (exp))
;; A Negation is a (make-neg Expression) with:
;;   exp : The expression to be negated
;;
;; TEMPLATE
#|
(define (neg-temp a-neg)
  ... (neg-exp    a-neg) ...
  ... (eval-arith a-neg) ...
  ... (eval-arith (neg-exp a-neg) ... )
|#

;; Examples:
(define neg-1 (make-neg 1))



(define-struct add (exp1 exp2))
;; An Addition is a (make-add Expression Expression) with:
;;   exp1 : One addend
;;   exp2 : The other addend
;;
;; TEMPLATE
#|
(define (add-temp a-add)
  ... (add-exp1   a-add) ...
  ... (add-exp2   a-add) ...
  ... (eval-arith a-add) ... 
  ... (eval-arith (add-exp1 a-add) ... 
  ... (eval-arith (add-exp2 a-add) ... )
|#

;; Examples:
(define add-1-2 (make-add 1 2))
(define add-1-2-3-4 (make-add (make-add 1 2)
                              (make-add 3 4)))



(define-struct sub (exp1 exp2))
;; A Subtraction is a (make-sub Expression Expression) with:
;;   exp1 : The minuend
;;   exp2 : The subtrahend
;;
;; TEMPLATE
#|
(define (sub-temp a-sub)
  ... (sub-exp1   a-sub) ...
  ... (sub-exp2   a-sub) ...
  ... (eval-arith a-sub) ... 
  ... (eval-arith (sub-exp1 a-sub) ... 
  ... (eval-arith (sub-exp2 a-sub) ... )
|#

;; Examples:
(define sub-1-2 (make-sub 1 2))
(define sub-1-2-3-4 (make-sub (make-sub 1 2)
                              (make-sub 3 4)))



(define-struct mul (exp1 exp2))
;; A Multiplication is a (make-mul Expression Expression) with:
;;   exp1 : One multiplicand
;;   exp2 : The other multiplicand
;;
;; TEMPLATE
#|
(define (mul-temp a-mul)
  ... (mul-exp1   a-mul) ...
  ... (mul-exp2   a-mul) ...
  ... (eval-arith a-mul) ... 
  ... (eval-arith (mul-exp1 a-mul) ... 
  ... (eval-arith (mul-exp2 a-mul) ... )
|#

;; Examples:
(define mul-1-2 (make-mul 1 2))
(define mul-1-2-3-4 (make-mul (make-mul 1 2)
                              (make-mul 3 4)))



(define-struct div (exp1 exp2))
;; A Division is a (make-div Expression Expression) with:
;;   exp1 : The dividend
;;   exp2 : The divisor
;;
;; TEMPLATE
#|
(define (div-temp a-div)
  ... (div-exp1   a-div) ...
  ... (div-exp2   a-div) ...
  ... (eval-arith a-div) ... 
  ... (eval-arith (div-exp1 a-div) ... 
  ... (eval-arith (div-exp2 a-div) ... )
|#

;; Examples:
(define div-1-2 (make-div 1 2))
(define div-1-2-3-4 (make-div (make-div 1 2)
                              (make-div 3 4)))



;; An example of an expression including all expression types (except variables)
(define exp-complex (make-add (make-add (make-add 1
                                                  neg-1)
                                        (make-add add-1-2-3-4
                                                  sub-1-2-3-4))
                              (make-add mul-1-2-3-4
                                        div-1-2-3-4)))

;; Examples of expressions including variables
(define mul-2-x-sqr (make-mul 2 (make-mul "x" "x")))
(define var-all-exp (make-neg (make-add "var"
                                        (make-sub "var"
                                                  (make-mul "var"
                                                            (make-div "var"
                                                                      1))))))
(define det (make-sub (make-mul "b" "b") (make-mul 4 (make-mul "a" "c"))))




; FUNCTIONS
;-----------------------------------------------

;; eval-arith : Expression -> Number
;; Purpose    : Computes the numerical result of the given expression
;; Examples:
;;    1           -> 1
;;    neg-1       -> -1
;;    add-1-2-3-4 -> 10
;;    sub-1-2-3-4 -> 0
;;    mul-1-2-3-4 -> 24
;;    div-1-2-3-4 -> 2/3
;;    exp-complex -> 104/3
(define (eval-arith exp)
  (cond [(number? exp) exp]
        [(neg? exp) (- 0
                       (eval-arith (neg-exp exp)))]
        [(add? exp) (+ (eval-arith (add-exp1 exp))
                       (eval-arith (add-exp2 exp)))]
        [(sub? exp) (- (eval-arith (sub-exp1 exp))
                       (eval-arith (sub-exp2 exp)))]
        [(mul? exp) (* (eval-arith (mul-exp1 exp))
                       (eval-arith (mul-exp2 exp)))]
        [(div? exp) (/ (eval-arith (div-exp1 exp))
                       (eval-arith (div-exp2 exp)))]))

;; TESTS
(check-expect (eval-arith 1) 1)
(check-expect (eval-arith neg-1) -1)
(check-expect (eval-arith add-1-2-3-4) 10)
(check-expect (eval-arith sub-1-2-3-4) 0)
(check-expect (eval-arith mul-1-2-3-4) 24)
(check-expect (eval-arith div-1-2-3-4) 2/3)
(check-expect (eval-arith exp-complex) 104/3)



;; plug-in : Expression String Number -> Expression
;; Purpose : Replaces all strings (variables) in the given expression that match
;;           the given string with the given number
;; Examples:
;;    neg-1 "x" 5
;;        -> (make-neg 1)
;;    mul-2-x-sqr "x" 5
;;        -> (make-mul 2 (make-mul 5 5))
;;    var-all-exp "var" 2
;;        -> (make-neg (make-add 2 (make-sub 2 (make-mul 2 (make-div 2 1)))))
;;    (plug-in (plug-in det "a" 1) "b" 3) "c" 2
;;        -> (make-sub (make-mul 3 3) (make-mul 4 (make-mul 1 2)))
(define (plug-in exp var num)
  (cond [(number? exp) exp]
        [(string? exp) (if (string=? exp var) num exp)]
        [(neg? exp) (make-neg (plug-in (neg-exp exp) var num))]
        [(add? exp) (make-add (plug-in (add-exp1 exp) var num)
                              (plug-in (add-exp2 exp) var num))]
        [(sub? exp) (make-sub (plug-in (sub-exp1 exp) var num)
                              (plug-in (sub-exp2 exp) var num))]
        [(mul? exp) (make-mul (plug-in (mul-exp1 exp) var num)
                              (plug-in (mul-exp2 exp) var num))]
        [(div? exp) (make-div (plug-in (div-exp1 exp) var num)
                              (plug-in (div-exp2 exp) var num))]))

;; TESTS
(check-expect (plug-in neg-1 "x" 5)
              (make-neg 1))
(check-expect (plug-in mul-2-x-sqr "x" 5)
              (make-mul 2 (make-mul 5 5)))
(check-expect (plug-in var-all-exp "var" 2)
              (make-neg (make-add 2 (make-sub 2 (make-mul 2 (make-div 2 1))))))
(check-expect (plug-in (plug-in (plug-in det "a" 1) "b" 3) "c" 2)
              (make-sub (make-mul 3 3) (make-mul 4 (make-mul 1 2))))

|#