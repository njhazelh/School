#lang class/0
(require 2htdp/image)
(require class/universe)

;;> Final score: 182/197
;;> Student: Tiffany Chao
;;> Student: Nick Jones
;;> Maximum points for this assignment: <+197>
;;> Graded by: Rebecca MacKenzie <rmacnz@ccs.neu.edu>


;;;;;;;;;;;;;;;;;;
;; ASSIGNMENT 2 ;;
;; Tiffany Chao ;;
;; Nick Jones ;;;;
;;;;;;;;;;;;;;;;;;


;; Exercise 2.1: SPACE INVADERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Constants -------------------------------------------------------------------

;; Cannon

(define CANNON (isosceles-triangle 30 45 "solid" "white")) ; placeholder
;;(define CANNON .) ; 40 * 40 pixels

(define CANNON-DEAD (isosceles-triangle 30 45 "solid" "red")) ; placeholder
;; (define CANNON-DEAD .)
(define CANNON-VELOCITY 10)
(define CANNON-WIDTH (image-width CANNON))
(define CANNON-HALF-WIDTH (/ CANNON-WIDTH 2)) ; 20 pixels
(define CANNON-HEIGHT (image-height CANNON))
(define CANNON-HALF-HEIGHT (/ CANNON-HEIGHT 2)) ; 20 pixels

;; Alien

(define ALIEN1 (square 30 "solid" "yellow")) ; placeholder
(define ALIEN2 (square 30 "solid" "red")) ; placeholder
(define ALIEN3 (square 30 "solid" "purple"))    ; placeholder

;;(define ALIEN1 .) ; 30 * 30 pixels
;;(define ALIEN2 .) ; 30 * 30 pixels
;;(define ALIEN3 (flip-vertical .)) ; 30 * 30 pixels

(define ALIEN-WIDTH (image-width ALIEN1))
(define ALIEN-HALF-WIDTH (/ ALIEN-WIDTH 2)) ; 15 pixels
(define ALIEN-HEIGHT (image-height ALIEN1))
(define ALIEN-HALF-HEIGHT (/ ALIEN-HEIGHT 2))
(define ALIEN-UNIT 5) ; distance alien travels upon update
(define ALIEN-SPACE-ACROSS (+ ALIEN-WIDTH 5)) ; space betw. aliens (horizontal)
(define ALIEN-SPACE-DOWN (+ ALIEN-HEIGHT 5)) ; space betw. aliens (vertical)
(define ALIEN-VELOCITY 5)
(define TICK-UPDATE 5)
(define TICK-RESET 100)
(define TICK-START 1)

;; Bullet

(define BULLET (rectangle 2 10 "solid" "white"))
(define BULLET-CANNON-VELOCITY -12)
(define BULLET-ALIEN-VELOCITY 6)
(define BULLET-HEIGHT 10)
(define BULLET-HALF-HEIGHT (/ BULLET-HEIGHT 2))

;; World

(define SCENE-WIDTH 500)
(define SCENE-HEIGHT 500)
(define SCENE-HALF-WIDTH (/ SCENE-WIDTH 2))
(define SCENE-HALF-HEIGHT (/ SCENE-HEIGHT 2))
(define SCENE (empty-scene SCENE-WIDTH SCENE-HEIGHT "black"))

;; Useful Functions -----------------------------------------------------------

;; distance-formula: Number Number Number Number -> Number
;; finds the distance between two points
(define (distance-formula x1 x2 y1 y2)
  (sqrt (+ (sqr (- y2 y1))
           (sqr (-  x2 x1)))))

(check-expect (distance-formula 5 10 0 0) 5)
(check-expect (distance-formula 0 3 0 4) 5)

;; positive: Number -> Number
;; converts number into positive number
(define (positive x)
  (cond [(negative? x) (- x)]
        [else x]))

(check-expect (positive 3) 3)
(check-expect (positive -3) 3)

;; negative: Number -> Number
;; converts number into negative number
(define (negative x)
  (cond [(positive? x) (- x)]
        [else x]))

(check-expect (negative -3) -3)
(check-expect (negative 3) -3)

;; Definitions: Cannon ---------------------------------------------------------

;; An Cannon is a (new cannon% Number Number Number Boolean)
;; x-posn is position along x-axis in graphic coordinates
;; direction: is the speed of the Cannon along x-axis
;; dead: is the Cannon alive or dead?

;; Template
#; (define (cannon-temp...)
     ...(field x-posn)
     ...(field y-posn)
     ...(field velocity)
     ...(field dead?))

