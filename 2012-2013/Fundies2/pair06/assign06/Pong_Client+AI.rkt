#lang class/1

(require racket/math)
(require 2htdp/image)
(require class/universe)

;; Constants
(define SCENE_W 800)
(define SCENE_H 500)
(define SCENE_W/2 (/ SCENE_W 2))
(define SCENE_H/2 (/ SCENE_H 2))
(define SCENE (scene+line (rectangle SCENE_W SCENE_H "solid" "black")
                          SCENE_W/2
                               0
                               SCENE_W/2
                               SCENE_H
                               (make-pen 'white
                                         5
                                         'long-dash
                                         'butt
                                         'miter)))

(define PADDLE_WIDTH 20)
(define PADDLE_HEIGHT 80)
(define PADDLE_WIDTH/2 (/ PADDLE_WIDTH 2))
(define PADDLE_HEIGHT/2 (/ PADDLE_HEIGHT 2))
(define PADDLE_X_BUFFER 40)
(define LEFT_PAD_START_POS
  (make-rectangular PADDLE_X_BUFFER
                    SCENE_H/2))
(define RIGHT_PAD_START_POS
  (make-rectangular (- SCENE_W
                       PADDLE_X_BUFFER)
                    SCENE_H/2))
(define PADDLE (rectangle PADDLE_WIDTH PADDLE_HEIGHT "solid" "white"))

(define BALL_RADIUS 10)
(define BALL (circle BALL_RADIUS "solid" "white"))
(define BALL_SPEED 10)
(define BALL_START_POS (make-rectangular SCENE_W/2
                                          SCENE_H/2))
(define MAX_BALL_ANGLE (inexact->exact
                        (round 
                         (radians->degrees
                          (atan (/ SCENE_W/2
                                   (- SCENE_H/2
                                      100)))))))

(define PLAYER_SPEED 5)


;; A ->client is a 
;; (make-mail iWorld (list Imaginary Imaginary Imaginary Number Number))
;; Interp:
;; - The first item, Imaginary is the coordinates of player 1
;; - The second item, Imaginary is the coordinates of player 2
;; - The third item, Imaginary is the coordinates of the Ball
;; - The fourth item, Number is the score of the receiving player
;; - The fifth item, Number is the score of the enemy player

;; A ->server is a
;; (make-package Client Direction)

;; A Direction is one of:
;; - "up"
;; - "down"

;; A Client is a:
;; (new client% Imaginary Imaginary Imaginary Number Number)
;; Interp:
;; - The first item, Imaginary is the position of player 1
;; - The second item, Imaginary is the position of player 2
;; - The third item, Imaginary is the position of the Ball
;; - The fourth item, Number is the player's score
;; - The fifth item, Number, is the enemy player's score

;; Clients send ->server to the server and recieve ->client from the server
;; Clients keep track of data sent in ->client in their classes for reference,
;; and the data Clients keep track of is refreshed every time clients receive 
;; a ->client

;; An IP is a String that is an ip address or hostname

(define-class client%
  (fields p1-posn p2-posn ball-posn p1-score p2-score server-ip)
  
  ;; Template:
  #;(define (client%-temp)
      (this . p1-posn)   ...
      (this . p2-posn)   ...
      (this . ball-posn) ...
      (this . p1-score)  ...
      (this . p2-score)  ...
      (this . server-ip) ...)
  
  ;; register : -> ???
  ;; registers the client with the server
  (define (register) (this . server-ip))
  
  
  
  
  ;; to-draw : -> Scene
  ;; Draws the Client
  (define (to-draw)
    (overlay/align 
     "left" "top"
     (text (number->string (this . p1-score)) 40 "white")
     (overlay/align 
      "right" "top"
      (text (number->string (this . p2-score)) 40 "white")
      (place-image 
       PADDLE (real-part (this . p1-posn)) (imag-part (this . p1-posn))
       (place-image
        PADDLE (real-part (this . p2-posn)) (imag-part (this . p2-posn))
        (place-image BALL (real-part (this . ball-posn)) 
                     (imag-part (this . ball-posn))
                     SCENE))))))
  ;; Examples/Tests
  (check-expect 
   (client-test . to-draw)
   (overlay/align 
    "left" "top" (text "0" 40 "white")
    (overlay/align 
     "right" "top" (text "0" 40 "white")
     (place-image
      PADDLE 40 250
      (place-image 
       PADDLE 760 250
       (place-image BALL 400 250 SCENE)))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  AI Player  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-class ai%
  (super client%)
  
  (define (tick-rate) (/ 1 5))
  
  ;; Template:
  #;(define (ai%-temp)
      (this . p1-posn)   ...
      (this . p2-posn)   ...
      (this . ball-posn) ...
      (this . p1-score)  ...
      (this . p2-score)  ...
      (this . server-ip) ...)
  
  ;; on-receive : ->client -> Client
  ;; Updates the data in the client with data from the server
  (define (on-receive msg)
    (new ai%
         (first msg)
         (second msg)
         (third msg)
         (fourth msg)
         (fifth msg)
         (this . server-ip)))
  ;; Examples/Tests:
  (check-expect (ai-test . on-receive '(40+250i 760+250i 400+250i 0 0))
                (new ai% 40+250i 760+250i 400+250i 0 0 "LOCALHOST"))
  (check-expect (ai-test . on-receive '(40+300i 760+100i 200+30i 1 2))
                (new ai% 40+300i 760+100i 200+30i 1 2 "LOCALHOST"))
    
    
  ;; on-tick : -> ->server OR client
  ;; moves the paddle towards the ball
  (define (on-tick)
    (cond
      [(or (< (imag-part (this . p1-posn))
              (imag-part (this . ball-posn))) 
           (< (imag-part (this . p2-posn))
              (imag-part (this . ball-posn))))
       (make-package this "down")]
       [(or (> (imag-part (this . p1-posn))
               (imag-part (this . ball-posn))) 
            (> (imag-part (this . p2-posn))
               (imag-part (this . ball-posn))))
        (make-package this "up")]
       [else this]))
  ;; Examples/Tests
  (check-expect 
   ((new ai% 40+250i 760+250i 400+100i 0 0 "LOCALHOST") . on-tick)
   (make-package 
    (new ai% 40+250i 760+250i 400+100i 0 0 "LOCALHOST") "up"))
  (check-expect 
   ((new ai% 40+250i 760+250i 400+300i 0 0 "LOCALHOST") . on-tick)
   (make-package 
    (new ai% 40+250i 760+250i 400+300i 0 0 "LOCALHOST") "down"))
  (check-expect 
   ((new ai% 40+250i 760+250i 400+250i 0 0 "LOCALHOST") . on-tick)
    (new ai% 40+250i 760+250i 400+250i 0 0 "LOCALHOST")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Human Player  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-class human%
  (super client%)
  
  ;; Template:
  #;(define (human%-temp)
      (this . p1-posn)   ...
      (this . p2-posn)   ...
      (this . ball-posn) ...
      (this . p1-score)  ...
      (this . p2-score)  ...
      (this . server-ip) ...)
  
  ;; on-receive : ->client -> Client
  ;; Updates the data in the client with data from the server
  (define (on-receive msg)
    (new human%
         (first msg)
         (second msg)
         (third msg)
         (fourth msg)
         (fifth msg)
         (this . server-ip)))
  ;; Examples/Tests:
  (check-expect (human-test . on-receive '(40+250i 760+250i 400+250i 0 0))
                (new human% 40+250i 760+250i 400+250i 0 0 "LOCALHOST"))
  (check-expect (human-test . on-receive '(40+300i 760+100i 200+30i 1 2))
                (new human% 40+300i 760+100i 200+30i 1 2 "LOCALHOST"))
  
  
  ;; on-key : KeyEvent -> ->server OR client
  ;; sends the keystroke to the server
  (define (on-key ke)
    (if (or (string=? ke "up") (string=? ke "down"))
        (make-package this ke)
        this))
  ;; Examples/Tests
  (check-expect (human-test . on-key "up")
                (make-package human-test "up"))
  (check-expect (human-test . on-key "down")
                (make-package human-test "down"))
  (check-expect (human-test . on-key "a")
                human-test))





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Testable Stuff + Helper Functions  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A Client at the beginning of the game to test with
(define client-test (new client% 40+250i 760+250i 400+250i 0 0 "LOCALHOST"))

(define human-test (new human% 40+250i 760+250i 400+250i 0 0 "LOCALHOST"))

(define ai-test (new ai% 40+250i 760+250i 400+250i 0 0 "LOCALHOST"))

;; new-client: IP -> Client
;; Creates a new client that tries to connect to the specified IP address
(define (new-human ip)
  (big-bang (new human% 40+250i 760+250i 400+250i 0 0 ip)))

;; new-ai: IP -> Client
;; Creates a new AI player that tries to connect to the specified IP address
(define (new-ai ip)
    (big-bang (new ai% 40+250i 760+250i 400+250i 0 0 ip)))
  
;; Exmaples/Tests
#;(check-expect (new-client "192.168.1.1")
              (new client% 40+250i 760+250i 400+250i 0 0 "192.168.1.1"))
#;(check-expect (new-client "10.0.0.1")
              (new client% 40+250i 760+250i 400+250i 0 0 "10.0.0.1"))
;; I would uncomment the tests, but doing so actually runs big-bang


;; Launches a single player game against the computer
(define (launch-single-player-game ip)
  (launch-many-worlds
   (new-human ip)
   (new-ai ip)))

;; Launches a two player game
;; (both players are on same computer
(define (launch-two-player-game ip)
  (launch-many-worlds
   (new-human ip)
   (new-human ip)))

;; Launches a game with two AI players
;; (sit back and relax as the computer playes an
;;  exciting and riveting game of pong against itself!)
(define (launch-ai-game ip)
  (launch-many-worlds
   (new-ai ip)
   (new-ai ip)))
  


