#lang class/0

(require 2htdp/image)
(require class/universe)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SPACE INVADERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; CONSTANTS ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define SCENE_WIDTH 700)
(define SCENE_HEIGHT 600)
(define X_BORDER 20)
(define TOP_BORDER 40)

(define BULLET_SENSITIVITY 10)
(define BULLET_Y_VEL 10)

(define GUN_X_VEL 10)

(define BACKGROUND_COLOR 'black)
(define GUN_COLOR 'blue)
(define ALIEN_COLOR 'green)
(define BULLET_COLOR 'white)

(define GROUND_LEVEL 10)
(define GROUND_HEIGHT 20)
(define GROUND_COLOR 'green)

(define NUM_ALIENS_START 90)
(define NUM_ALIENS_PER_ROW_START 15)
(define ALIEN_GAP_START 40)

(define ALIEN_X_VEL_START 1.5)
(define ALIEN_Y_VEL -15)
(define GUN_START_X (quotient SCENE_WIDTH 2))
(define GUN_START_Y (- SCENE_HEIGHT 30))

(define BACKGROUND_IMAGE (overlay
                          (rectangle SCENE_WIDTH
                                     SCENE_HEIGHT
                                     'solid
                                     BACKGROUND_COLOR)
                          (empty-scene SCENE_WIDTH
                                       SCENE_HEIGHT)))
(define BULLET_IMAGE (above (triangle 5
                                      'solid
                                      BULLET_COLOR)
                            (rectangle 5
                                       10
                                       'solid
                                       BULLET_COLOR)))

(define ALIEN_IMAGE (circle 10
                            'solid
                            ALIEN_COLOR))

(define GUN_IMAGE (triangle 30
                             'solid
                             GUN_COLOR))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; CLASS DEFINITIONS ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; A World is a (new world% Gun [Listof Alien] [Listof Bullet] Number)
(define-class world%
  (fields gun aliens bullets score)
  
  ;; to-draw : -> Image
  ;; Draws the aliens, bullets, and gun on the world
  (define (to-draw)
    (send (field gun)
          draw-on
          (foldr (λ (b rest) (send b draw-on rest))
                 (foldr (λ (a rest) (send a draw-on rest))
                        BACKGROUND_IMAGE
                        (field aliens))
                 (field bullets))))
  
  ;; on-tick : -> World
  ;; updates the world
  ;; moves aliens
  ;; moves bullets
  ;; checks collisions
  ;; filers bullets off screen
  (define (on-tick)
    (new world%
         (field gun)
         (send this manage-aliens)
         (send this manage-bullets)
         (field score)))
  
  ;; manage-aliens: -> [Listof Alien]
  ;; Moves and filters the aliens
  (define (manage-aliens)
    (local ((define decend? (aliens-decend? (field aliens))))
      (map (λ (a) (if decend?
                      (send a decend)
                      (send a move))) 
           (filter (λ (a)
                     (not (ormap (λ (b) (send b
                                          collide?
                                          (send a x)
                                          (send a y)))
                             (field bullets))))
                   (field aliens)))))
  
  ;; manage-bullets : -> [Listof Bullet]
  ;; Moves and filters the bullets
  (define (manage-bullets)
    (map (λ (b) (send b move)) 
         (filter (λ (b) (not (or (send b off-screen?)
                                 (ormap (λ (a) (send b
                                                     collide?
                                                     (send a x)
                                                     (send a y)))
                                        (field aliens)))))
                 (field bullets))))
    
  
  ;; on-key : KeyEvent -> World
  ;; Updates the world according to a key stroke.
  (define (on-key ke)
    (cond [(string=? ke "left")
           (new world%
                (send (field gun) move 'left)
                (field aliens)
                (field bullets)
                (field score))]
          [(string=? ke "right")
           (new world%
                (send (field gun) move 'right)
                (field aliens)
                (field bullets)
                (field score))]
          [(string=? ke " ")
           (new world%
                (field gun)
                (field aliens)
                (cons (new bullet%
                           (send (field gun) x)
                           (send (field gun) y)
                           0
                           BULLET_Y_VEL)
                      (field bullets))
                (field score))]
          [else this]))
  
  ;; stop-on: -> Boolean
  (define (stop-when)
    (or (empty? (field aliens))
        (ormap (λ (a) (send a at-ground?))
           (field aliens)))))


;; A Bullet is a (new bullet% Number Number Number Number State)
(define-class bullet%
  (fields x y x-vel y-vel)
  
  ;; draw-on : Scene -> Image
  ;; Draws this bullet on the scene
  (define (draw-on scene)
    (place-image BULLET_IMAGE
                 (field x)
                 (field y)
                 scene))
  
  ;; move : -> Bullet
  ;; Moves the bullet by a step of the velocity
  (define (move)
    (new bullet%
         (+ (field x)
            (field x-vel))
         (- (field y)
            (field y-vel))
         (field x-vel)
         (field y-vel)
         ))
  
  ;; off-screen?: -> Boolean
  ;; Is the bullet off screen?
  (define (off-screen?)
    (or (< (field x)
           0)
        (> (field x)
           SCENE_WIDTH)
        (< (field y)
           0)
        (> (field y)
           SCENE_HEIGHT)))
 
  
  ;; collide? : Number Number -> Boolean
  ;; Is the point within range of the bullet?
  (define (collide? x y)
    (and (>= x
             (- (field x)
                BULLET_SENSITIVITY))
         (<= x
             (+ (field x)
                BULLET_SENSITIVITY))
         (>= y
             (- (field y)
                BULLET_SENSITIVITY))
         (<= y
             (+ (field y)
                BULLET_SENSITIVITY)))))



;; An Alien is a (new alien% Number Number Number Number State)
(define-class alien%
  (fields x y x-vel y-vel)
  
  ;; draw-on : Scene -> Scene
  ;; Draw the alien on the scene a the graphical coordinates
  ;; represented by fields (x,y)
  (define (draw-on scene)
    (place-image ALIEN_IMAGE
                 (field x)
                 (field y)
                 scene))
  
  ;; move : -> Alien
  ;; Move the alien by a step of the x-vel.
  ;; + -> right
  ;; - -> left
  (define (move)
    (new alien%
         (+ (field x)
            (field x-vel))
         (field y)
         (field x-vel)
         (field y-vel)))
  
  ;; decend : -> Alien
  ;; Move the alien down by a step of the y-vel.
  (define (decend)
    (new alien%
         (field x)
         (- (field y)
            (field y-vel))
         (- (field x-vel))
         (field y-vel)))
  
  ;; at-edge? : -> Boolean
  ;; Is the alien at the edge of the screen?
  (define (at-edge?)
    (or (<= (field x)
            X_BORDER)
        (>= (field x)
            (- SCENE_WIDTH
               X_BORDER))))
 
  
  ;; at-ground : -> Boolean
  ;; Is the alien on the ground?
  (define (at-ground?)
    (>= (field y)
        (- SCENE_HEIGHT 
           GROUND_LEVEL))))

;; A Direction is one of:
;; - 'left
;; - 'right

;; A Gun is one of (new gun% Number Number)
(define-class gun%
  (fields x y x-vel)
  
  ;; move : Direction -> Gun
  ;; Moves the gun left or right
  (define (move dir)
    (if (symbol=? dir 'left)
        (new gun%
             (max X_BORDER
                  (- (field x)
                     (field x-vel)))
             (field y)
             (field x-vel))
        (new gun%
             (min (- SCENE_WIDTH
                     X_BORDER)
                  (+ (field x)
                     (field x-vel)))
             (field y)
             (field x-vel))))
  
  ;; draw-on : Scene -> Scene
  ;; Draw the gun on the given scene at the point
  ;; represented by fields (x,y) in graphical coordinates.
  (define (draw-on scene)
    (place-image GUN_IMAGE
                 (field x)
                 (field y)
                 scene)))

;; Static Helper Functions

;; far-x-alien : [Listof Alien] [Number Number -> Boolean]
;; Find the furthest left or right alien
;; < -> leftmost
;; > -> rightmost
(define (far-x-alien aliens test)
  (cond [(empty? aliens) (new alien%
                              (/ SCENE_WIDTH 2)
                              (/ SCENE_HEIGHT 2)
                              0
                              0)]
        [else (local ((define furthest (far-x-alien (rest aliens) test)))
                (if (test (send (first aliens) x)
                          (send furthest x))
                    (first aliens)
                    furthest))]))

;; aliens-decend? : [Listof Aliens] -> Boolean
;; Should the aliens decend?
(define (aliens-decend? aliens)
  (local ((define alien-dir (if (negative? (send (first aliens) x-vel))
                                'left
                                'right)))
    (or (and (symbol=? alien-dir 'left)
             (send (far-x-alien aliens <) at-edge?))
        (and (symbol=? alien-dir 'right)
             (send (far-x-alien aliens >) at-edge?)))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; DEFINITIONS USING CLASSES ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define ALIEN_HOARD_START (build-list NUM_ALIENS_START
                                      (λ (n) (new alien%
                                                  (+ X_BORDER
                                                     (* ALIEN_GAP_START
                                                        (modulo n
                                                                NUM_ALIENS_PER_ROW_START)))
                                                  (+ TOP_BORDER
                                                     (* ALIEN_GAP_START
                                                     (floor (/ n
                                                               NUM_ALIENS_PER_ROW_START))))
                                                  ALIEN_X_VEL_START
                                                  ALIEN_Y_VEL))))
                                                             
                                                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; BIG-BANG ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(big-bang (new world%
               (new gun%
                    GUN_START_X
                    GUN_START_Y
                    GUN_X_VEL)
               ALIEN_HOARD_START
               empty
               0))






