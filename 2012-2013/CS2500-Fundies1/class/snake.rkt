;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname snake) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; Snake Game
(require 2htdp/image)
(require 2htdp/universe)

;; Lectures 10/1 and 10/4/2012.  
;; We haven't completed the game yet. 

;; SNAKE WORLD
;;
(define-struct world (snake food))
(define-struct snake (dir segs))
;; A World is (make-world Snake Food)
;; A Food is a Posn 
;; A Snake is (make-snake Direction Segs)
;;    Snake must contain at least one segment
;;    The head is the first element in Segs

;; A Segs is one of:  ; Note: Segs is a list of Posns! 
;; - empty
;; - (cons Posn Segs)
;; food and seg positions are in grid coordinates

;; A Direction is one of: 
;; - 'up
;; - 'down
;; - 'left 
;; - 'right

;; Initial Wish List: 

;; world->scene : World -> Scene
;; food+scene : Food Scene -> Scene
;; snake+scene : Snake Scene -> Scene

;; world->world : World -> World

;; snake-move : Snake -> Snake
;; change direction in response to key events 
;; snake-eat : 
;; snake-grow : 

;; eating? : 
;; self-collide? : 
;; wall-collide? : 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONSTANTS: things we need to keep track of that never change

(define GRID-SQSIZE 10) ; width of a game-board square
(define BOARD-HEIGHT 20) ; height of board in grid squares
(define BOARD-WIDTH 30) ; width of board in grid squares
(define BOARD-HT/PIX (* GRID-SQSIZE BOARD-HEIGHT))
(define BOARD-WD/PIX (* GRID-SQSIZE BOARD-WIDTH))

(define BACKGROUND (empty-scene BOARD-WD/PIX BOARD-HT/PIX))

(define TICK-RATE 0.3) 

(define SEGMENT-RADIUS (quotient GRID-SQSIZE 2))
(define SEGMENT-IMAGE (circle SEGMENT-RADIUS 'solid 'red))
(define FOOD-RADIUS (floor (* 0.9 SEGMENT-RADIUS)))
(define FOOD-IMAGE (circle FOOD-RADIUS 'solid 'green))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define Food1 (make-posn 5 3))
(define Snake1 (make-snake 'left (cons (make-posn 6 10) empty)))
(define World1 (make-world Snake1 Food1))

(define Snake2 (make-snake 'left (cons (make-posn 5 3) empty)))
(define World2 (make-world Snake2 Food1)) ; an eating scenario

(define Food3 (make-posn 10 20))
(define Snake3 
  (make-snake 'left 
              (cons (make-posn 5 3) 
                    (cons (make-posn 6 3) empty)))) ; 2-segment snake
(define World3 (make-world Snake3 Food3))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
;; Templates

#;(define (world-temp w)
  ... (world-snake w) ... (world-food w))

#;(define (food-temp f)
  ... (posn-x f) ... (posn-y f)...)

#;(define (snake-temp snk)
  ... (snake-dir snk) ... (snake-segs snk))
  
#;(define (segs-temp segs)
  (cond [(empty? segs) ...]
        [else ... (first segs) ... (segs-temp (rest segs)) ...]))
  
