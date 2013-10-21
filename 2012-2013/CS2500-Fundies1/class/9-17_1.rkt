;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname sept17) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#| ---------------------------------------------------------------------
    Problem: design a simple simulaiton of a traffic light.  
    The simulation should initially display a big red circle.
    After three seconds, it should display a big green circle,
    and after another three seconds, it should switch to a yellow circle.
    Then it starts all over.

    Problem 1: A data representation of the current state of the traffic light.

    Problem 2: Design the function SWITCH, 
    which consumes the current state of the traffic light and produces the next one.

    Problem 3: design the function DISPLAY,
    which consumes the current state of the traffic light and produces an image of it.
|#

#|
A TLS is one of:
 -- 'red
 -- 'yellow
 -- 'green
Interpretation: symbol indicated color of light.
|#

;; switch : TLS -> TLS
;; Purpose: Consumes the current state of the traffic light and produces the next one.

#| examples:
'red -> 'green
'green -> 'yellow
'yellow -> red

Template:

(define (a-TLS-template a-TLS)
  (cond [(symbol=? a-TLS 'red)    ...]
        [(symbol=? a-TLS 'yellow) ...]
        [(symbol=? a-TLS 'green)  ...]))

|#

(define (switch a-TLS)
  (cond [(symbol=? a-TLS 'red)    'green]
        [(symbol=? a-TLS 'yellow) 'red]
        [(symbol=? a-TLS 'green)  'yellow]))

(check-expect (switch 'red) 'green)
(check-expect (switch 'green) 'yellow)
(check-expect (switch 'yellow) 'red)
