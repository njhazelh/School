;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname 11-26_1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
Nov. 26, 2012
In class notes

Writing a language: Husky
|#

#|
Want:
<var>
<number>
<boolean>
(CONST <constant-expression>)
(if <test> <then> <else>)
(fun <args> <body>)
(<fun> <arg> <arg> ...)

A Var is a Symbol

A HExp is one of:
-- Var
-- Number
-- Boolean
-- (list 'const HExp)
-- (list 'if HExp HExp)
-- (list 'fun HExp [Listof Var] HExp)
-- (HExp HExp ...)
|#