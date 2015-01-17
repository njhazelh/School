#lang class/2

(require 2htdp/image class/universe)

;;> Graded by Nicholas Labich <labichn@ccs.neu.edu>
;;> <140/150>

;;> What's with all the whitespace?

;; An Animation implements:
;; next : -> Animation
;; prev : -> Animation
;; render : -> Scene

(define WIDTH 200) ; Animation dimension in PX.
(define-class count-animation%
  (fields n)
  (define (next)
    (new count-animation% (add1 (send this n))))
  (define (prev)
    (new count-animation% (max 0 (sub1 (send this n)))))
  (define (render)
    (overlay (text (number->string (send this n)) (quotient WIDTH 4) "black")
             (empty-scene 200 200))))

;; A Player is one of:
;; - (new play-player% Animation)
;; - (new frame-player% Animation)
;; - (new ff-player% Animation)
;; - (new rw-player% Animation)

;; A Player responds to the following key-presses:
;; - "p" (plays the animation)
;; - "f" (fast forwards the animation)
;; - "r" (rewinds the animation)
;; - "s" (stops the animation)
;; and implements:
;;  tick-rate : -> Number
;;     Returns the rate of ticks
;;  on-key : KeyEvent -> Player
;;     Handles KeyEvents
;;  to-draw : -> Scene
;;     Renders the Player
;;  on-tick : -> Player
;;     Animation interaction with time.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Players  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;> Very nicely designed, but ^these huge comment blocks are just silly.
(define-class player%
  (fields anim)
  
  ;; player-temp
  ;; A template for the player class
  (define (player-temp)
    ((this . anim) ...))
  
  
  ;; A tick rate for animations.
  ;; Currently set at 1/4 for ease
  (define (tick-rate) 1/4)
  
  ;; on-key : KeyEvent -> Player
  ;; Makes a player based on which key is pressed
  (define (on-key ke)
    (cond
      [(string=? ke "p")
       (new play-player% (this . anim))]
      [(string=? ke "f")
       (new ff-player% (this . anim))]
      [(string=? ke "r")
       (new rw-player% (this . anim))]
      [(string=? ke "s")
       (new frame-player% (this . anim))]
      [else this]))
  ;; Examples/Tests
  (check-expect ((new play-player% COUNT_ANIM) . on-key "p")
                (new play-player% COUNT_ANIM))
  (check-expect ((new play-player% COUNT_ANIM) . on-key "f")
                (new ff-player% COUNT_ANIM))
  (check-expect ((new play-player% COUNT_ANIM) . on-key "r")
                (new rw-player% COUNT_ANIM))
  (check-expect ((new play-player% COUNT_ANIM) . on-key "s")
                (new frame-player% COUNT_ANIM))
  (check-expect ((new play-player% COUNT_ANIM) . on-key "g")
                (new play-player% COUNT_ANIM))
  
  
  ;; to-draw : -> Scene
  ;; Renders the animation
  (define (to-draw)
    (this . anim . render))
  ;; Examples/Tests
  (check-expect ((new player% COUNT_ANIM) . to-draw)
                (overlay (text (number->string 50) (quotient WIDTH 4) "black")
                         (empty-scene 200 200))))






;; A Player for when an animation is playing
(define-class play-player%
  (super player%)
  
  ;; on-tick : -> Player
  ;; Moves the animation forward
  (define (on-tick)
    (new play-player% ((this . anim) . next)))
  ;; Examples/Tests
  (check-expect ((new play-player% COUNT_ANIM) . on-tick)
                (new play-player% 
                     (new count-animation% 51))))






;; A Player of when the animation is fast-forwarding
(define-class ff-player%
  (super player%)
  
  ;; on-tick : -> Player
  ;; Moves the animation forward
  (define (on-tick)
    (new ff-player% ((this . anim) . next . next)))
  ;; Examples/Tests
  (check-expect ((new ff-player% COUNT_ANIM) . on-tick)
                (new ff-player% 
                     (new count-animation% 52))))






;; A Player for when the animation is rewinding
(define-class rw-player%
  (super player%)
  
  ;; on-tick : -> Player
  ;; Moves the animation forward
  (define (on-tick)
    (new rw-player% ((this . anim) . prev)))
  ;; Examples/Tests
  (check-expect ((new rw-player% COUNT_ANIM) . on-tick)
                (new rw-player% 
                     (new count-animation% 49))))





