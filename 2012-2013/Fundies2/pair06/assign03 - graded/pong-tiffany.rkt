#lang class/1
(require 2htdp/image)
(require class/universe)

;; Exercise 10: Pong ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Constants -------------------------------------------------------------------

(define SCENE-WIDTH 800)
(define SCENE-HALF-WIDTH (/ SCENE-WIDTH 2))
(define SCENE-HEIGHT 400)
(define SCENE-HALF-HEIGHT (/ SCENE-HEIGHT 2))
(define SCENE (empty-scene SCENE-WIDTH SCENE-HEIGHT "black"))

(define PLAYER-WIDTH 10)
(define PLAYER-HALF-WIDTH (/ PLAYER-WIDTH 2))
(define PLAYER-HEIGHT 50)
(define PLAYER-HALF-HEIGHT (/ PLAYER-HEIGHT 2))
(define PLAYER (rectangle PLAYER-WIDTH PLAYER-HEIGHT "solid" "white"))
(define PLAYER-VELOCITY 20)

(define BALL-RADIUS 10)
(define BALL-VELOCITY 10)

;; Definition : World ----------------------------------------------------------

;; A World is a (new world% Player Player Ball)

;; Template

#;(define (world-temp ...)
    (field player1) ...
    (field player2) ...
    (field ball) ...)

