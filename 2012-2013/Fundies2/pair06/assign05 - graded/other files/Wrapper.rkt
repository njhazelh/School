#lang class/1

(require 2htdp/image)
(require class/universe)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CONSTANTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define TICKS_PER_SEC 28)
(define WORLD_W 200)
(define WORLD_H 200)
(define BORDER_W 50)
(define TEXT_COLOR 'blue)
(define WRAPPER_COLOR 'black)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CLASS DEFINITIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A World is (new world Number Number Number Number Number Color Number Number)
;; x : The x position of the center of the world in the wrapper (graphical)
;; y : The y position of the center of the world in the wrapper (graphical)
;; w : The width in pixels of the world
;; h : The height in pixels of the world
;; count : The count used to show ticks are being passed
;; color : The color of the background
;; mx : The x position of the mouse in the world (origin is top left of world)
;; my : The y position of the mouse in the world (origin is top left of world)
(define-class world%
  (fields x y w h count color mx my)
  
  ;; Template:
  #;(define (world%-temp)
      (this . x)     ...
      (this . y)     ...
      (this . w)     ...
      (this . h)     ...
      (this . count) ...
      (this . color) ...
      (this . mx)    ...
      (this . my)    ...)
  
  
  ;; on-tick : -> World
  ;; Update the counter
  (define (on-tick)
    (new world%
         (this . x)
         (this . y)
         (this . w)
         (this . h)
         (modulo (add1 (this . count))
                 (* TICKS_PER_SEC 60))
         (this . color)
         (this . mx)
         (this . my)))
  ;; Tests/Examples:
  (check-expect (world1 . on-tick)
                (new world% 150 150 200 200 1 'black 100 100))
  (check-expect (world2 . on-tick)
                (new world% 450 150 200 200 24 'orange 0 150))
  (check-expect (world3 . on-tick)
                (new world% 150 150 200 200 1 'white 150 0))
  (check-expect (world4 . on-tick)
                (new world% 150 150 200 200 0 'purple 100 100))
  
  
  
  ;; on-mouse : Number Number MouseEvent -> World
  ;; Manage MouseEvents
  (define (on-mouse x y me)
    (cond [(mouse=? me "button-down")
           (this . change-color 'orange . set-mouse x y)]
          [(mouse=? me "button-up")
           (this . change-color 'white . set-mouse x y)]
          [else (this . set-mouse x y)]))
  ;; Tests/Examples:
  (check-expect (world1 . on-mouse 0 0 "button-down")
                (new world% 150 150 200 200 0 'orange 0 0))
  (check-expect (world1 . on-mouse 0 0 "button-up")
                (new world% 150 150 200 200 0 'white 0 0))
  (check-expect (world1 . on-mouse 0 0 "move")
                (new world% 150 150 200 200 0 'black 0 0))
  (check-expect (world2 . on-mouse 12 34 "move")
                (new world% 450 150 200 200 23 'orange 12 34))
  (check-expect (world3 . on-mouse 45 67 "button-down")
                (new world% 150 150 200 200 0 'orange 45 67))
  (check-expect (world4 . on-mouse 67 89 "button-up")
                (new world% 150 150 200 200 1679 'white 67 89))
  
  
  
  ;; on-key : KeyEvent -> World
  ;; Manage KeyEvents
  (define (on-key ke)
    (cond [(key=? ke "a")
           (this . change-color 'red)]
          [(key=? ke "s")
           (this . change-color 'pink)]
          [(key=? ke "d")
           (this . change-color 'purple)]
          [(key=? ke "f")
           (this . change-color 'green)]
          [(key=? ke "g")
           (this . change-color 'yellow)]
          [else this]))
  ;; Tests/Examples:
  (check-expect (world1 . on-key "a")
                (new world% 150 150 200 200 0 'red 100 100))
  (check-expect (world1 . on-key "s")
                (new world% 150 150 200 200 0 'pink 100 100))
  (check-expect (world1 . on-key "d")
                (new world% 150 150 200 200 0 'purple 100 100))
  (check-expect (world1 . on-key "f")
                (new world% 150 150 200 200 0 'green 100 100))
  (check-expect (world1 . on-key "g")
                (new world% 150 150 200 200 0 'yellow 100 100))
  (check-expect (world1 . on-key "r")
                (new world% 150 150 200 200 0 'black 100 100))
  
  
  
  ;; to-draw : -> Image
  ;; Draw this world
  (define (to-draw)
    (place-image (circle 3 'solid 'black)
                 (this . mx)
                 (this . my)
                 (overlay (text (number->string (quotient (this . count)
                                                          TICKS_PER_SEC))
                                40
                                TEXT_COLOR)
                          (rectangle (this . w)
                                     (this . h)
                                     'solid
                                     (this . color)))))
  ;; Tests/Examples:
  (check-expect (world1 . to-draw)
                (place-image (circle 3 'solid 'black)
                             100 100
                             (overlay (text "0" 40 TEXT_COLOR)
                                      (rectangle 200  200 'solid 'black))))
  (check-expect (world2 . to-draw)
                (place-image (circle 3 'solid 'black)
                             0 150
                             (overlay (text "0" 40 TEXT_COLOR)
                                      (rectangle 200  200 'solid 'orange))))
  (check-expect (world3 . to-draw)
                (place-image (circle 3 'solid 'black)
                             150 0
                             (overlay (text "0" 40 TEXT_COLOR)
                                      (rectangle 200  200 'solid 'white))))
  (check-expect (world4 . to-draw)
                (place-image (circle 3 'solid 'black)
                             100 100
                             (overlay (text "59" 40 TEXT_COLOR)
                                      (rectangle 200  200 'solid 'purple))))
  
  
  ;; change-color : Color -> World
  ;; change the world color:
  (define (change-color color)
    (new world%
         (this . x)
         (this . y)
         (this . w)
         (this . h)
         (this . count)
         color
         (this . mx)
         (this . my)))
  ;; Tests/Examples:
  (check-expect (world1 . change-color 'green)
                (new world% 150 150 200 200 0 'green 100 100))
  (check-expect (world1 . change-color 'black)
                (new world% 150 150 200 200 0 'black 100 100))
  (check-expect (world1 . change-color 'white)
                (new world% 150 150 200 200 0 'white 100 100))
  (check-expect (world1 . change-color 'red)
                (new world% 150 150 200 200 0 'red 100 100))
  (check-expect (world1 . change-color 'pink)
                (new world% 150 150 200 200 0 'pink 100 100))
  
  
  
  ;; set-mouse : number Number -> World
  ;; Set the x y coordinate of the mouse
  (define (set-mouse x y)
    (new world%
         (this . x)
         (this . y)
         (this . w)
         (this . h)
         (this . count)
         (this . color)
         x
         y))
  ;; Tests/Examples:
  (check-expect (world1 . set-mouse 0 0)
                (new world% 150 150 200 200 0 'black 0 0))
  (check-expect (world1 . set-mouse 10 20)
                (new world% 150 150 200 200 0 'black 10 20))
  (check-expect (world1 . set-mouse 50 90)
                (new world% 150 150 200 200 0 'black 50 90))
  (check-expect (world1 . set-mouse 3 4)
                (new world% 150 150 200 200 0 'black 3 4))
  
  
  ;; mouse-over? : Number Number -> Booolean
  ;; Is this wrapper-based (x,y) coordinate over the world?
  (define (mouse-over? x y)
    (and (<= x
             (+ (this . x)
                (/ (this . w) 2)))
         (>= x
             (- (this . x)
                (/ (this . w) 2)))
         (<= y
             (+ (this . y)
                (/ (this . h) 2)))
         (>= y
             (- (this . y)
                (/ (this . h) 2)))))
  ;; Tests/Examples:
  (check-expect (world1 . mouse-over? 0 0) false)
  (check-expect (world1 . mouse-over? 150 150) true)
  (check-expect (world1 . mouse-over? 50 50) true)
  (check-expect (world1 . mouse-over? 250 50) true)
  (check-expect (world1 . mouse-over? 50 250) true)
  (check-expect (world1 . mouse-over? 250 250) true)
  (check-expect (world2 . mouse-over? 450 150) true))

;; Some examples of worlds:
(define world1 (new world% 150 150 200 200 0 'black 100 100))
(define world2 (new world% 450 150 200 200 23 'orange 0 150))
(define world3 (new world% 150 150 200 200 0 'white 150 0))
(define world4 (new world% 150 150 200 200 1679 'purple 100 100))


;; A Status is one of:
;; 'run
;; 'quit


;; A Wrapper is a (new wrapper% Number Number [Listof World] Status)
;; w : The width of the wrapper in pixels
;; h : The height of the wrapper in pixels
;; worlds : The worlds that are contained in the wrapper
;; status : The status of the world (wrapper quits iff = 'quit)
(define-class wrapper%
  (fields w h worlds status)
  
  ;; Template:
  #;(define (wrapper%-temp)
      (this . w)      ...
      (this . h)      ...
      (this . worlds) ...
      (this . status) ...)
  
  
  
  ;; tick-rate: -> Number
  ;; The interval between ticks in seconds
  (define (tick-rate)
    (/ 1 TICKS_PER_SEC))
  ;; Tests/Examples:
  (check-expect (one-world-wrapper . tick-rate) (/ 1 TICKS_PER_SEC))
  (check-expect (two-world-wrapper . tick-rate) (/ 1 TICKS_PER_SEC))
  (check-expect (three-world-wrapper . tick-rate) (/ 1 TICKS_PER_SEC))
  (check-expect (four-world-wrapper . tick-rate) (/ 1 TICKS_PER_SEC))
  
  
  
  ;; on-tick : -> Wrapper
  ;; Send the worlds a tick
  (define (on-tick)
    (new wrapper%
         (this . w)
         (this . h)
         (map (λ (wld) (wld . on-tick))
              (this . worlds))
         (this . status)))
  ;; Tests/Examples:
  (check-expect (one-world-wrapper . on-tick)
                (new wrapper%
                     300 300
                     (list (new world% 150 150 200 200 1 'white 0 0))
                     'run))
  (check-expect (two-world-wrapper . on-tick)
                (new wrapper%
                     600 300
                     (list (new world% 150 150 200 200 1 'white 0 0)
                           (new world% 450 150 200 200 1 'white 0 0))
                     'run))
  (check-expect (three-world-wrapper . on-tick)
                (new wrapper%
                     900 300
                     (list (new world% 150 150 200 200 1 'white 0 0)
                           (new world% 450 150 200 200 1 'white 0 0)
                           (new world% 750 150 200 200 1 'white 0 0))
                     'run))
  (check-expect (four-world-wrapper . on-tick)
                (new wrapper% 
                     600 600
                     (list (new world% 150 150 200 200 1 'white 0 0)
                           (new world% 450 150 200 200 1 'white 0 0)
                           (new world% 150 450 200 200 1 'white 0 0)
                           (new world% 450 450 200 200 1 'white 0 0))
                     'run))
  
  
  
  ;; on-mouse: Number Number MouseEvent -> Wrapper
  ;; Send the MouseEvent to the worlds it is over
  (define (on-mouse x y me)
    (new wrapper%
         (this . w)
         (this . h)
         (map (λ (wld) (if (wld . mouse-over? x y)
                           (wld . on-mouse
                                (+ x
                                   (- (wld . x))
                                   (/ (wld . w) 2))
                                (+ y
                                   (- (wld . y))
                                   (/ (wld . h) 2))
                                me)
                           wld))
              (this . worlds))
         (this . status)))
  ;; Tests/Examples:
  (check-expect (one-world-wrapper . on-mouse 0 0 "button-down")
                one-world-wrapper)
  (check-expect (one-world-wrapper . on-mouse 150 150 "button-down")
                (new wrapper%
                     300 300
                     (list (new world% 150 150 200 200 0 'orange 100 100))
                     'run))
  (check-expect (one-world-wrapper . on-mouse 250 150 "button-up")
                (new wrapper%
                     300 300
                     (list (new world% 150 150 200 200 0 'white 200 100))
                     'run))
  (check-expect (two-world-wrapper . on-mouse 250 150 "button-up")
                (new wrapper%
                     600 300
                     (list (new world% 150 150 200 200 0 'white 200 100)
                           (new world% 450 150 200 200 0 'white   0   0))
                     'run))
  
  
  
  ;; on-key : KeyEvent -> Wrapper
  ;; Send the KeyEvent to each world
  ;; or quit if key = 'q'
  (define (on-key ke)
    (cond  [(key=? ke "q")
            (new wrapper%
                 (this . w)
                 (this . h)
                 (this . worlds)
                 'quit)]
           [else
            (new wrapper%
                 (this . w)
                 (this . h)
                 (map (λ (wld) (wld . on-key ke))
                      (this . worlds))
                 (this . status))]))
  ;; Tests/Examples:
  (check-expect (one-world-wrapper . on-key "q")
                (new wrapper%
                     300 300
                     (list (new world% 150 150 200 200 0 'white 0 0))
                     'quit))
  (check-expect (one-world-wrapper . on-key "a")
                (new wrapper%
                     300 300
                     (list (new world% 150 150 200 200 0 'red 0 0))
                     'run))
  (check-expect (two-world-wrapper . on-key "d")
                (new wrapper%
                     600 300
                     (list (new world% 150 150 200 200 0 'purple 0 0)
                           (new world% 450 150 200 200 0 'purple 0 0))
                     'run))
  (check-expect (four-world-wrapper . on-key "s")
                (new wrapper%
                     600 600
                     (list (new world% 150 150 200 200 0 'pink 0 0)
                           (new world% 450 150 200 200 0 'pink 0 0)
                           (new world% 150 450 200 200 0 'pink 0 0)
                           (new world% 450 450 200 200 0 'pink 0 0))
                     'run))
  
  
  
  ;; to-draw ; -> Scene
  ;; Render all the worlds on the wrapper
  (define (to-draw)
    (foldr (λ (wld scene) (place-image (wld . to-draw)
                                       (wld . x)
                                       (wld . y)
                                       scene))
           (rectangle (this . w)
                      (this . h)
                      'solid
                      WRAPPER_COLOR)
           (this . worlds)))
  ;; Tests/Examples:
  (check-expect (one-world-wrapper . to-draw)
                (place-image (place-image
                              (circle 3 'solid 'black)
                              0 0
                              (overlay (text "0" 40 TEXT_COLOR)
                                       (rectangle 200 200 'solid 'white)))
                             150 150
                             (rectangle 300 300 'solid 'black)))
  (check-expect (two-world-wrapper . to-draw)
                (place-image
                 (place-image
                  (circle 3 'solid 'black)
                  0 0
                  (overlay (text "0" 40 TEXT_COLOR)
                           (rectangle 200 200 'solid 'white)))
                 150 150
                 (place-image 
                  (place-image
                   (circle 3 'solid 'black)
                   0 0
                   (overlay (text "0" 40 TEXT_COLOR)
                            (rectangle 200 200 'solid 'white)))
                  450 150
                  (rectangle 600 300 'solid 'black))))
  (check-expect (three-world-wrapper . to-draw)
                (place-image
                 (place-image
                  (circle 3 'solid 'black)
                  0 0
                  (overlay (text "0" 40 TEXT_COLOR)
                           (rectangle 200 200 'solid 'white)))
                 150 150
                 (place-image 
                  (place-image
                   (circle 3 'solid 'black)
                   0 0
                   (overlay (text "0" 40 TEXT_COLOR)
                            (rectangle 200 200 'solid 'white)))
                  450 150
                  (place-image 
                  (place-image
                   (circle 3 'solid 'black)
                   0 0
                   (overlay (text "0" 40 TEXT_COLOR)
                            (rectangle 200 200 'solid 'white)))
                  750 150
                  (rectangle 900 300 'solid 'black)))))
                  
  ;; stop-when : -> Boolean
  ;; Quit if the wrapper status is 'quit
  (define (stop-when)
    (symbol=? (this . status) 'quit))
  ;; Tests/Examples:
  (check-expect ((new wrapper% 200 200 empty 'quit) . stop-when) true)
  (check-expect ((new wrapper% 200 200 empty 'run) . stop-when) false))


;; Wrapper Examples:
(define one-world-wrapper (new wrapper%
                               (+ WORLD_W (* BORDER_W 2))
                               (+ WORLD_H (* BORDER_W 2))
                               (list (new world%
                                          (+ (/ WORLD_W 2) BORDER_W)
                                          (+ (/ WORLD_H 2) BORDER_W)
                                          WORLD_W WORLD_H 0 'white 0 0))
                               'run))
(define two-world-wrapper (new wrapper%
                               (+ (* 2 WORLD_W) (* 4 BORDER_W))
                               (+ WORLD_H (* 2 BORDER_W))
                               (list (new world%
                                          (+ (/ WORLD_W 2) BORDER_W)
                                          (+ (/ WORLD_H 2) BORDER_W)
                                          WORLD_W WORLD_H 0 'white 0 0)
                                     (new world%
                                          (+ (* WORLD_W 1.5) (* BORDER_W 3))
                                          (+ (/ WORLD_H 2) BORDER_W)
                                          WORLD_W WORLD_H 0 'white 0 0))
                               'run))
(define three-world-wrapper (new wrapper%
                                 (+ (* 3 WORLD_W) (* 6 BORDER_W))
                                 (+ WORLD_H (* 2 BORDER_W))
                                 (list (new world%
                                            (+ (/ WORLD_W 2) BORDER_W)
                                            (+ (/ WORLD_H 2) BORDER_W)
                                            WORLD_W WORLD_H 0 'white 0 0)
                                       (new world%
                                            (+ (* WORLD_W 1.5) (* BORDER_W 3))
                                            (+ (/ WORLD_H 2) BORDER_W)
                                            WORLD_W  WORLD_H 0 'white 0 0)
                                       (new world%
                                            (+ (* WORLD_W 2.5) (* BORDER_W 5))
                                            (+ (/ WORLD_H 2)  BORDER_W)
                                            WORLD_W WORLD_H 0 'white 0 0))
                                 'run))
(define four-world-wrapper (new wrapper%
                                (+ (* 2 WORLD_W) (* 4 BORDER_W))
                                (+ (* 2 WORLD_H) (* 4 BORDER_W))
                                (list (new world%
                                           (+ (/ WORLD_W 2) BORDER_W)
                                           (+ (/ WORLD_H 2) BORDER_W)
                                           WORLD_W WORLD_H 0 'white 0 0)
                                      (new world%
                                           (+ (* WORLD_W 1.5) (* BORDER_W 3))
                                           (+ (/ WORLD_H 2) BORDER_W)
                                           WORLD_W WORLD_H 0 'white 0 0)
                                      (new world%
                                           (+ (/ WORLD_W 2) BORDER_W)
                                           (+ (* WORLD_H 1.5) (* BORDER_W 3))
                                           WORLD_W WORLD_H 0 'white 0 0)
                                      (new world%
                                           (+ (* WORLD_W 1.5) (* BORDER_W 3))
                                           (+ (* WORLD_H 1.5) (* BORDER_W 3))
                                           WORLD_W WORLD_H 0 'white 0 0))
                                'run))

;; big bang
(launch-many-worlds (big-bang four-world-wrapper)
                    #;(big-bang three-world-wrapper)
                    #;(big-bang two-world-wrapper)
                    #;(big-bang one-world-wrapper))