;; A Player for when the animation is stopped
(define-class frame-player%
  (super player%)
  
  ;; on-tick : -> Player
  ;; Moves the animation forward
  (define (on-tick) this)
  ;; Examples/Tests
  (check-expect ((new frame-player% COUNT_ANIM) . on-tick)
                (new frame-player% 
                     (new count-animation% 50))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Animations  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; If the animation consists of a [Listof Scene]
;; then the new animation is a:
;; (new list-anim% empty [Listof Scene])

;; If the animation consists of a function that takes a number,
;; then the new animation is a:
;; (new func-anim% [Number -> Scene] Number)

;; If the animation consists of a World
;; then the new animation is a:
;; (new list-anim empty empty World)

;; COPIED FOR EASE:
;; An Animation implements:
;; next : -> Animation
;; prev : -> Animation
;; render : -> Scene


;; An Animation for functions
(define-class func-anim%
  (fields f n)
  
  ;; func-anim-temp 
  ;; Template for func-anim%
  #;(define (func-anim-temp)
      ((this . f) ...)
      ((this . n) ...))
  
  
  ;; render : -> Scene
  ;; Renders the scene of the animation
  (define (render)
    ((this . f) (this . n)))
  ;; Examples/Tests
  (check-expect 
   ((new func-anim% (lambda (i) (overlay (text (number->string i) 50 "black")
                                         (empty-scene 200 200))) 50) . render)
   (overlay (text (number->string 50) 50 "black")
            (empty-scene 200 200)))
  
  ;; next : -> Animation
  ;; The next scene in the animation
  (define (next)
    (new func-anim% (this . f) (add1 (this . n))))
  ;; Examples/Tests
  (check-expect (((new func-anim% 
                       (lambda (i) (overlay (text (number->string i) 50 "black")
                                            (empty-scene 200 200))) 50) . next) . render)
                (overlay (text (number->string 51) 50 "black")
                         (empty-scene 200 200)))
  
  ;; prev : -> Animation
  ;; The previous scene in the animation
  (define (prev)
    (new func-anim% (this . f) (sub1 (this . n))))
  ;; Examples/Tests
  (check-expect (((new func-anim% 
                       (lambda (i) (overlay (text (number->string i) 50 "black")
                                            (empty-scene 200 200))) 50) . prev) . render)
                (overlay (text (number->string 49) 50 "black")
                         (empty-scene 200 200))))




;; An Animation for [Listof Scene]
(define-class list-anim%
  (fields prevs rests)
  
  ;; list-anim-temp 
  ;; Template for list-anim%
  #;(define (list-anim-temp)
      ((this . prevs) ...)
      ((this . rests) ...))
  
  ;; render : -> Scene
  ;; Renders the scene of the animation
  (define (render)
    (first (this . rests)))
  ;; Examples/Tests
  (check-expect 
   ((new list-anim% empty
         (build-list 50 (lambda (i) 
                          (overlay (text (number->string i)  50 "black")
                                   (empty-scene 200 200))))) . rests)
   (build-list 50 (lambda (i) (overlay (text (number->string i) 50 "black")
                                       (empty-scene 200 200)))))
  
  
  ;; next : -> Animation
  ;; The next scene in the animation
  (define (next)
    (cond
      [(empty? (this . rests)) (new list-anim% (rest (this . prevs))
                                    (cons (first (this . prevs)) 
                                          (this . rests)))]
      [(empty? (rest (this . rests))) this]
      [else (new list-anim% (cons (first (this . rests)) (this . prevs))
                 (rest (this . rests)))]))
  ;; Examples/Tests
  (check-expect 
   ((new list-anim% empty
         (build-list 50 (lambda (i) 
                          (overlay (text (number->string i)  50 "black")
                                   (empty-scene 200 200))))) . next)
   (new list-anim% (list (overlay (text (number->string 0) 50 "black")
                                  (empty-scene 200 200)))
        (rest (build-list 50 (lambda (i) 
                               (overlay (text (number->string i)  50 "black")
                                        (empty-scene 200 200)))))))
  
  
  ;; prev : -> Animation
  ;; The previous scene in the animation
  (define (prev)
    (if
     (empty? (this . prevs)) 
     this
     (new list-anim% (rest (this . prevs)) (cons (first (this . prevs))
                                                 (this . rests)))))
  ;; Examples/Tests
  (check-expect 
   ((new list-anim% empty
         (build-list 50 (lambda (i) 
                          (overlay (text (number->string i)  50 "black")
                                   (empty-scene 200 200))))) . prev)
   (new list-anim% empty 
        (build-list 50 (lambda (i) 
                         (overlay (text (number->string i)  50 "black")
                                  (empty-scene 200 200))))))
  (check-expect ((new list-anim% (list (empty-scene 200 200))
                      (list (rectangle 200 200 'solid 'red))) . prev)
                (new list-anim% empty 
                     (list (empty-scene 200 200)
                           (rectangle 200 200 'solid 'red)))))