#;(define (direction-temp dir)
  (cond [(symbol=? dir 'up) ...]
        [(symbol=? dir 'down) ...]
        [(symbol=? dir 'left) ...]
        [(symbol=? dir 'right) ...]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Image/scene painting functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world->scene : World -> Image
;; Build an image of the given world
(define (world->scene w)
  (snake+scene (world-snake w) 
               (food+scene (world-food w) BACKGROUND)))

;; food+scene: Food Image -> Image
;; Add image of food to the given scene
(define (food+scene f scn)
  (place-image-on-grid FOOD-IMAGE (posn-x f) (posn-y f) scn))

;; place-image-on-grid : Image Number Number Image -> Image
;; Just like place-image, but takes x,y in grid coordinates
(define (place-image-on-grid img1 x y img2)
  (place-image img1 
               (- (* GRID-SQSIZE x) (quotient GRID-SQSIZE 2))
               (- BOARD-HT/PIX 
                  (- (* GRID-SQSIZE y) (quotient GRID-SQSIZE 2)))
               img2))


;; snake+scene: Snake Image -> Image
;; Add image of the snake to the given scene
(define (snake+scene snk scn)
  (segments+scene (snake-segs snk) scn))

;; segments+scene : Segs Image -> Image
;; Add the snake's segments to the scene
(define (segments+scene segs scn)
  (cond [(empty? segs) scn]
        [else (place-image-on-grid SEGMENT-IMAGE
                                   (posn-x (first segs))
                                   (posn-y (first segs))
                                   (segments+scene (rest segs) scn))]))
  
  
;; Examples/Tests: scene-painting functions
(check-expect (food+scene Food1 BACKGROUND)
              (place-image FOOD-IMAGE 45 175 BACKGROUND))

(check-expect (segments+scene (cons (make-posn 6 10) empty) BACKGROUND)
              (place-image SEGMENT-IMAGE 55 105 BACKGROUND))

(check-expect (snake+scene Snake1 BACKGROUND)
              (place-image SEGMENT-IMAGE 55 105 BACKGROUND))

(check-expect (world->scene World1)
              (place-image SEGMENT-IMAGE 55 105 
                           (place-image FOOD-IMAGE 45 175 BACKGROUND)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Snake motion and growth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; snake-slither : Snake -> Snake
;; Move the snake by one step in appropriate direction
;;  How: new head is old head moved by one step in approp direc
;;       new tail is old segs minus last
(define (snake-slither snk)
  (make-snake (snake-dir snk) 
              (move-segs (snake-segs snk) (snake-dir snk))))

;; A NESegs (non-empty segments) is one of: 
;; -- (cons Posn empty)
;; -- (cons Posn NESegs)

;; move-segs : NESegs Direction -> NESegs
;; Move the snake's segments by one step
;;  How: new head is old head moved by one step in approp direc
;;       new tail is old segs minus last
(define (move-segs nesegs dir)
  (cons (move-seg (first nesegs) dir)
        (segments-all-but-last nesegs)))

;; segments-all-but-last: NESegs -> Segs
;; remove the last segment in the list 
(define (segments-all-but-last nesegs)
  (cond [(empty? (rest nesegs)) empty]
        [else (cons (first nesegs) 
                    (segments-all-but-last (rest nesegs)))]))

;; move-seg : Posn Direction -> Posn
;; move the segment in the given direction
(define (move-seg p dir)
  (cond [(symbol=? dir 'up) 
         (make-posn (posn-x p) (add1 (posn-y p)))]
        [(symbol=? dir 'down) 
         (make-posn (posn-x p) (sub1 (posn-y p)))]        
        [(symbol=? dir 'left) 
         (make-posn (sub1 (posn-x p)) (posn-y p))]
        [(symbol=? dir 'right) 
         (make-posn (add1 (posn-x p)) (posn-y p))]))

;; snake-grow : Snake -> Snake
;; Grow snake one step
;; This is just like snake-slither except we don't drop last seg
(define (snake-grow snk)
  (make-snake (snake-dir snk)
              (cons (move-seg (first (snake-segs snk)) (snake-dir snk))
                    (snake-segs snk))))

;; eat&grow : World -> World
;; Eat the current food, grow the snake and produce new food
(define (eat&grow w)
  (make-world (snake-grow (world-snake w))
              (make-posn (add1 (random BOARD-WIDTH))
                         (add1 (random BOARD-HEIGHT)))))


;; Examples/Tests for snake movement and growth
(check-expect (snake-slither Snake1)
              (make-snake 'left 
                          (cons (make-posn 5 10) empty)))
  
(check-expect (snake-grow Snake1)
              (make-snake 'left
                          (cons (make-posn 5 10)
                                (cons (make-posn 6 10) empty))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Collision detection
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; posn=?  : Posn Posn -> Boolean
;; Are the posns the same point?
;; Examples:
;;  (make-posn 1 1) (make-posn 0 0) -> false
;;  (make-posn 1 1) (make-posn 1 1) -> true
(define (posn=? p1 p2)
  (and (= (posn-x p1) (posn-x p2))
       (= (posn-y p2) (posn-y p2))))
;; Tests:
(check-expect (posn=? (make-posn 1 1) (make-posn 0 0)) false)
(check-expect (posn=? (make-posn 1 1) (make-posn 1 1)) true)
               
               
;; eating? : World -> Boolean
;; check if snake head overlaps food
(define (eating? w)
  (equal? (first (snake-segs (world-snake w)))
          (world-food w)))

;; segs-collide? : Seg Segs -> Boolean
;; Is the head at the same point as another
;; segment?
;; Examples:
;;    (make-posn 1 1) (list (make-posn 1 1) (make-posn 1 2)) -> true
;;    (make-posn 1 1) (list (make-posn 2 2) (make-posn 3 2)) -> false
(define (segs-collide? head segs)
  (and (not (empty? segs))
       (or (posn=? head (first segs))
           (segs-collide? head (rest segs)))))
;; Tests:
(check-expect (segs-collide? (make-posn 1 1) (list (make-posn 1 1) (make-posn 1 2))) true)
(check-expect (segs-collide? (make-posn 1 1) (list (make-posn 2 2) (make-posn 3 2))) false)


;; self-collide? : Snake -> Boolean
;; Is the snake eating itself?
;; Examples:
;; TO DO
(define (self-collide? snake)
  (segs-collide? (first (snake-segs snake))
                (rest  (snake-segs snake))))
;; Tests:
;;   TO DO


;; wall-collide? : Seg -> Boolean
;; Is the head off the grid?
;; Examples:
;;    (make-posn  -1  -1) -> true
;;    (make-posn 100 100) -> true
;;    (make-posn   1 100) -> true
;;    (make-posn 100   1) -> true
;;    (make-posn   1   1) -> false
(define (wall-collide? seg)
  (or (< (posn-x seg) 1)
      (< (posn-y seg) 1)
      (> (posn-x seg) BOARD-WIDTH)
      (> (posn-y seg) BOARD-HEIGHT)))
;; Tests:
(check-expect (wall-collide? (make-posn  -1  -1)) true)
(check-expect (wall-collide? (make-posn 100  100)) true)
(check-expect (wall-collide? (make-posn   1  100)) true)
(check-expect (wall-collide? (make-posn 100    1)) true)
(check-expect (wall-collide? (make-posn   1    1)) false)


;; snake-death? : Snake -> Boolean
;; Did the snake hit the wall or eat
;; itself?
;; Examples:
;;    TO DO
(define (snake-death? snake)
  (or (wall-collide? (first (snake-segs snake)))
      (self-collide? snake)))
;; Tests:
;; TO DO


;; Examples/Tests for collision functions
(check-expect (eating? World2) true)
(check-expect (eating? World3) false)

;; change-snake-dir : World Direction -> world
;; Changes the direction of the snake
(define (change-snake-dir w dir)
  (make-world (make-snake dir
                          (snake-segs (world-snake w)))
              (world-food w)))
;; Tests:
;;;



;; world->world : World -> World
;; change the world one step
;; (Right now this is version 1 for early testing)
(define (world->world w)
  (cond [(eating? w) (eat&grow w)]
        [else (make-world (snake-slither (world-snake w)) (world-food w))]))

;; game-over? : World -> Boolean
;; Is the game over?
;; Examples:
;;   TO DO
(define (game-over? world)
  (snake-death? (world-snake world)))
;; Tests:
;;   TO DO


(define (key-control world key)
  (cond [(key=? key "up")    (change-snake-dir world 'up)]
        [(key=? key "down")  (change-snake-dir world 'down)]
        [(key=? key "left")  (change-snake-dir world 'left)]
        [(key=? key "right") (change-snake-dir world 'right)]
        [else world]))
        

;; early testing: uses world->world.v1
(big-bang World1
          (to-draw world->scene)
          (on-tick world->world TICK-RATE)
          (stop-when game-over?)
          (on-key key-control))












