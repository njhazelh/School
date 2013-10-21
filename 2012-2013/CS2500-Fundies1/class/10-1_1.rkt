;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname 10-1_1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
October 1, 2012
Class Work
Snake
|#

;; REQUIREMENTS
(require 2htdp/image)
(require 2htdp/universe)

;; WORLD CONSTANTS
(define X_TILES 20)
(define Y_TILES 20)
(define TILE_SIDE 10) ;; length of square tile side in pixels
(define TICK_RATE .1)
(define BACK_COLOR "tan")
(define SCENE_WIDTH  (* X_TILES TILE_SIDE)) ;; Scene height in pixels
(define SCENE_HEIGHT (* Y_TILES TILE_SIDE)) ;; Scene width in pixels
(define BACK_IMAGE (overlay (rectangle SCENE_WIDTH
                                       SCENE_HEIGHT
                                       "solid"
                                       BACK_COLOR)
                            (empty-scene SCENE_WIDTH
                                         SCENE_HEIGHT)))


;; FOOD CONSTANTS
(define FOOD_COLOR "green")
(define FOOD_RADIUS (floor (* .9 (sqrt (quotient TILE_SIDE 2)))))
(define FOOD_IMAGE (circle FOOD_RADIUS
                           "solid"
                           FOOD_COLOR))

;; SNAKE CONSTANTS
(define SNAKE_SPEED 10)
(define SNAKE_COLOR "red")
(define PIECE_RADIUS (sqrt (quotient TILE_SIDE 2)))
(define PIECE_IMAGE (circle PIECE_RADIUS
                            "solid"
                            SNAKE_COLOR))

;; DATA DEFINTIONS

#|
A Direction is one of:
  - 'up
  - 'down
  - 'left
  - 'right

A Segs is one of:
  - empty
  - (cons Posn Segs)

A Food is a Posn where x and y are the tile values
   -- (0,0)              : bottom left
   -- (X_TILES, Y_TILES) : top right
|#

(define-struct snake (dir segs))
#|
A Snake is a (make-snake Direction Segs)

Template:
(define (snake-temp snake)
   ... (snake-dir snake)  ...
   ... (snake-segs snake) ...)
|#

(define-struct world (food snake))
#|
A World is a (make-world Snake Food)

Template:
(define (world-temp world)
   ... (world-snake world) ...
   ... (world-food  world) ...)
|#
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; MISC. FUNCTIONS ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; tile-posn->pixel-posn : Posn -> Posn
;; Purpose : Takes a Posn where the x and y
;;           values are tile values, and converts
;;           it to a Posn of pixel values (graphical).
(define (tile-posn->pixel-posn posn)
  (make-posn (+ (* (posn-x posn)
                   TILE_SIDE)
                (quotient TILE_SIDE 2))
             (- SCENE_HEIGHT
                (quotient TILE_SIDE 2)
                (* (posn-y posn)
                   TILE_SIDE))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; PAINTING FUNCTIONS ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; food+scene : Food Scene -> Scene
;; Purpose    : Adds the image of the food
;;              to the scene.
(define (food+scene food scene)
  (place-image FOOD_IMAGE
               (posn-x (tile-posn->pixel-posn food))
               (posn-y (tile-posn->pixel-posn food))
               scene))

;; snake+scene : Segs Scene -> Scene
;; Purpose     : Adds the segments of the snake
;;               to the scene.
(define (snake+scene segs scene)
  (cond [(empty? snake-segs) scene]
        [else (place-image PIECE_IMAGE
                           (posn-x (tile-posn->pixel-posn (first segs)))
                           (posn-y (tile-posn->pixel-posn (first segs)))
                           (snake+scene (rest segs
                                              scene)))]))


;; world-scene : World -> Scene
;; Purpose     : Renders the world with food and
;;               a snake on a background.
(define (world->scene world)
  (snake+scene (world-snake world)
               (food+scene (world-food world)
                           BACK_IMAGE)))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; SNAKE FUNCTIONS ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (move-head dir head)
  (cond [(symbol=? dir 'up   ) (make-posn (posn-x head)
                                          (add1 (posn-y head)))]
        [(symbol=? dir 'down ) (make-posn (posn-x head)
                                          (add1 (posn-y head)))]
        [(symbol=? dir 'left ) (make-posn (posn-x head)
                                          (add1 (posn-y head)))]
        [(symbol=? dir 'right) (make-posn (posn-x head)
                                          (add1 (posn-y head)))]
;; move-snake : Direction Segs -> Segs
;; Purpose    : Moves the first tile in the appropriate
;;              direction and propogrates locations down
;;              the snake.
(define (move-snake dir segs)
  ()

(define (change-dir snake new))

(define (grow-snake snake))

(define (eating? world))

(define (self-collide? snake))

(define (wall-collide?))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; FOOD FUNCTIONS ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (new-food world)
  (make-posn (random X_TILES)
             (random Y_TILES)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; WORLD FUNCTIONS ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; BIG BANG
(big bang )