(define-class world%
  (fields player1 player2 ball)
  
  ; on-key : KeyEvent -> World
  ; advances the world upon KeyEvent
  (define (on-key k)
    (cond [(string=? k "w")
           (new world% 
                ((field player1) . move 'up)(field player2)(field ball))]
          [(string=? k "s")
           (new world% 
                ((field player1) . move 'down)(field player2)(field ball))]
          [(string=? k "up")
           (new world% 
                (field player1)((field player2) . move 'up)(field ball))]
          [(string=? k "down") 
           (new world% 
                (field player1)((field player2) . move 'down)(field ball))]
          [else this]))
  
  ; on-tick : -> World
  ; advances the world
  (define (on-tick)
    (new world% ((field player1) . update-score1 (field ball))
         ((field player2) . update-score2 (field ball))
         ((field ball) . goal . step 
                       . change-velocity (field player1) (field player2))))
  
  ; to-draw : -> Image
  ; draws the world
  (define (to-draw)
    ((field ball) . render 
         ((field player2) . score . render-score
              ((field player2) . render 
                   ((field player1) . score . render-score
                        ((field player1) . render SCENE)))))))
  
;; Definition : Player and Score -----------------------------------------------

;; An IPlayer implements:

;; move : Symbol -> IPlayer
;; if Symbol is 'up, moves the player up
;; if Symbol is 'down, moves the player down
;; render : Image -> Image
;; renders the player

;; A Player is a (new player% Number Number Score)
;; y-posn is measured in graphic coordinates
;; velocity is the velocity of the Player
;; score is a natural number

;; Template 

#; (define (player-temp ...)
     (field x-posn)...
     (field y-posn)...
     (field velocity)...
     (field score)...)

(define-class player% 
  (fields x-posn y-posn velocity score)
  
  ;; move : Symbol -> Player
  ;; if Symbol is 'up, moves the player up
  ;; if Symbol is 'down, moves the player down
  (define (move s)
    (cond [(and (symbol=? s 'up)
                (> (field y-posn) PLAYER-HALF-HEIGHT))
           (new player% (field x-posn)(- (field y-posn) (field velocity))
                (field velocity)(field score))]
          [(and (symbol=? s 'down)
                (< (field y-posn) (- SCENE-HEIGHT PLAYER-HALF-HEIGHT)))
           (new player% (field x-posn)(+ (field y-posn) (field velocity))
                (field velocity)(field score))]
          [else this]))
  
  (check-expect (player-1 . move 'up)
                (new player% 50 (- SCENE-HALF-HEIGHT 10) 10 score0))
  (check-expect (player-1 . move 'down)
                (new player% 50 (+ SCENE-HALF-HEIGHT 10) 10 score0))
  (check-expect (player-2 . move 'up) player-2)
  (check-expect (player-3 . move 'down) player-3)
  
  ;; update-score1 : Ball Number -> Player
  ;; Interp: if the Ball hits the right wall, updates player 1's score
  (define (update-score1 b)
    (cond [(and (b . collide-goal?)
                (>= (b . x-coord) (+ SCENE-WIDTH (b . radius))))
           (new player% (field x-posn) (field y-posn) (field velocity)
                ((field score) . add-score))]
          [else this]))
  
  (check-expect (player-1 . update-score1 (new ball% BALL-RADIUS "white" 
                      (make-rectangular 1000 200)
                      (make-rectangular -3 5)))
                (new player% 50 SCENE-HALF-HEIGHT 10 
                     (new score% 50 50 "white" 1)))
  
  (check-expect (player-1 . update-score1 ball1) player-1)
  
  ;; update-score2 : Ball Number -> Player
  ;; Interp: if the Ball hits the left wall, updates player 2's score
  (define (update-score2 b)
    (cond [(and (b . collide-goal?)(<= (b . x-coord) (- (b . radius))))
           (new player% (field x-posn)(field y-posn)(field velocity)
                ((field score) . add-score))]
          [else this]))
  
  (check-expect (player-1 . update-score2 (new ball% BALL-RADIUS "white" 
                      (make-rectangular -20 200)
                      (make-rectangular -3 5)))
                (new player% 50 SCENE-HALF-HEIGHT 10 
                     (new score% 50 50 "white" 1)))
  
  (check-expect (player-1 . update-score2 ball1) player-1)
  
  ;; render : Number Image -> Image
  ;; renders the player
  (define (render i)
    (place-image PLAYER (field x-posn) (field y-posn) i))
  
  (check-expect (player-1 . render SCENE)
                (place-image PLAYER 50 SCENE-HALF-HEIGHT SCENE)))

;; A Score is a (new score% Number Number String Number)
;; x-posn is the position of Score on the x-axis in graphic coordinates
;; y-posn is the position of Score on the y-axis in graphic coordinates
;; color is the color of the Score
;; num is the score's value

;; Template

#; (define (score-temp ...)
     (field x-posn) ...
     (field y-posn) ...
     (field color) ...
     (field num) ...)

(define-class score%
  (fields x-posn y-posn color num)
  
  ;; add-score : -> Score
  ; updates the score
  (define (add-score)
    (new score% (field x-posn) (field y-posn) (field color) (add1 (field num))))
  
  (check-expect (score0 . add-score)
                (new score% 50 50 "white" 1))
  
  ;; render-score : Image -> Image
  ;; renders the player's score in a chosen color
  ;; and places score at x-posn and y-posn of Image
  (define (render-score i)
    (place-image (text (number->string (field num)) 80 (field color))
                 (field x-posn) (field y-posn) i))
  
  (check-expect (score0 . render-score SCENE)
                (place-image (text "0" 80 "white") 50 50 SCENE)))

;; Examples
(define score0 (new score% 50 50 "white" 0))
(define SCORE1 (new score% 50 50 "red" 0))
(define SCORE2 (new score% (- SCENE-WIDTH 50) 50 "blue" 0))

(define player-1 (new player% 50 SCENE-HALF-HEIGHT 10 score0))
(define player-2 (new player% 50 PLAYER-HALF-HEIGHT 10 score0)) 
(define player-3 (new player% 50 (+ SCENE-HEIGHT PLAYER-HALF-HEIGHT) 10 score0))
(define PLAYER1 (new player% 100 SCENE-HALF-HEIGHT PLAYER-VELOCITY SCORE1))
(define PLAYER2 (new player% (- SCENE-WIDTH 100) 
                     SCENE-HALF-HEIGHT PLAYER-VELOCITY SCORE2))
    
;; Definition : Ball -----------------------------------------------------------

;; An IBall implements:
;; x-coord : -> Number
;; the IBall's x-coordinate
;; y-coord : -> Number
;; the IBall's y-coordinate
;; change-velocity : Player -> Ball
;; changes velocity of Ball if it hits the top or bottom wall or Player
;; step : -> IBall
;; updates the IBall
;; render : Image -> Image
;; renders the IBall

;; A Ball is a (new ball% Number String Complex Complex)
;; radius is the radius of the Ball
;; color is the color of the Ball
;; location (x,y) is represented as the complex number x+yi
;; velocity (x,y) is represented as the complex number x+yi

;; Template

#; (define (ball-temp ...)
     (field radius) ...
     (field color) ...
     (field location) ...
     (field velocity) ...)

(define-class ball%
  (fields radius color location velocity)
  
  ;; x-coord : -> Number
  ;; the Ball's x-coordinate
  (define (x-coord)
    (real-part (field location)))
  
  (check-expect (ball1 . x-coord) 50)
  
  ;; y-coord : -> Number
  ;; the Ball's y-coordinate
  (define (y-coord)
    (imag-part (field location)))
  
  (check-expect (ball1 . y-coord) 100)
  
  ;; collide-player? : Player -> Boolean
  ;; returns true if Ball collides with Player
  (define (collide-player? p)
    (and (<= (this . x-coord) (+ (p . x-posn) PLAYER-HALF-WIDTH))
         (>= (this . x-coord) (- (p . x-posn) PLAYER-HALF-WIDTH))         
         (<= (this . y-coord) (+ (p . y-posn) PLAYER-HALF-HEIGHT))
         (>= (this . y-coord) (- (p . y-posn) PLAYER-HALF-HEIGHT))))
  
  (check-expect (ball1 . collide-player? player-3) false)
  (check-expect (ball1 . collide-player? (new player% 50 100 10 score0)) true)
  
  ;; collide-wall? : -> Boolean
  ; returns true if Ball hits either the top or bottom wall
  (define (collide-wall?)
    (or (<= (this . y-coord) (field radius))
        (>= (this . y-coord) (- SCENE-HEIGHT (field radius)))))
  
  (check-expect (ball1 . collide-wall?) false)
  (check-expect (ball2 . collide-wall?) true)
  (check-expect (ball3 . collide-wall?) true)
  
  ;; collide-goal? : -> Boolean
  ;; returns true if Ball hits either left or right wall
  (define (collide-goal?)
    (or (<= (this . x-coord) (- (field radius)))
               (>= (this . x-coord) (+ SCENE-WIDTH (field radius)))))
  
  (check-expect ((new ball% BALL-RADIUS "white" 
                      (make-rectangular -20 200)
                      (make-rectangular -3 5)) . collide-goal?) true)
  (check-expect ((new ball% BALL-RADIUS "white" 
                      (make-rectangular 1000 200)
                      (make-rectangular -3 5)) . collide-goal?) true)
  (check-expect (ball1 . collide-goal?) false)
  
  ;; goal :  -> Ball
  ;; if Ball hits either the left or right wall,
  ;; creates new ball with random velocity at center of screen
  (define (goal)
    (cond [(this . collide-goal?)
           (new ball% BALL-RADIUS "white" 
                (make-rectangular SCENE-HALF-WIDTH SCENE-HALF-HEIGHT)
                (make-rectangular (- (random 20) 10) 
                                  (- (random 20) 10)))]
          [else this]))
  
  (check-range (real-part (((new ball% BALL-RADIUS "white" 
                                 (make-rectangular -20 200)
                                 (make-rectangular -3 5)) . goal) . velocity))
               -10 10)
  (check-range (imag-part (((new ball% BALL-RADIUS "white" 
                                 (make-rectangular -20 200)
                                 (make-rectangular -3 5)) . goal) . velocity))
               -10 10)
  
  ;; change-velocity : Player Player -> Ball
  ;; changes velocity of Ball if it hits the top or bottom wall or Player
  (define (change-velocity p1 p2)      
    (cond [(this . collide-wall?)
           (new ball% (field radius) (field color) (field location)
                (make-rectangular (real-part (field velocity)) 
                                  (- (imag-part (field velocity)))))]            
          [(or (this . collide-player? p1)(this . collide-player? p2))
           (new ball% (field radius) (field color) (field location)
                (make-rectangular (- (real-part (field velocity)))
                                  (imag-part (field velocity))))]
          [else this]))
  
  (check-expect (ball2 . change-velocity player-3 player-3)
                (new ball% BALL-RADIUS "white" 
                     (make-rectangular 100 BALL-RADIUS)
                     (make-rectangular 3 -5)))
  (check-expect (ball3 . change-velocity player-3 player-3)
                (new ball% BALL-RADIUS "white"
                     (make-rectangular 100 (- SCENE-HEIGHT BALL-RADIUS))
                     (make-rectangular 3 5)))
  (check-expect (ball1 . change-velocity player-3 
                       (new player% 50 100 10 score0))
                (new ball% BALL-RADIUS "white" 
                     (make-rectangular 50 100)
                     (make-rectangular -3 5)))
  (check-expect (ball1 . change-velocity player-3 player-3) ball1)
  
  ;; step : -> Ball
  ;; updates the Ball
  (define (step)
    (new ball% (field radius) (field color)
         (+ (field location) (field velocity))
         (field velocity)))
  
  (check-expect (ball1 . step)
                (new ball% BALL-RADIUS "white" (make-rectangular 53 105)
                     (make-rectangular 3 5)))
  
  ;; render : Image -> Image
  ;; renders the Ball
  (define (render i)
    (place-image (circle (field radius) "solid" (field color))
                 (this . x-coord)(this . y-coord) i)))
                 
;; Examples
(define ball1 (new ball% BALL-RADIUS "white" (make-rectangular 50 100) 
                   (make-rectangular 3 5)))
(define ball2 (new ball% BALL-RADIUS "white" (make-rectangular 100 BALL-RADIUS)
                   (make-rectangular 3 5))) ; top of screen
(define ball3 (new ball% BALL-RADIUS "white"
                   (make-rectangular 100 (- SCENE-HEIGHT BALL-RADIUS))
                   (make-rectangular 3 -5))) ; bottom of screen
(define BALL-START (new ball% BALL-RADIUS "white" 
                        (make-rectangular SCENE-HALF-WIDTH SCENE-HALF-HEIGHT) 
                   (make-rectangular 3 5)))

;; Big Bang --------------------------------------------------------------------

(define initial-world (new world% PLAYER1 PLAYER2 BALL-START))

(big-bang initial-world)


