;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname sept17-2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#| --------------------------------------------------------
Problem: Design an airline customer system. The system
represents each customer via a title, first name, and last
name. Airlines use the following titles: Dr. Mr., Ms.

The system should also support a function for writing formal
letter openers adn function for measuring the number of
characters in a customer record.

Problem 1: Create a data definition for customer records.
----------------------------------------------------------|#

(define-struct customer (title first last))

#|
Data Description:
Customer = (make-customer Title String String)
A Title is one of:
-- 'Dr.
-- 'Mr.
-- 'Ms.

Problem 2: Design a function that produces a letter formal
opening from a customer record.  Remember that a formal letter
opening is something such as "Dear Dr. Scheme:".

Contract & Purpose:
letter opening: customer -> String
Purpose: Given a customer record, produces a formal letter opening

Examples:
(make-customer 'Dr. "Olin" "Shivers") --> "Dear. Dr. Shivers:"
...

Template:
(define (customer-template a-customer)
    (... (customer-title a-customer) ...
         (customer-first a-customer) ...
         (customer-last  a-customer) ...))
|#

(define (letter-opening a-cust)
    (string-append "Dear " 
                   (symbol->string (customer-title a-cust)) 
                   " "
                   (customer-last  a-cust)
                   ":"))

(check-expect (letter-opening (make-customer 'Dr. "Olin" "Shivers")) "Dear Dr. Shivers:")

#|
Problem 3: Design a function that counts the characters in a customer record.

count-char : Customer -> Number
Purpose : Counts the non-whitespace characters in a customer record.

Examples:
(make-customer 'Dr. "Olin" "Shivers") --> 14
(make-customer 'Ms. "Olin" "Shivers") --> 12

Template:
(define (customer-template a-customer)
    (... (customer-title a-customer) ...
         (customer-first a-customer) ...
         (customer-last  a-customer) ...))
|#
(define (count-char a-customer)
    (+ (string-length (customer-title a-customer))
       (string-length (customer-first a-customer))
       (string-length (customer-last  a-customer))))
