#lang class/0


#|
Nicholas Jones
Tiffany  Chao

Problem Set 1
January 9th 2013

|#

(require 2htdp/image)
(require 2htdp/universe)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Exercise 1  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A Circle is a (make-circ Number Color Number Number)
(define-struct circ (radius color x y))

;; Template:
#; (define (circ-temp c)
     (circ-radius c) ...
     (circ-color  c) ...
     (circ-x      c) ...
     (circ-y      c) ...)

;; Examples
(define circ1 (make-circ 10 'red 0 0))
(define circ2 (make-circ 20 'green 10 15))
(define circ3 (make-circ 10 'red 0 0))


;; =? : Circle Circle -> Boolean
;; Do the circles have the same radius
;; and position?
(define (=? c1 c2)
  (and (= (circ-radius c1)
          (circ-radius c2))
       (= (circ-x c1)
          (circ-x c2))
       (= (circ-y c1)
          (circ-y c2))))
;; Tests/Examples:
(check-expect (=? circ1 circ2) false)
(check-expect (=? circ1 circ3) true)


;; area : Circle -> Number
;; Calculate the area of the circle
(define (area c)
  (* 2 pi (circ-radius c)))
;; Tests/Examples:
(check-range (area circ1)
             (- (* 2 pi 10).00001)
             (+ (* 2 pi 10).00001))
(check-range (area circ2)
             (- (* 2 pi 20).00001)
             (+ (* 2 pi 20).00001))



;; move-to : Circle Number Number -> Circle
;; Move the (x,y) coordinates
(define (move-to c x y)
  (make-circ (circ-radius c)
             (circ-color c)
             x
             y))
;; Tests/Examples:
(check-expect (move-to circ1 50 20)
              (make-circ 10 'red 50 20))
(check-expect (move-to circ2 5 56)
              (make-circ 20 'green 5 56))
(check-expect (move-to circ3 1 9)
              (make-circ 10 'red 1 9))



;; move-by : Circle Number Number -> Circle
;; Shift the Circle by the given X Y
(define (move-by c x y)
  (make-circ (circ-radius c)
             (circ-color c)
             (+ (circ-x c)
                x)
             (+ (circ-y c)
                y)))
;; Texts/Examples:
(check-expect (move-by circ1 10 20)
              (move-to circ1 10 20))
(check-expect (move-by circ2 10 20)
              (move-to circ2 20 35))



;; stretch : Circle Number -> Circle
;; Scale the circle by the factor
(define (stretch c f)
  (make-circ (* f (circ-radius c))
             (circ-color c)
             (circ-x c)
             (circ-y c)))
;; Tests/Examples:
(check-expect (stretch circ1 1/2)
              (make-circ 5 'red 0 0))
(check-expect (stretch circ2 4)
              (make-circ 80 'green 10 15))



;; to-image : Circle -> Image
;; Convert Circle to image
(define (to-image c)
  (circle (circ-radius c)
          'solid
          (circ-color c)))
;; Tests/Examples:
(check-expect (to-image circ1)
              (circle 10
                      'solid
                      'red))
(check-expect (to-image circ2)
              (circle 20
                      'solid
                      'green))



;; draw-on : Circle Scene -> Scene
;; Draw the circle on the scene
(define (draw-on c s)
  (place-image (to-image c)
               (circ-x c)
               (circ-y c)
               s))
;; Tests/Examples:
(check-expect (draw-on circ1 (empty-scene 200 200))
              (place-image (circle 10
                                   'solid
                                   'red)
                           0
                           0
                           (empty-scene 200 200)))
(check-expect (draw-on circ2 (empty-scene 200 200))
              (place-image (circle 20
                                   'solid
                                   'green)
                           10
                           15
                           (empty-scene 200 200)))



;; within? : Circle Posn -> Boolean
;; is the posn within the circle?
(define (within? c posn)
  (<= (sqrt (+ (sqr (- (circ-x c)
                       (posn-x posn)))
               (sqr (- (circ-y c)
                       (posn-x posn)))))
      (circ-radius c)))
;; Tests/Examples:
(check-expect (within? circ1 (make-posn 100 0))
              false)
(check-expect (within? circ1 (make-posn 5 5))
              true)



;; overlap? : Circle Circle: Boolean
;; Do the circles overlap?
(define (overlap? c1 c2)
  (< (sqrt (+ (sqr (- (circ-x c1)
                      (circ-x c2)))
              (sqr (- (circ-y c1)
                      (circ-y c2)))))
     (+ (circ-radius c1)
        (circ-radius c2))))
;; Tests/Examples:
(check-expect (overlap? circ1 circ2)
              true)
(check-expect (overlap? circ1
                        (make-circ 3
                                   'yellow
                                   100
                                   100))
              false)


;; change-color : Circle Color -> Circle
;; Change the color of the circle
(define (change-color circle color)
  (make-circ (circ-radius circle)
             color
             (circ-x circle)
             (circ-y circle)))
;; Tests/Examples:
(check-expect (change-color circ1 'yellow)
              (make-circ 10
                         'yellow
                         0 0))
(check-expect (change-color circ2 'pink)
              (make-circ 20
                         'pink
                         10 15))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  Exercise 2  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; A Circle is a (new circle% Number Color Number Number)
;; How doth one scribe a template of a class. I know'th not.
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