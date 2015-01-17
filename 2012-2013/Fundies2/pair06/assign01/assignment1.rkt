#lang class/0
(require 2htdp/image)
(require class/universe)

;;;;;;;;;;;;;;;;;;;;
;; ASSIGNMENT 1 ;;;;
;; Tiffany Chao ;;;;
;; Nicholas Jones ;;
;;;;;;;;;;;;;;;;;;;;

;; EXERCISE 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Definition

;; A Circ is a (make-circ Number String Number Number)
;; Where R is the radius
;; C is the color
;; X is the x-coordinate of the center of the circle
;; Y is the y-coordinate of the center of the circle
;; in graphic coordinates
(define-struct circ (R C X Y))

;; Template

#;(define (circ-temp c ...)
    (...(circ-R c)
     ...(circ-C c)
     ...(circ-X c)
     ...(circ-Y c)))

;; Contracts/Headers

;; =? : Circ Circ -> Boolean
;; determines if two circles are equal
;; ignores color
(define (=? circ1 circ2)
  (and (= (circ-R circ1)(circ-R circ2))
       (= (circ-X circ1)(circ-X circ2))
       (= (circ-Y circ1)(circ-Y circ2))))

(check-expect (=? c1 c1) true)
(check-expect (=? c1 (make-circ 25 "blue" 100 70)) true)
(check-expect (=? c1 c2) false)

;; area : Circ -> Number
;; determines area of a circle
(define (area c)
  (* pi (sqr (circ-R c))))

(check-expect (inexact->exact (area c1)) (inexact->exact (* pi 625)))
(check-expect (inexact->exact (area c2)) (inexact->exact (* pi 2500)))

;; move-to : Circ -> Circ
;; centers circle at new x and y coordinates
(define (move-to c x y)
  (make-circ (circ-R c) 
             (circ-C c)
             x
             y))

(check-expect (move-to c1 100 100) (make-circ 25 "red" 100 100))
(check-expect (move-to c2 50 150) (make-circ 50 "blue" 50 150))

;; move-by : Circ -> Circ
;; moves circle by change in x and y coordinates
(define (move-by c x y)
  (make-circ (circ-R c) 
             (circ-C c)
             (+ x (circ-X c))
             (+ y (circ-Y c))))

(check-expect (move-by c1 100 100) (make-circ 25 "red" 200 170))
(check-expect (move-by c2 -50 150) (make-circ 50 "blue" 40 180))

;; stretch : Circ Number -> Circ
;; scales a circle by given factor
(define (stretch c n)
  (make-circ (* n (circ-R c))
             (circ-C c)
             (circ-X c)
             (circ-Y c)))

(check-expect (stretch c1 2) (make-circ 50 "red" 100 70))
(check-expect (stretch c2 .1) (make-circ 5 "blue" 90 30))

;; draw-on : Circ Image -> Image
;; draws circle onto given image
(define (draw-on c i)
  (place-image (to-image c)
               (circ-X c)
               (circ-Y c)
               i))

(check-expect (draw-on c1 (empty-scene 200 200)) .)

;; to-image : Circ -> Image
;; Turns a circle into an image
(define (to-image c)
  (circle (circ-R c) "solid" (circ-C c)))

(check-expect (to-image c1) .)

;; within? : Circ Number Number -> Boolean
;; determines if a given position is located within the circle
;; or on the edge of the circle.
;; x is the position's x-coordinate
;; y is the position's y-coordinate
(define (within? c x y)
  (<= (sqrt (+ (sqr (- x (circ-X c)))
               (sqr (- y (circ-Y c)))))
      (circ-R c)))

(check-expect (within? c1 110 80) true)
(check-expect (within? c1 76 70) true)
(check-expect (within? c1 75 70) true) ; edge of circle
(check-expect (within? c1 74 70) false)
(check-expect (within? c2 200 200) false)

;; overlap : Circ Circ -> Boolean
;; determines if two circles overlap
(define (overlap? circ1 circ2)
  (<= (sqrt (+ (sqr (- (circ-X circ1) (circ-X circ2)))
               (sqr (- (circ-Y circ1) (circ-Y circ2)))))
      (+ (circ-R circ1) (circ-R circ2))))

(check-expect (overlap? c1 c2) true)
(check-expect (overlap? c2 c1) true)
(check-expect (overlap? c1 c3) false)

;; change-color : Circ String -> Circ
;; changes color of circle
(define (change-color c color)
  (make-circ (circ-R c)
             color
             (circ-X c)
             (circ-Y c)))

(check-expect (change-color c1 "purple") 
              (make-circ 25 "purple" 100 70))

