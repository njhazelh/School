#lang class/0
(require 2htdp/image)
(require class/universe)

;;> <128/130>
;;> Graded by Nicholas Labich (labichn@ccs.neu.edu)

;;;;;;;;;;;;;;;;;;;;
;; ASSIGNMENT 1 ;;;;
;; Tiffany Chao ;;;;
;; Nicholas Jones ;;
;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Exercise 1  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
    ...(circ-R c)
    ...(circ-C c)
    ...(circ-X c)
    ...(circ-Y c))

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

(check-expect (draw-on c1 (empty-scene 200 200)) 
              (place-image (to-image c1) 100 70 (empty-scene 200 200)))

;; to-image : Circ -> Image
;; turns a circle into an image
(define (to-image c)
  (circle (circ-R c) "solid" (circ-C c)))

(check-expect (to-image c1) (circle 25 "solid" "red"))

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



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Exercise 2  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; A Circle is a (new circle% Number Color Number Number)
;; How doth one scribe a template of a class. I know'th not.
;;> Same way as above, describe the interpretation of the fields as if
;;> they were aspects of a structure. <-2>
(define-class circle%
  (fields radius color x y)
  
  ;; =? : Circle -> Boolean
  ;; Do the circles have the same center and radius?
  (define (=? c)
    (and (= (field radius)
            (send c radius))
         (= (field x)
            (send c x))
         (= (field y)
            (send c y))))
  ;; Tests/Examples:
  (check-expect (send c-class1 =? c-class2) false)
  (check-expect (send c-class1 =? c-class3) true)
  
  
  ;; area : -> Number
  ;; Calculate the area of the circle
  (define (area)
    (* 2 pi (field radius)))
  ;; Tests/Examples:
  (check-range (send c-class1 area)
               (- (* 2 pi 10).00001)
               (+ (* 2 pi 10).00001))
  (check-range (send c-class2 area)
               (- (* 2 pi 20).00001)
               (+ (* 2 pi 20).00001))
  
  
  
  ;; move-to : Number Number -> Circle
  ;; Move the (x,y) coordinates
  (define (move-to x y)
    (new circle%
         (field radius)
         (field color)
         x
         y))
  ;; Tests/Examples:
  (check-expect (send c-class1 move-to 50 20)
                (new circle% 10 'red 50 20))
  (check-expect (send c-class2 move-to 5 56)
                (new circle% 20 'green 5 56))
  (check-expect (send c-class3 move-to 1 9)
                (new circle% 10 'red 1 9))
  
  
  
  ;; move-by : Number Number -> Circle
  ;; Shift the Circle by the given X Y
  (define (move-by x y)
    (new circle%
         (field radius)
         (field color)
         (+ (field x)
            x)
         (+ (field y)
            y)))
  ;; Texts/Examples:
  (check-expect (send c-class1 move-by 10 20)
                (send c-class1 move-to 10 20))
  (check-expect (send c-class2 move-by 10 20)
                (send c-class2 move-to 20 35))
  
  
  
  ;; stretch : Number -> Circle
  ;; Scale the circle by the factor
  (define (stretch f)
    (new circle%
         (* f (field radius))
         (field color)
         (field x)
         (field y)))
  ;; Tests/Examples:
  (check-expect (send c-class1 stretch 1/2)
                (new circle% 5 'red 0 0))
  (check-expect (send c-class2 stretch 4)
                (new circle% 80 'green 10 15))
  
  
  
  ;; to-image : -> Image
  ;; Convert Circle to image
  (define (to-image)
    (circle (field radius)
            'solid
            (field color)))
  ;; Tests/Examples:
  (check-expect (send c-class1 to-image)
                (circle 10
                        'solid
                        'red))
  (check-expect (send c-class2 to-image)
                (circle 20
                        'solid
                        'green))
  
  
  
  ;; draw-on : Scene -> Scene
  ;; Draw the circle on the scene
  (define (draw-on s)
    (place-image (send this to-image)
                 (field x)
                 (field y)
                 s))
  ;; Tests/Examples:
  (check-expect (send c-class1 draw-on (empty-scene 200 200))
                (place-image (circle 10
                                     'solid
                                     'red)
                             0
                             0
                             (empty-scene 200 200)))
  (check-expect (send c-class2 draw-on (empty-scene 200 200))
                (place-image (circle 20
                                     'solid
                                     'green)
                             10
                             15
                             (empty-scene 200 200)))
  
  
  
  ;; within? : Posn -> Boolean
  ;; Is the posn within the circle?
  (define (within? posn)
    (<= (sqrt (+ (sqr (- (field x)
                         (posn-x posn)))
                 (sqr (- (field y)
                         (posn-x posn)))))
        (field radius)))
  ;; Tests/Examples:
  (check-expect (send c-class1 within? (make-posn 100 0))
                false)
  (check-expect (send c-class1 within? (make-posn 5 5))
                true)
  
  
  
  ;; overlap? : Circle: Boolean
  ;; Does the circle overlap?
  (define (overlap? c)
    (< (sqrt (+ (sqr (- (field x)
                        (send c x)))
                (sqr (- (field y)
                        (send c y)))))
       (+ (field radius)
          (send c radius))))
  ;; Tests/Examples:
  (check-expect (send c-class1 overlap? c-class2)
                true)
  (check-expect (send c-class1
                      overlap?
                      (new circle%
                           3
                           'yellow
                           100
                           100))
                false)
  
  
  ;; change-color : Color -> Circle
  ;; Change the color of the circle
  (define (change-color color)
    (new circle%
         (field radius)
         color
         (field x)
         (field y)))
  ;; Tests/Examples:
  (check-expect (send c-class1 change-color 'yellow)
                (new circle%
                     10
                     'yellow
                     0
                     0))
  (check-expect (send c-class2 change-color 'pink)
                (new circle%
                     20
                     'pink
                     10
                     15)))

;;; Examples:
(define c-class1 (new circle% 10 'red 0 0))
(define c-class2 (new circle% 20 'green 10 15))
(define c-class3 (new circle% 10 'red 0 0))