(define-class cannon%
  (fields x-posn y-posn velocity dead?)
  
  ; move : -> Cannon
  ; moves the Cannon
  (define (move)
    (new cannon% (+ (x-posn) (field velocity))
         (field y-posn) (field velocity) (field dead?)))
  
  (check-expect (send cannon1 move) 
                (new cannon% 
                     (+ SCENE-HALF-WIDTH CANNON-VELOCITY)
                     (- SCENE-HEIGHT CANNON-HALF-HEIGHT)
                     CANNON-VELOCITY false))
  ;;> Insufficient testing. <-1>
  
  ; collide? : X -> Cannon
  ;;> Incorrect contract. This function returns a boolean. <-1>
  ; X is an object
  ; if the Cannon collides with an Alien or Alien's Bullet,
  ; returns dead Cannon
  ;;> I'm just going to pretend you said "returns false" there so I don't have to
  ;;> take off points for your purpose statement too.
  (define (collide? x)
    (or (and (<= (distance-formula (field x-posn) (send x x-posn)
                                   (field y-posn) (send x y-posn))
                 (+ CANNON-HALF-HEIGHT ALIEN-HALF-HEIGHT))
             (alien? x))
        (and (<= (distance-formula (field x-posn) (send x x-posn)
                                   (field y-posn)(send x y-posn))
                 (+ CANNON-HALF-HEIGHT BULLET-HALF-HEIGHT))
             (alien-bullet? x))))
  
  (check-expect (send cannon1 collide? 
                      (new bullet% SCENE-HALF-WIDTH 
                           (- SCENE-HEIGHT CANNON-HEIGHT) 10 'alien))
                true)
  (check-expect (send cannon1 collide?
                      (new alien% SCENE-HALF-WIDTH 
                           (- SCENE-HEIGHT CANNON-HALF-HEIGHT)
                           ALIEN-VELOCITY 'alien1 TICK-START))
                true)
  (check-expect (send cannon1 collide? alien1) false)
  
  ; dead-cannon -> Cannon
  ; returns dead Cannon
  (define (dead-cannon)
    (new cannon% (field x-posn) (field y-posn) (field velocity) true))
  
  (check-expect (send cannon1 dead-cannon) cannon4)
  
  ; is-dead? : -> Boolean
  ; is the Cannon dead?
  (define (is-dead?)
    (field dead?))
  
  (check-expect (send cannon4 is-dead?) true)
  (check-expect (send cannon1 is-dead?) false)
  
  ; draw : -> Image
  ; image of Cannon
  (define (draw) 
    (cond [(send this is-dead?) CANNON-DEAD]
          [else CANNON]))
  
  (check-expect (send cannon4 draw) CANNON-DEAD)
  (check-expect (send cannon1 draw) CANNON))

;; cannon? : X -> Boolean
;; is X a Cannon?
(define (cannon? x)
  (= (image-height (send x draw)) CANNON-HEIGHT))

(check-expect (cannon? cannon1) true)
(check-expect (cannon? alien1) false)

;; render-cannon : Cannon -> Image
;; renders Cannon on background scene
(define (render-cannon cannon)
  (place-image (send cannon draw)
               (send cannon x-posn)
               (send cannon y-posn)
               SCENE))

(check-expect (render-cannon cannon1)
              (place-image CANNON
                           SCENE-HALF-WIDTH
                           (- SCENE-HEIGHT CANNON-HALF-HEIGHT)
                           SCENE))
;;> This should be a method, not a function. <-1>
;;> Insufficient testing. <-1>

;; Examples
(define cannon1 (new cannon% SCENE-HALF-WIDTH
                     (- SCENE-HEIGHT CANNON-HALF-HEIGHT)
                     CANNON-VELOCITY false))
(define cannon2 (new cannon% CANNON-HALF-WIDTH 
                     (- SCENE-HEIGHT CANNON-HALF-HEIGHT)
                     CANNON-VELOCITY false)) 
; cannon at leftmost edge of screen
(define cannon3 (new cannon% 
                     (- SCENE-WIDTH CANNON-HALF-WIDTH)
                     (- SCENE-HEIGHT CANNON-HALF-HEIGHT)
                     CANNON-VELOCITY false))
; cannon at rightmost edge of screen
(define cannon4 (new cannon% SCENE-HALF-WIDTH
                     (- SCENE-HEIGHT CANNON-HALF-HEIGHT)
                     CANNON-VELOCITY true)); dead cannon

;; Definitions: Alien ----------------------------------------------------------

;; An Alien is one of:
;; - Alien1
;; - Alien2
;; - Alien3
;; Note: Aliens differ in appearance only

;; An Alien is a (new alien% Number Number Number Symbol Number)
;; x-posn is position along x-axis in graphic coordinates
;; y-posn is position along y-axis in graphic coordinates
;; velocity is the speed of the Alien along the x-axis

;; type describes type of alien and is one of:
;; - 'alien1
;; - 'alien2
;; - 'alien3

;; tick is the Alien's tick-rate

;; Template
#; (define (alien-temp...)
     ...(field x-posn)
     ...(field y-posn)
     ...(field velocity)
     ...(field type)
     ...(field tick))

(define-class alien%
  (fields x-posn y-posn velocity type tick)
  
  ; change-velocity : -> Alien
  ; changes velocity of Alien
  ;;> I think you just started writing a different function after this...
  (define (change-direction)
    (cond [(negative? (field velocity))
           (new alien% (field x-posn) (field y-posn)
                (positive (field velocity)) (field type) (field tick))]
          [(positive? (field velocity))
           (new alien% (field x-posn) (field y-posn)
                (negative (field velocity)) (field type) (field tick))]))
  
  (check-expect (send alien1 change-direction)
                (new alien% 50 50 (- ALIEN-VELOCITY) 'alien1 TICK-START))
  (check-expect (send (new alien% 50 50 (- ALIEN-VELOCITY) 'alien1 TICK-START)
                      change-direction) alien1)
  
  ; move-down : -> Alien
  ; moves Alien down along the y-axis
  (define (move-down)
    (new alien%
         (field x-posn)
         (+ (field y-posn) (* 2 ALIEN-UNIT))
         (field velocity)
         (field type)
         (field tick)))
  
  (check-expect (send alien1 move-down)
                (new alien% 50 60 ALIEN-VELOCITY 'alien1 TICK-START))
  ;;> Insufficient testing. <-1>
  
  ; move : -> Alien
  ; moves Alien along the x-axis
  (define (move)
    (new alien%
         (+ (field x-posn) (field velocity))
         (field y-posn)
         (field velocity)
         (field type)
         (field tick)))
  
  (check-expect (send alien1 move)
                (new alien% (+ 50 ALIEN-VELOCITY) 50 ALIEN-VELOCITY 
                     'alien1 TICK-START))
  (check-expect (send (new alien% 50 50 (- ALIEN-VELOCITY) 'alien1 TICK-START)
                      move)
                (new alien% (- 50 ALIEN-VELOCITY) 50
                     (- ALIEN-VELOCITY) 'alien1 TICK-START))
  
  ; move1 : -> Alien
  ; when (modulo tick TICK-UPDATE) equals 0, moves the Alien
  ; Note: uses tick to mimic the step-by-step movement of
  ; the aliens from the original Space Invaders game
  (define (move1)
    (cond [(= (modulo (field tick) TICK-UPDATE) 0)
           (send this move)]
          [else this]))
  ;;> Insufficient testing. <-1>
  
  ; move2 : -> Alien
  ; moves Alien down and changes direction of Alien
  (define (move2)
    (send (send this change-direction) move-down))
  ;;> Insufficient testing. <-1>
  
  ; collide? X -> Boolean
  ; X is an object
  ; does the Alien collide with a Cannon's Bullet or Cannon?
  (define (collide? x)
    (or (and (<= (distance-formula (field x-posn) (send x x-posn)
                                   (field y-posn) (send x y-posn))
                 (+ ALIEN-HALF-HEIGHT CANNON-HALF-HEIGHT))
             (cannon? x))
        (and (<= (distance-formula (field x-posn) (send x x-posn)
                                   (field y-posn) (send x y-posn))
                 (+ ALIEN-HALF-HEIGHT BULLET-HALF-HEIGHT))
             (cannon-bullet? x))))
  
  (check-expect (send alien1 collide? (new bullet% 50 50 10 'cannon)) true)
  (check-expect (send (new alien% SCENE-HALF-WIDTH SCENE-HEIGHT ALIEN-VELOCITY
                           'alien1 TICK-START) collide? cannon1) true)                
  (check-expect (send alien1 collide? bullet1) false)
  
  ; bottom-collide? : -> Boolean
  ; has the Alien collided with the bottom of the screen?
  (define (bottom-collide?)
    (>= (field y-posn)(- SCENE-HEIGHT ALIEN-HALF-HEIGHT)))
  
  (check-expect (send alien1 bottom-collide?) false)
  (check-expect (send alien6 bottom-collide?) true)
  
  ; update-tick : -> Alien
  ; increases the number tick by 1
  ; when tick = TICK-RESET, resets to 1
  (define (update-tick)
    (cond [(= (field tick) TICK-RESET)
           (new alien%
                (field x-posn)
                (field y-posn)
                (field velocity)
                (field type)
                TICK-START)]
          [else (new alien%
                     (field x-posn) 
                     (field y-posn) 
                     (field velocity)
                     (field type)
                     (add1 (field tick)))]))
  
  (check-expect (send (new alien% 50 50 ALIEN-VELOCITY 'alien1 TICK-START)
                      update-tick)
                (new alien% 50 50 ALIEN-VELOCITY 'alien1 (add1 TICK-START)))
  
  (check-expect (send alien2 update-tick) alien1)
  
  ; draw : -> Image
  ; draws the Alien
  (define (draw) 
    (cond [(symbol=? (field type) 'alien1) ALIEN1]
          [(symbol=? (field type) 'alien2) ALIEN2]
          [(symbol=? (field type) 'alien3) ALIEN3]))
  
  (check-expect (send alien1 draw) ALIEN1)
  (check-expect (send alien5 draw) ALIEN2))

;; alien? : X -> Boolean
;; is the object an Alien?
(define (alien? x)
  (= (image-height (send x draw)) ALIEN-HEIGHT))

(check-expect (alien? alien1) true)
(check-expect (alien? bullet1) false)

;; move-all-aliens : [listof Alien] -> [listof Alien]
;; if an Alien is at either the leftmost or rightmost edge of the screen
;; and (modulo tick TICK-RATE) equals 0,
;; changes direction and moves Aliens down
;; otherwise, moves Aliens left/right
(define (move-all-aliens aliens)
  (cond [(empty? aliens) empty]
        [(and (or (ormap (λ (a)(<= (send a x-posn) ALIEN-HALF-WIDTH)) aliens)
                  (ormap (λ (a)(>= (send a x-posn) 
                                   (- SCENE-WIDTH ALIEN-HALF-WIDTH)))
                         aliens))
              (= (modulo (send (first aliens) tick) TICK-UPDATE) 0))
         (map (λ (a) (send (send a move2) move1)) aliens)]        
        [else (map (λ (a) (send a move1)) aliens)]))

(check-expect (move-all-aliens (list alien2))
              (list (new alien% (+ 50 ALIEN-VELOCITY) 50 ALIEN-VELOCITY 
                         'alien1 TICK-RESET)))

(check-expect (move-all-aliens (list alien2 alien4)) ; 
              (list (new alien% (- 50 ALIEN-VELOCITY) 60 (- ALIEN-VELOCITY) 
                         'alien1 TICK-RESET)
                    (new alien% (- SCENE-WIDTH ALIEN-HALF-WIDTH)
                         60 (- ALIEN-VELOCITY) 'alien1 TICK-START)))
;;> Insufficient testing. <-1>

; update-all-aliens : [listof Alien] -> [listof Alien]
; updates tick for all aliens
(define (update-all-aliens aliens)
  (cond [(empty? aliens) empty] 
        [else (map (λ (a) (send a update-tick)) aliens)]))

(check-expect (update-all-aliens (list alien1))
              (list (new alien% 50 50 ALIEN-VELOCITY 'alien1 (+ 1 TICK-START))))

(check-expect (update-all-aliens (list alien2)) (list alien1))

; render-aliens : [listof Alien] Image -> Image
; renders aliens
(define (render-aliens aliens image)
  (cond [(empty? aliens) image]
        [else (place-image (send (first aliens) draw)
                           (send (first aliens) x-posn)
                           (send (first aliens) y-posn)
                           (render-aliens (rest aliens) image))]))

(check-expect (render-aliens empty SCENE) SCENE)
(check-expect (render-aliens (list alien1 alien5) SCENE)
              (place-image ALIEN1 50 50 (place-image ALIEN2 50 50 SCENE)))

;; build-alienwave : Number Number Number Symbol Number  -> [listof Alien]
;; builds row of aliens with center at (x-posn, y-posn) in graphic coordinates
;; row of aliens all have same type and direction
;; num represents number of aliens
(define (build-alienwave x-posn y-posn velocity type num)
  (local ((define (find-x-posns aliens x) ; finds x-posns, begin w/ empty list
            ; produces new [listof Alien]
            (cond [(zero? x) aliens]
                  [else (find-x-posns  
                         (cons (new alien% 
                                    (+ x-posn 
                                       (* ALIEN-SPACE-ACROSS 
                                          (- x (/ num 2))))
                                    y-posn
                                    velocity
                                    type
                                    TICK-START) aliens) (sub1 x))])))                                  
    (find-x-posns empty num)))
;;> Insufficient testing. <-1>

;; Examples
(define alien0 (new alien% (- ALIEN-HALF-WIDTH) 0 0 'alien1 TICK-START)) 
; placeholder Alien for (field last-alien)
(define alien1 (new alien% 50 50 ALIEN-VELOCITY 'alien1 TICK-START))

(define alien2 (new alien% 50 50 ALIEN-VELOCITY 'alien1 TICK-RESET)) 
; tick = TICK-RESET
(define alien3 (new alien% 
                    ALIEN-HALF-WIDTH 50 (- ALIEN-VELOCITY) 'alien1 TICK-START)) 
; leftmost edge of screen
(define alien4 (new alien% (- SCENE-WIDTH ALIEN-HALF-WIDTH)
                    50 ALIEN-VELOCITY 'alien1 TICK-START))
; rightmost edge of screen
(define alien5 (new alien% 50 50 ALIEN-VELOCITY 'alien2 TICK-START)) 
; different type of alien
(define alien6 (new alien% 50 (+ SCENE-HEIGHT ALIEN-HALF-HEIGHT)
                    ALIEN-VELOCITY 'alien1 TICK-START))
; bottom edge of screen

(define alienwave0 (list (new alien%  
                              (- SCENE-HALF-WIDTH ALIEN-SPACE-ACROSS)
                              20 ALIEN-VELOCITY 'alien1 TICK-START)
                         (new alien% SCENE-HALF-WIDTH
                              20 ALIEN-VELOCITY 'alien1 TICK-START)
                         (new alien%  
                              (+ SCENE-HALF-WIDTH ALIEN-SPACE-ACROSS)
                              20 ALIEN-VELOCITY 'alien1 TICK-START)))

(define alienwave1 (build-alienwave 
                    SCENE-HALF-WIDTH 
                    (+ (+ 5 ALIEN-HALF-HEIGHT) (* 4 ALIEN-SPACE-DOWN))
                    ALIEN-VELOCITY 'alien1 12))

(define alienwave2 (build-alienwave  
                    SCENE-HALF-WIDTH 
                    (+ (+ 5 ALIEN-HALF-HEIGHT) (* 3 ALIEN-SPACE-DOWN))
                    ALIEN-VELOCITY 'alien1 11))

(define alienwave3 (build-alienwave  
                    SCENE-HALF-WIDTH 
                    (+ (+ 5 ALIEN-HALF-HEIGHT) (* 2 ALIEN-SPACE-DOWN))
                    ALIEN-VELOCITY 'alien2 10))

(define alienwave4 (build-alienwave 
                    SCENE-HALF-WIDTH 
                    (+ (+ 5 ALIEN-HALF-HEIGHT) (* 1 ALIEN-SPACE-DOWN))
                    ALIEN-VELOCITY 'alien2 9))

(define alienwave5 (build-alienwave  
                    SCENE-HALF-WIDTH (+ 5 ALIEN-HALF-HEIGHT)
                    ALIEN-VELOCITY 'alien3 8))

(define alienarmy1 
  (append alienwave1 alienwave2 alienwave3 alienwave4 alienwave5))

;; Definitions: Bullet --------------------------------------------------------

;; A Bullet is a (new bullet% Number Number Number Symbol)
;; x-posn is position along x-axis in graphic coordinates
;; y-posn is position along y-axis in graphic coordinates
;; velocity is the speed of the Bullet
;; type: shot by Alien or Cannon?

#; (define (bullet-temp...)
     ...(field x-posn)
     ...(field y-posn)
     ...(field velocity)
     ...(field type))

(define-class bullet%
  (fields x-posn y-posn velocity type)
  
  ; move : -> Bullet
  ; moves bullet
  (define (move)
    (new bullet% 
         (field x-posn) 
         (+ (field y-posn) (field velocity)) 
         (field velocity)
         (field type)))
  
  (check-expect (send bullet1 move)
                (new bullet% 
                     100
                     (+ (- SCENE-HEIGHT CANNON-HEIGHT) BULLET-CANNON-VELOCITY)
                     BULLET-CANNON-VELOCITY 'cannon))
  ;;> Insufficient testing. <-1>
  
  ; offscreen? : -> Boolean
  ; is the Bullet offscreen?
  (define (offscreen?)
    (or (<= (field y-posn) (- BULLET-HALF-HEIGHT))
        (>= (field y-posn) (+ SCENE-HEIGHT BULLET-HALF-HEIGHT))))
  
  (check-expect (send bullet1 offscreen?) false)
  (check-expect (send bullet2 offscreen?) true)
  
  ; collide? : X -> Boolean
  ; X is an object
  ; does an Alien's Bullet and Cannon collide or
  ; does a Cannon's Bullet and Alien collide?
  (define (collide? x)
    (or (and (<= (distance-formula (field x-posn) (send x x-posn)
                                   (field y-posn) (send x y-posn))
                 (+ BULLET-HALF-HEIGHT CANNON-HALF-HEIGHT))
             (cannon? x)
             (alien-bullet? this))
        (and (<= (distance-formula (field x-posn) (send x x-posn)
                                   (field y-posn) (send x y-posn))
                 (+ BULLET-HALF-HEIGHT ALIEN-HALF-HEIGHT))
             (alien? x)
             (cannon-bullet? this))))
  
  (check-expect (send bullet1 collide? 
                      (new alien% 100 (- SCENE-HEIGHT CANNON-HEIGHT)
                           ALIEN-VELOCITY 'alien1 TICK-START)) true)
  
  (check-expect (send (new bullet% 
                           SCENE-HALF-WIDTH
                           (- SCENE-HEIGHT CANNON-HEIGHT) 
                           BULLET-ALIEN-VELOCITY 'alien) collide? cannon1) true)
  
  (check-expect (send bullet3 collide? cannon1) false)
  
  ; draw : -> Image
  ; renders the Bullet
  (define (draw) BULLET)
  
  (check-expect (send bullet1 draw) BULLET))

;; alien-bullet? : X -> Boolean
;; is X a Bullet shot by Alien?
(define (alien-bullet? x)
  (and (= (image-height (send x draw)) BULLET-HEIGHT)
       (symbol=? (send x type) 'alien)))

(check-expect (alien-bullet? bullet1) false)
(check-expect (alien-bullet? bullet3) true)
(check-expect (alien-bullet? alien1) false)

;; cannon-bullet? : X -> Boolean
;; is X a Bullet shot by Cannon?
(define (cannon-bullet? x)
  (and (= (image-height (send x draw)) BULLET-HEIGHT)
       (symbol=? (send x type) 'cannon)))

(check-expect (cannon-bullet? bullet1) true)
(check-expect (cannon-bullet? bullet3) false)
(check-expect (cannon-bullet? alien1) false)

;; remove-offscreen : [listof Bullet] -> [listof Bullet]
;; removes offsceen bullets
(define (remove-offscreen bullets)
  (cond [(empty? bullets) empty]
        [else (filter (λ (b) (not (send b offscreen?))) bullets)]))

(check-expect (remove-offscreen empty) empty)
(check-expect (remove-offscreen (list bullet1 bullet2)) (list bullet1))

;; move-all-bullets : [listof Bullet] -> [listof Bullet]
;; moves all bullets
(define (move-all-bullets bullets)
  (cond [(empty? bullets) empty] 
        [else (map (λ (b) (send b move)) bullets)]))

(check-expect (move-all-bullets empty) empty)
(check-expect (move-all-bullets (list (new bullet% 100 100 -10 'cannon)
                                      (new bullet% 200 150 10 'alien)))
              (list (new bullet% 100 90 -10 'cannon)
                    (new bullet% 200 160 10 'alien)))

; render-bullets : [listof Bullet] Image -> Image
; renders bullets onto image
(define (render-bullets bullets image)
  (cond [(empty? bullets) image]
        [else (place-image (send (first bullets) draw)
                           (send (first bullets) x-posn)
                           (send (first bullets) y-posn)
                           (render-bullets (rest bullets) image))]))

(check-expect (render-bullets empty SCENE) SCENE)
(check-expect (render-bullets (list (new bullet% 100 100 10 'cannon)
                                    (new bullet% 200 150 10 'cannon)) SCENE)
              (place-image BULLET 100 100 (place-image BULLET 200 150 SCENE)))

;; Examples
(define bullet1 (new bullet% 
                     100 
                     (- SCENE-HEIGHT CANNON-HEIGHT) 
                     BULLET-CANNON-VELOCITY 'cannon)) ;; Cannon's bullet
(define bullet2 (new bullet% 
                     100 
                     (- BULLET-HALF-HEIGHT) 
                     BULLET-CANNON-VELOCITY 'cannon)) ;; offscreen bullet
(define bullet3 (new bullet% 
                     100 
                     100 
                     BULLET-ALIEN-VELOCITY 'alien)) ;; Alien's bullet

;; Definitions: World ----------------------------------------------------------

;; A World is a (new world% Cannon [listof Alien] Alien [listof Bullet])
;; the Cannon moves left/right at the bottom of the screen
;; Aliens move left/right unless they reach either the
;; leftmost or rightmost edge of the screen, in which case Aliens move down
;; last-alien is the last randomly selected Alien 
;; bullets are all onscreen Bullets

#; (define (world-temp...)
     ...(field cannon)
     ...(field aliens)
     ...(field last-alien)
     ...(field bullets))

(define-class world%
  (fields cannon aliens last-alien bullets)
  
  ; on-key : KeyEvent -> World
  ; if left arrow key is pressed, 
  ; calls move method and changes Cannon velocity to negative number
  ; if right arrow key is pressed,
  ; calls move method and changes Cannon velocity to positve number
  ; if space bar is pressed,
  ; Cannon shoots bullet
  (define (on-key key)
    (cond [(and (string=? key "left")
                (> (send (field cannon) x-posn) CANNON-HALF-WIDTH))
           (new world% 
                (send 
                 (new cannon% 
                      (send (field cannon) x-posn) 
                      (send (field cannon) y-posn) 
                      (negative (send (field cannon) velocity))
                      (send (field cannon) dead?))
                 move)
                (field aliens)
                (field last-alien)
                (field bullets))]
          [(and (string=? key "right")
                (< (send (field cannon) x-posn)
                   (- SCENE-WIDTH CANNON-HALF-WIDTH)))
           (new world% 
                (send
                 (new cannon% 
                      (send (field cannon) x-posn)
                      (send (field cannon) y-posn)
                      (positive (send (field cannon) velocity))
                      (send (field cannon) dead?))
                 move)
                (field aliens)
                (field last-alien)
                (field bullets))]
          [(string=? key " ")
           (new world% 
                (field cannon)
                (field aliens)
                (field last-alien)
                (append (list (new bullet% 
                                   (send (field cannon) x-posn)
                                   (- SCENE-HEIGHT CANNON-HEIGHT)
                                   BULLET-CANNON-VELOCITY 'cannon))
                        (field bullets)))]           
          [else this]))
  
  ;; on-tick : -> World
  ;; updates the World
  (define (on-tick)
    (random-bullet (remove-dead (new world% 
                                     (field cannon)
                                     (move-all-aliens (update-all-aliens 
                                                       (field aliens)))
                                     (field last-alien)
                                     (move-all-bullets (remove-offscreen 
                                                        (field bullets)))))))
  
  (check-expect (send (new world% 
                           cannon1 
                           (list alien2)
                           alien0
                           (list (new bullet% 100 100 10 'alien)
                                 bullet2)) on-tick)
                (new world% 
                     cannon1 
                     (list alien1) alien1
                     (list (new bullet% 100 110 10 'alien))))
  ;;> Insufficient testing. <-1>
  
  ;; this test may fail due to random selection of an Alien from [listof Alien]
  ;;> Write a test that doesn't. Use what you know about the data!!!
  
  ;; stop-when : -> Boolean
  ;; stops updating the World when:
  ;; - Alien(s) collides with the bottom of the screen
  ;; - Cannon collides with Alien or Alien's bullet
  ;; - all Aliens are eliminated
  (define (stop-when)
    (or (empty? (field aliens))
        (send (first (field aliens)) bottom-collide?)
        (send (field cannon) is-dead?)))
  
  (check-expect (send testworld1 stop-when) true)
  (check-expect (send testworld2 stop-when) true)
  (check-expect (send testworld3 stop-when) true)
  (check-expect (send initial-world stop-when) false)
  
  ;; to-draw : -> Image
  ;; renders the World
  (define (to-draw)
    (cond [(and (send this stop-when)
                (empty? (field aliens)))
           (overlay (text "YOU WIN!" 50 "green") (draw-helper this))]
          [(and (send this stop-when)
                (or (send (first (field aliens)) bottom-collide?)
                    (send (field cannon) is-dead?)))
           (overlay (text "GAME OVER" 50 "red")(draw-helper this))]
          [else (draw-helper this)]))
  
  (check-expect (send testworld1 to-draw)
                (overlay (text "GAME OVER" 50 "red")(draw-helper testworld1)))
  
  (check-expect (send testworld2 to-draw)
                (overlay (text "YOU WIN!" 50 "green") (draw-helper testworld2)))
  
  (check-expect (send testworld3 to-draw)
                (overlay (text "GAME OVER" 50 "red")(draw-helper testworld3)))
  
  (check-expect (send initial-world to-draw) (draw-helper initial-world)))

;; draw-helper : World -> Image
;; renders the World
(define (draw-helper world)
  (render-bullets (send world bullets) 
                  (render-aliens (send world aliens)
                                 (render-cannon (send world cannon)))))

(check-expect (draw-helper 
               (new world% cannon1 (list alien1) alien0 (list bullet3)))
              (place-image BULLET 100 100 
                           (place-image ALIEN1 50 50
                                        (place-image CANNON 
                                                     SCENE-HALF-WIDTH
                                                     (- SCENE-HEIGHT 
                                                        CANNON-HALF-HEIGHT)
                                                     SCENE))))
;;> Insufficient testing. <-1>
;;> This should be a method, not a function. <-1>

;; remove-dead : World -> World
;; if a Cannon's Bullet and Alien collide, removes Bullet and Alien
;; if an Alien's Bullet and Cannon collide, removes Bullet and kills Cannon
;; if an Alien and Cannon collide, removes Alien and kills Cannon
(define (remove-dead world)
  (local ((define (return-cannon c)
            (cond [(or (ormap (λ (a) (send c collide? a))
                              (send world aliens))
                       (ormap (λ (b) (send c collide? b))
                              (send world bullets)))
                   (send c dead-cannon)]
                  [else c]))
          (define (return-aliens list-a)
            (filter (λ (a) (not (or (ormap 
                                     (λ (b) (send a collide? b)) 
                                     (send world bullets))
                                    (send a collide? (send world cannon)))))
                    list-a))
          (define (return-bullets list-b)
            (filter (λ (b) (not (or (ormap 
                                     (λ (a) (send b collide? a)) 
                                     (send world aliens))
                                    (send b collide? (send world cannon))))) 
                    list-b)))          
    (new world%
         (return-cannon (send world cannon))
         (return-aliens (send world aliens))
         (send world last-alien)
         (return-bullets (send world bullets)))))
;;> This should be a method, not a function. <-1>

;; random-bullet : World -> World
;; when (modulo Number (random Number)) equals 0
;; last randomly selected alien produces a bullet
;; otherwise, randomly selects alien 
;; and stores this alien in the field last-alien
(define (random-bullet world)
  (local ((define (pick-alien world) ; picks a random Alien from [listof Alien]
            (list-ref (send world aliens)
                      (random (length (send world aliens)))))
          (define (store-alien world)
            (new world% 
                 (send world cannon)
                 (send world aliens)
                 (pick-alien world)
                 (send world bullets))))             
    (cond [(empty? (send world aliens)) world]
          [(= (modulo 100 (+ 10 (add1 (random 20)))) 0)  
           (new world% 
                (send world cannon)
                (send world aliens)
                (send world last-alien)
                (append (list (new bullet% 
                                   (send (send world last-alien) x-posn)
                                   (+ (send (send world last-alien) y-posn) 
                                      ALIEN-HALF-HEIGHT)
                                   BULLET-ALIEN-VELOCITY 'alien)) 
                        (send world bullets)))]
          [else (store-alien world)])))
;;> Insufficient testing. <-1>

;; Examples

(define initial-world (new world% cannon1 alienarmy1 alien0 empty))
(define testworld1 (new world% 
                        cannon1 
                        (list (new alien% 50 SCENE-HEIGHT 
                                   ALIEN-VELOCITY 'alien1 TICK-START))
                        alien0 empty)) ;; alien is at bottom of screen
(define testworld2 (new world% cannon1 empty alien0 empty)) ;; no aliens
(define testworld3 
  (new world% (send cannon1 dead-cannon) (list alien1) alien0 empty)) 
;; dead cannon

;; Other Tests -----------------------------------------------------------------

(check-expect (remove-dead (new world% cannon1 (list alien1) alien0
                                (list (new bullet% 
                                           SCENE-HALF-WIDTH
                                           (- SCENE-HEIGHT CANNON-HEIGHT) 
                                           BULLET-ALIEN-VELOCITY 'alien))))
              (new world% (send cannon1 dead-cannon) 
                   (list alien1) alien0 empty))

(check-expect (remove-dead (new world% 
                                cannon1
                                (list (new alien% 100 
                                           (- SCENE-HEIGHT CANNON-HEIGHT)
                                           ALIEN-VELOCITY 'alien1 TICK-START))
                                alien0
                                (list bullet1))) 
              (new world% cannon1 empty alien0 empty))

(check-expect (remove-dead (new world% 
                                cannon1 
                                (list (new alien% SCENE-HALF-WIDTH 
                                           (- SCENE-HEIGHT CANNON-HALF-HEIGHT)
                                           ALIEN-VELOCITY 'alien1 TICK-START))
                                alien0 empty))
              (new world% (send cannon1 dead-cannon) empty alien0 empty))

(check-expect (send (new world% cannon1 empty alien0 empty) on-key "left")
              (new world% (new cannon% 
                               (- SCENE-HALF-WIDTH CANNON-VELOCITY)
                               (- SCENE-HEIGHT CANNON-HALF-HEIGHT)
                               (- CANNON-VELOCITY) false)
                   empty
                   alien0
                   empty))

(check-expect (send (new world% cannon1 empty alien0 empty) on-key "right")
              (new world% (new cannon%
                               (+ SCENE-HALF-WIDTH CANNON-VELOCITY)
                               (- SCENE-HEIGHT CANNON-HALF-HEIGHT)
                               CANNON-VELOCITY false)
                   empty
                   alien0
                   empty))

(check-expect (send (new world% cannon1 empty alien0 empty) on-key " ")
              (new world% cannon1
                   empty
                   alien0
                   (list (new bullet% 
                              SCENE-HALF-WIDTH
                              (- SCENE-HEIGHT CANNON-HEIGHT)
                              BULLET-CANNON-VELOCITY 'cannon))))

(check-expect (send (new world% cannon1 empty alien0 empty) on-key "up")
              (new world% cannon1 empty alien0 empty))

(check-expect (remove-dead (new world% 
                                cannon1
                                (list alien1 
                                      (new alien% 100 100 ALIEN-VELOCITY 
                                           'alien1 10))
                                alien0
                                (list 
                                 bullet1 (new bullet% 100 100 10 'cannon))))
              (new world% cannon1 (list alien1) alien0 (list bullet1)))

(check-expect (remove-dead (new world%
                                cannon1
                                (list (new alien% 
                                           SCENE-HALF-WIDTH
                                           (- SCENE-HEIGHT CANNON-HALF-HEIGHT) 
                                           ALIEN-VELOCITY 
                                           'alien1 TICK-START))
                                alien0 empty))
              (new world% (new cannon% SCENE-HALF-WIDTH 
                               (- SCENE-HEIGHT CANNON-HALF-HEIGHT)
                               CANNON-VELOCITY true)
                   empty alien0 empty))

;; Big Bang --------------------------------------------------------------------

(big-bang initial-world)


;; Exercise 2.2: Ternary Trees ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define max-num max) ;; redefining the max function

;; A TernaryTree is one of
;; - TernaryNode
;; - TernaryLeaf
;; and implements:
;; size : -> Number
;; How many numbers are in the tree?
;; sum : -> Number
;; What is the sum of numbers in the tree?
;; prod : -> Number
;; What is the product of the numbers in the tree?
;; contains? : Number -> Boolean
;; Does the tree contain the number?
;; map : [Number -> Number] -> TernaryTree
;; Apply a function to all numbers in the tree
;; max : -> Number
;; What is the highest number in the tree?

;; A TernaryNode is a (new tern-node% Number TernaryTree TernaryTree TernaryTree)
(define-class tern-node%
  (fields value left middle right)
  
  ;; Template:
  #; (define (tern-node%-temp)
       (send this value)  ...
       (send this left)   ...
       (send this middle) ...
       (send this right)  ...)
  
  ;; size : -> Number
  ;; How many numbers are in the tree?
  (define (size)
    (+ 1
       (send (send this left) size)
       (send (send this middle) size)
       (send (send this right) size)))
  ;; Tests/Examples:
  (check-expect (send tree1 size) 4)
  (check-expect (send tree2 size) 10)
  
  ;; sum : -> Number
  ;; What is the sum of the numbers in the tree?
  (define (sum)
    (+ (send this value)
       (send (send this left) sum)
       (send (send this middle) sum)
       (send (send this right) sum)))
  ;; Tests/Examples:
  (check-expect (send tree1 sum) 10)
  (check-expect (send tree2 sum) 55)
  
  ;; prod : -> Number
  ;; What is the product of the numbers in the tree?
  (define (prod)
    (* (send this value)
       (send (send this left) prod)
       (send (send this middle) prod)
       (send (send this right) prod)))
  ;; Tests/Examples:
  (check-expect (send tree1 prod) 24)
  (check-expect (send tree2 prod) 3628800)
  
  ;; contains? : Number -> Boolean
  ;; Does the tree contain the number?
  (define (contains? num)
    (or (=(send this value) num)
        (send (send this left) contains? num)
        (send (send this middle) contains? num)
        (send (send this right) contains? num)))
  ;; Tests/Examples:
  (check-expect (send tree1 contains? 0) false)
  (check-expect (send tree1 contains? 1) true)
  (check-expect (send tree1 contains? 20) false)
  (check-expect (send tree1 contains? 1) true)
  
  ;; map : [Number -> Number] -> TernaryTree
  ;; Apply a function to all numbers in the tree
  (define (map func)
    (new tern-node%
         (func (send this value))
         (send (send this left) map func)
         (send (send this middle) map func)
         (send (send this right) map func)))
  ;; Tests/Examples:
  (check-expect (send tree1 map add1)
                (new tern-node%
                     2
                     (new tern-leaf% 3)
                     (new tern-leaf% 4)
                     (new tern-leaf% 5)))
  (check-expect (send tree1 map sub1)
                (new tern-node%
                     0
                     (new tern-leaf% 1)
                     (new tern-leaf% 2)
                     (new tern-leaf% 3)))
  (check-expect (send tree2 map add1)
                (new tern-node%
                     2
                     (new tern-node%
                          3
                          (new tern-leaf% 4)
                          (new tern-leaf% 5)
                          (new tern-leaf% 6))
                     (new tern-leaf% 7)
                     (new tern-node%
                          8
                          (new tern-leaf% 9)
                          (new tern-leaf% 10)
                          (new tern-leaf% 11))))
  (check-expect (send tree2 map sub1)
                (new tern-node%
                     0
                     (new tern-node%
                          1
                          (new tern-leaf% 2)
                          (new tern-leaf% 3)
                          (new tern-leaf% 4))
                     (new tern-leaf% 5)
                     (new tern-node%
                          6
                          (new tern-leaf% 7)
                          (new tern-leaf% 8)
                          (new tern-leaf% 9))))
  ;; max : -> Number
  ;; What is the highest number in the tree?
  (define (max)
    (max-num (send this value)
             (send (send this left) max)
             (send (send this middle) max)
             (send (send this right) max)))
  ;; Tests/Examples:
  (check-expect (send tree1 max) 4)
  (check-expect (send tree2 max) 10))


;; A TernaryLeaf is a (new tern-leaf% Number)
(define-class tern-leaf%
  (fields number)
  
  ;; Template:
  #; (define (tern-leaf%-temp)
       (send this number) ...)
  
  ;; size : -> Number
  ;; How many numbers are in the tree?
  (define (size)
    1)
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 0) size) 1)
  (check-expect (send (new tern-leaf% 2) size) 1)
  
  ;; sum : -> Number
  ;; What is the sum of the numbers in the tree?
  (define (sum)
    (send this number))
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 0) sum) 0)
  (check-expect (send (new tern-leaf% 2) sum) 2)
  
  ;; prod : -> Number
  ;; What is the product of the numbers in the tree?
  (define (prod)
    (send this number))
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 0) prod) 0)
  (check-expect (send (new tern-leaf% 2) prod) 2)
  
  ;; contains? : Number -> Boolean
  ;; Does the tree contain the number?
  (define (contains? num)
    (= num (send this number)))
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 3) contains? 3) true)
  (check-expect (send (new tern-leaf% 3) contains? 1) false)
  
  ;; map : [Number -> Number] -> ternaryTree
  ;; Apply a function to all numbers in the tree
  (define (map func)
    (new tern-leaf%
         (func (send this number))))
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 3) map add1)
                (new tern-leaf% 4))
  (check-expect (send (new tern-leaf% 3) map sub1)
                (new tern-leaf% 2))
  
  ;; max : -> Number
  ;; What is the highest number in the tree?
  (define (max)
    (send this number))
  ;; Tests/Examples:
  (check-expect (send (new tern-leaf% 0) max) 0)
  (check-expect (send (new tern-leaf% 2) max) 2))


;; Examples:
(define tree1 (new tern-node%
                   1
                   (new tern-leaf% 2)
                   (new tern-leaf% 3)
                   (new tern-leaf% 4)))
(define tree2 (new tern-node%
                   1
                   (new tern-node%
                        2
                        (new tern-leaf% 3)
                        (new tern-leaf% 4)
                        (new tern-leaf% 5))
                   (new tern-leaf% 6)
                   (new tern-node%
                        7
                        (new tern-leaf% 8)
                        (new tern-leaf% 9)
                        (new tern-leaf% 10))))