;; Examples

(define c1 (make-circ 25 "red" 100 70))
(define c2 (make-circ 50 "blue" 90 30))
(define c3 (make-circ 10 "green" 50 80))

;; EXERCISE 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Definition

;; a Circ2 is a (new circ% Number String Number Number)
;; Where R is the radius
;; C is the color
;; X is the x-coordinate of the center of the circle
;; Y is the y-coordinate of the center of the circle
;; in graphic coordinates
(define-class circ%
  (fields R C X Y)
  
  ;; Template

  #;(define (circ-temp ...)
      ...(field R)
      ...(field C)
      ...(field X)
      ...(field Y))
  
  ;; Contracts/Headers
  
  ; =? : Circ2 -> Boolean
  ; determines if two circles are equal
  ; ignores color
  (define (=? circ2)
    (and (= (field R)(send circ2 R))
         (= (field X)(send circ2 X))
         (= (field Y)(send circ2 Y))))
  
  (check-expect (send c4 =? c4) true)
  (check-expect (send c4 =? (new circ% 25 "red" 100 70)) true)
  (check-expect (send c4 =? c5) false)
  
  ; area : -> Number
  ; determines area of a circle
  (define (area)
    (* pi (sqr (field R))))
  
  (check-expect (inexact->exact (send c4 area)) 
                (inexact->exact (* pi 625)))
  (check-expect (inexact->exact (send c5 area)) 
                (inexact->exact (* pi 2500)))
  
  ; move-to : -> Circ2
  ; centers circle at new x and y coordinates
  (define (move-to x y)
    (new circ% (field R)
         (field C)
         x
         y))
  
  (check-expect (send c4 move-to 100 100) (new circ% 25 "red" 100 100))
  (check-expect (send c5 move-to 50 150) (new circ% 50 "blue" 50 150))
  
  ; move-by : -> Circ2 
  ; moves circle by change in x and y coordinates
  (define (move-by x y)
    (new circ% (field R)
         (field C)
         (+ x (field X))
         (+ y (field Y))))
  
  (check-expect (send c4 move-by 100 100) (new circ% 25 "red" 200 170))
  (check-expect (send c5 move-by -50 150) (new circ% 50 "blue" 40 180))
  
  ; stretch : Number -> Circ2
  ; scales a circle by given factor
  (define (stretch n)
    (new circ% (* n (field R))
         (field C)
         (field X)
         (field Y)))
  
  (check-expect (send c4 stretch 2) (new circ% 50 "red" 100 70))
  (check-expect (send c5 stretch .1) (new circ% 5 "blue" 90 30))
  
  ; draw-on : Image -> Image
  ; draws circle onto given image
  (define (draw-on i)
    (place-image (circle (field R) "solid" (field C))
                 (field X)
                 (field Y)
                 i))
  
  (check-expect (send c4 draw-on (empty-scene 200 200)) .)
  
  ; to-image : -> Image
  ; turns a circle into an image
  (define (to-image)
    (circle (field R) "solid" (field C)))
  
  (check-expect (send c4 to-image) .)
  
  ; within? : Number Number -> Boolean
  ; determines if a given position is located within the circle
  ; or on the edge of the circle.
  ; x is the position's x-coordinate
  ; y is the position's y-coordinate
  (define (within? x y)
    (<= (sqrt (+ (sqr (- x (field X)))
                 (sqr (- y (field Y)))))
        (field R)))
  
  (check-expect (send c4 within? 110 80) true)
  (check-expect (send c4 within? 76 70) true)
  (check-expect (send c4 within? 75 70) true) ; edge of circle
  (check-expect (send c4 within? 74 70) false)
  (check-expect (send c5 within? 200 200) false)
  
  ; overlap : Circ2 -> Boolean
  ; determines if two circles overlap
  (define (overlap? circ2)
    (<= (sqrt (+ (sqr (- (field X) (send circ2 X)))
                 (sqr (- (field Y) (send circ2 Y)))))
        (+ (field R) (send circ2 R))))
  
  (check-expect (send c4 overlap? c5) true)
  (check-expect (send c5 overlap? c4) true)
  (check-expect (send c4 overlap? (new circ% 10 "green" 10 10)) false)
  
  ; change-color : String -> Circ2
  ; changes color of circle
  (define (change-color color)
    (new circ% (field R)
         color
         (field X)
         (field Y)))
  
  (check-expect (send c4 change-color "purple") 
                (new circ% 25 "purple" 100 70)))

;; Examples

(define c4 (new circ% 25 "red" 100 70))
(define c5 (new circ% 50 "blue" 90 30)) 