;; An Animation for Worlds
(define-class wrap-anim%
  (fields prevs rests world)
  
  
  ;; wrap-anim-temp 
  ;; Template for wrap-anim%
  #;(define (wrap-anim-temp)
      ((this . prevs) ...)
      ((this . rests) ...)
      ((this . world) ...))
  
  ;; render : -> Scene
  ;; Renders the scene of the animation
  (define (render)
    (cond
      [(not (empty? (this . rests)))
       (first (this . rests))]
      [else 
       (this . world . to-draw)]))
  ;; Examples/Tests
  (check-expect (WRAP_ANIM . render)
                (overlay (text "50" 50 'black)
                         (empty-scene 200 200)))
  (check-expect (WRAP_ANIM . next . next . prev . render)
                (overlay (text "51" 50 'black)
                         (empty-scene 200 200)))
  
  
  ;; next : -> Animation
  ;; The next scene in the animation
  (define (next)
    (cond
      [(not (empty? (this . rests)))
       (new wrap-anim% (cons (first (this . rests)) (this . prevs))
            (rest (this . rests)) (this . world))]
      [else (new wrap-anim% (cons (this . world . to-draw)
                                  (this . prevs)) empty (this . world . on-tick))]))
  ;; Examples/Tests
  (check-expect (WRAP_ANIM . next . render)
                (overlay (text "51" 50 'black)
                         (empty-scene 200 200)))
  (check-expect (WRAP_ANIM . next . next . prev . next . render)
                (overlay (text "52" 50 'black)
                         (empty-scene 200 200)))
  
  
  ;; prev : -> Scene
  ;; the previous scene in the animation
  ;; NOTE: A wrapped world cannot rewind past the initial world.
  ;; As far as I know, there is no way to reverse the on-tick function
;;> Of course, that would just be insanity otherwise!
  (define (prev)
    (cond
      [(empty? (this . prevs)) this]
      [else (new wrap-anim% (rest (this .  prevs))
                 (cons (first (this . prevs)) (this . rests))
                 (this . world))]))
  ;; Examples/Tests
  (check-expect (WRAP_ANIM . prev . render)
                (overlay (text "50" 50 'black)
                         (empty-scene 200 200)))
  (check-expect (WRAP_ANIM . next . next . prev . render)
                (overlay (text "51" 50 'black)
                         (empty-scene 200 200))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Constants & Tests  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; A list-anim% for testing
(define LIST_COUNT_ANIM 
  (new list-anim% empty
       (build-list 50 (lambda (i) (overlay (text (number->string i) 50 "black")
                                           (empty-scene 200 200))))))
;;> Guess what happens if the second list is empty? <-10>

;; A count-animation% for testing
(define COUNT_ANIM (new count-animation% 50))

;; A func-anim% for testing
(define FUNC_ANIM (new func-anim% 
                       (lambda (i) (overlay (text (number->string i) 50 "black")
                                            (empty-scene 200 200)))
                       25))



;; A wrap-anim% for testing
(define WRAP_ANIM (new wrap-anim% empty empty
                       (new play-player% COUNT_ANIM)))

;; An example of an Animation of an Animation
(define (anim-of-anim anim)
  (big-bang (new play-player% (new wrap-anim% empty empty
                                   (new play-player% anim)))))
;; (ANIMATION-CEPTION!!!! :D )

;; Starts a player with the goven animation
(define (start-animation anim)
  (big-bang (new frame-player% anim)))