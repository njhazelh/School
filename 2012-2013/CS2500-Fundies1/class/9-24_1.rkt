;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname sept24-1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
9/24/2012
Class Notes and work
Problem 1: Structures
|#

#|
Problem 1: We have interns, who work at an hourly rate, and
full-time employees, who are salaried. We need to keep track
of these employee, and print out their paychecks once a
month: "Pay to the order of Olin Shivers, $15000."
|#

;; Step 1: Data Defintion
(define-struct name (first last))
;; A Name is a (make-name String String) where
;; first : the first name of a person
;; last  : the last name of a person

(define-struct intern (name wage hours/week))
;; An Intern is a (make-intern Name Number Number) where
;; name       : The name of the intern
;; wage       : The hourly wage of the intern
;; hours/week : The number of hours worked per week

(define-struct fulltimer (name salary))
;; A FullTimeWorker is a (make-fulltimer Name Number) where
;; name   : The name of the employee
;; salary : The monthly salary of the employee

#|
An Employee is one of:
   -- Intern
   -- Fulltimer

(define (employee-template employee)
    (cond [(intern? employee)    ... (intern-name       employee) ...
                                 ... (intern-wage       employee) ...
                                 ... (intern-hours/week employee) ...]
          [(fulltimer? employee) ... (fulltimer-name    employee) ...
                                 ... (fulltimer-salary  employee) ...]))
|#

(define i1 (make-intern (make-name "Olin"
                                   "Shivers")
                        10
                        40))
(define f1 (make-fulltimer (make-name "Trevyn"
                                      "Langsford")
                           14000))

;; Step 2: Contract and Purpose
;; print-paycheck : Employee -> String
;; Purpose: Given an employee, produces a monthly paycheck as follows: 
;;          "Pay to the order of Olin Shivers, $1000."

;; Step 3: Examples
;; i1 -> "Pay to the order of Olin Shivers, $1600."
;; f1 -> "Pay to the order of Trevyn Langsford, $14000."

;; Step 4: Template: See employee-template

;; Step 5: Write function
(define (print-paycheck emp)
  (cond [(intern? emp) (string-append "Pay to the order of "
                                      (name-first (intern-name emp))
                                      " "
                                      (name-last  (intern-name emp))
                                      ", $"
                                      (number->string (* (intern-wage emp)
                                                         (intern-hours/week emp)
                                                         4))
                                      ".")]
        [else          (string-append "Pay to the order of "
                                      (name-first (fulltimer-name emp))
                                      " "
                                      (name-last  (fulltimer-name emp))
                                      ", $"
                                      (number->string (fulltimer-salary emp))
                                      ".")]))

;; Step 6: Tests
(check-expect (print-paycheck i1) "Pay to the order of Olin Shivers, $1600.")
(check-expect (print-paycheck f1) "Pay to the order of Trevyn Langsford, $14000.")

;; Better way
;; fullname : Employee -> String
;; Purpose  : Takes an employee, produces name "FIRST LAST"
;; Examples:
;;     i1 -> "Olin Shivers"
;;     f1 -> "Trevyn Langsford"
(define (fullname emp)
  (cond [(intern? emp) (string-append (name-first (intern-name emp))
                                      " "
                                      (name-last (intern-name emp)))]
        [else          (string-append (name-first (fulltimer-name emp))
                                      " "
                                      (name-last (fulltimer-name emp)))]))

;; Tests:
(check-expect (fullname i1) "Olin Shivers")
(check-expect (fullname f1) "Trevyn Langsford")

;; monthly-pay : Employee -> Number
;; Purpose: Take an employee and returns what they should be paid
;;          for the month.
;; Examples:
;; i1 ->  1600
;; f1 -> 14000
(define (monthly-pay emp)
  (cond [(intern? emp) (* (intern-wage       emp)
                          (intern-hours/week emp)
                          4)]
        [else          (fulltimer-salary emp)]))
;; Tests:
(check-expect (monthly-pay i1)  1600)
(check-expect (monthly-pay f1) 14000)

(define (print-paycheck-better emp)
  (string-append "Pay to the order of "
                 (fullname emp)
                 ", $"
                 (number->string (monthly-pay emp))
                 "."))
;; Tests:
(check-expect (print-paycheck-better i1) "Pay to the order of Olin Shivers, $1600.")
(check-expect (print-paycheck-better f1) "Pay to the order of Trevyn Langsford, $14000.")





















