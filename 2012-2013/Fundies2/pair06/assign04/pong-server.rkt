#lang class/1

(require racket/math)
(require class/universe)

;; Constants
(define SCENE_W 800)
(define SCENE_H 500)
(define SCENE_W/2 (/ SCENE_W 2))
(define SCENE_H/2 (/ SCENE_H 2))

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

(define BALL_RADIUS 10)
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

;; Clients send ->server to the server and recieve ->client from the server
;; Clients keep track of data sent in ->client in their classes for reference,
;; and the data Clients keep track of is refreshed every time clients receive 
;; a ->client


;; A Player is a:
;; (new player% iWorld Imaginary Number)
;; Interp:
;; - The iWorld is the connection to the Client
;; - The Imaginary is the postition of the player
;; = The Number is the score of the player


;; A Full-Serv is a server with two connections and is is a:
;; (new game-server% Player Player Ball)
;; Interp:
;; The first Player is Player 1
;; the second player is player 2

;; A 0-Serv is a server with no connections and is a:
;; (new no-connect%)

;; A 1-Serv is a server with one connection and is a:
;; (new one-connect% Player)

;; A Ball is a:
;; (new ball% Imaginary Imaginary)
;; Interp:
;; - The first item, Imaginary is the position of the Ball
;; - The second item, Imaginary is the velocity of the Ball

(define-class player%
  (fields iworld position score)
  
  ;; Template:
  #; (define (player%-temp)
       (this . iworld) ...
       (this . position) ...
       (this . score) ...)
  
  
  ;; move-player : String -> Player
  ;; Moves the player according to the String
  (define (move-player dir)
    (cond
      [(string=? dir "up")
       (new player% (this . iworld) 
            (make-rectangular (real-part (this . position))
                              (max PADDLE_HEIGHT/2
                                   (- (imag-part (this . position))
                                      PLAYER_SPEED)))
            (this . score))]
      [(string=? dir "down")
       (new player% (this . iworld) 
            (make-rectangular (real-part (this . position))
                              (min (- SCENE_H
                                      PADDLE_HEIGHT/2)
                                   (+ (imag-part (this . position))
                                      PLAYER_SPEED)))
            (this . score))]
      [else this]))
  ;; Examples/Tests
  (check-expect (p1-test . move-player "up")
                (new player% iworld1 40+245i 0))
  (check-expect (p1-test . move-player "down")
                (new player% iworld1 40+255i 0))
  (check-expect (p2-test . move-player "a") p2-test)
  
  
  ;; add-score : -> Player
  ;; Adds one to the score of the player
  (define (add-score)
    (new player% (this . iworld) (this . position) (add1 (this . score))))
  ;; Examples/Tests
  (check-expect (p1-test . add-score) (new player% iworld1 40+250i 1))
  (check-expect (p2-test . add-score) (new player% iworld2 760+250i 1)))


(define-class no-connect%
  
  ;; Template:
  #; (define (no-connect%-temp)
       ...)
  
  
  ;; on-tick : -> 0-Serv
  ;; Place-holder to make sure that on-tick is
  ;; called later. It's a weird bug in the language.
  (define (on-tick)
    this)
  ;; Examples/Tests:
  (check-expect ((new no-connect%) . on-tick)
                (new no-connect%))
  
  
  
  ;; on-new : iWorld -> 1-Serv
  ;; Produces a One-connect with the iWorld
  (define (on-new iw)
    (new one-connect% (new player% iw LEFT_PAD_START_POS 0)))
  ;; Examples/Tests
  (check-expect ((new no-connect%) . on-new iworld1)
                (new one-connect% p1-test))
  (check-expect ((new no-connect%) . on-new iworld2)
                (new one-connect% (new player%
                                       iworld2
                                       LEFT_PAD_START_POS
                                       0))))




(define-class one-connect%
  (fields player1)
  
  ;; Template:
  #; (define (one-connect%-temp)
       (this . player1) ...)
  
  
  ;; on-tick : -> 1-Serv
  ;; Place-holder to make sure that on-tick is
  ;; called later. It's a weird bug in the language.
  (define (on-tick)
    this)
  ;; Examples/Tests:
  (check-expect ((new one-connect% p1-test) . on-tick)
                (new one-connect% p1-test))
  (check-expect ((new one-connect% p2-test) . on-tick)
                (new one-connect% p2-test))
  
  
  
  ;; on-new : iWorld -> Full-Serv
  ;; Produces a Game-Server with the iWorld given as player 2
  (define (on-new iw)
    (new game-server%
         (this . player1)
         (new player% iw RIGHT_PAD_START_POS 0)
         (new ball% BALL_START_POS 5+5i)))
  ;;Examples/Tests
  (check-expect ((new one-connect% p1-test) . on-new iworld2)
                (new game-server% p1-test p2-test ball-test))
  (check-expect ((new one-connect% p1-test) . on-new iworld3)
                (new game-server% p1-test p3-test ball-test)))




(define-class game-server%
  (fields player1 player2 ball)
  
  ;; Template:
  #; (define (game-server%-temp)
       (this . player1) ...
       (this . player2) ...
       (this . ball)    ...)
  
  
  ;; on-msg : ->server -> Bundle
  ;; makes the updates player positions based on the message sent
  (define (on-msg iw msg)
    (if (iworld=? (this . player1 . iworld) iw) ;; if player1, move player 1
        (make-bundle 
         (new game-server%
              (this . player1 . move-player msg) (this . player2) 
              (this . ball))
         (list (make-mail (this . player1 . iworld)
                          (this . game-status))
               (make-mail (this . player2 . iworld)
                          (this . game-status)))
         empty)
        (make-bundle  ;; else move player 2
         (new game-server% 
              (this . player1)
              (this . player2 . move-player msg)
              (this . ball))
         (list (make-mail (this . player1 . iworld)
                          (this . game-status))
               (make-mail (this . player2 . iworld)
                          (this . game-status)))
         empty)))
  ;; Exmaples/Tests
  (check-expect 
   (test-server . on-msg iworld1 "up")
   (make-bundle
    (new game-server% (new player% iworld1 40+245i 0) p2-test ball-test)
    (list (make-mail iworld1 '(40+250i 760+250i 400+250i 0 0)) 
          (make-mail iworld2 '(40+250i 760+250i 400+250i 0 0))) empty))
  (check-expect (test-server . on-msg iworld2 "down")
                (make-bundle (new game-server%
                                  p1-test 
                                  (new player%
                                       iworld2
                                       760+255i
                                       0)
                                  ball-test)
                             (list (make-mail iworld1 '(40+250i
                                                        760+250i
                                                        400+250i
                                                        0
                                                        0)) 
                                   (make-mail iworld2 '(40+250i
                                                        760+250i
                                                        400+250i
                                                        0
                                                        0)))
                             empty))
  
  
  ;; on-tick : -> Bundle
  ;; Move the ball and send to clients
  ;; This should work, but for some reason it's not running.
  (define (on-tick)
    (local ((define new-server 
              (new game-server%
                   (this . player1)
                   (this . player2)
                   (if
                    (or (this . ball . paddle-hit? (this . player1))
                        (this . ball . paddle-hit? (this . player2)))
                    (this . ball . paddle-bounce)
                    (this . ball . move)))))
      (make-bundle (new-server . score-counter)
                   (list (make-mail (new-server . player1 . iworld)
                                    (new-server . game-status))
                         (make-mail (new-server . player2 . iworld)
                                    (new-server . game-status)))
                   empty)))
  ;; Examples/Tests:
  (check-expect 
   (test-server . on-tick)
   (make-bundle
    (new game-server% (new player% iworld1 40+250i 0)
         (new player% iworld2 760+250i 0)
         (new ball% 405+255i 5+5i))
    (list (make-mail iworld1 '(40+250i 760+250i 405+255i 0 0)) 
          (make-mail iworld2 '(40+250i 760+250i 405+255i 0 0))) empty))
  
  
  ;; game-status : -> ->client
  ;; makes a ->client of the current game
  (define (game-status)
    (list (this . player1 . position)
          (this . player2 . position)
          (this . ball . position)
          (this . player1 . score)
          (this . player2 . score)))
  ;; Examples/Tests
  (check-expect (test-server . game-status)
                (list 40+250i 760+250i 400+250i 0 0))
  
  
  
  ;; score-counter: -> World
  ;; Counts the scores and puts the ball back in the middle
  (define (score-counter)
    (cond
      [(< (real-part (this . ball . position)) 0)
       (new game-server%
            (this . player1)
            (this . player2 . add-score)
            (this . ball . new-ball))]
      [(> (real-part (this . ball . position)) SCENE_W)
       (new game-server%
            (this . player1 . add-score)
            (this . player2)
            (this . ball . new-ball))]
      [else this]))
  ;; Examples/Tests
  (check-expect (test-server . score-counter)
                (new game-server% p1-test 
                     p2-test ball-test))
  (check-within ((new game-server% p1-test 
                      p2-test 
                      (new ball% -10+250i 5+5i)) . score-counter)
                (new game-server% p1-test
                     (new player% iworld2 760+250i 1)
                     (new ball% 400+250i 1+1i)) 20)
  (check-within ((new game-server% p1-test 
                      p2-test 
                      (new ball% 900+250i 5+5i)) . score-counter)
                (new game-server% (new player% iworld1 40+250i 1)
                     p2-test
                     (new ball% 400+250i 1+1i)) 20))


(define-class ball%
  (fields position velocity)
  
  ;; Template:
  #; (define (ball%-temp)
       (this . position) ...
       (this . velocity) ...)
  
  
  ;; new-ball : -> Ball
  ;; Creates a new Ball going a random direction
  (define (new-ball)
    (local ((define angle (degrees->radians (random MAX_BALL_ANGLE))))
           (new ball% 
                BALL_START_POS
                (make-rectangular (* (expt -1 (random 2))
                                     BALL_SPEED
                                     (cos angle))
                                  (* (expt -1 (random 2)) 
                                     BALL_SPEED
                                     (sin angle))))))
  ;; Examples/Tests:
  (check-within ((new ball% 0 0) . new-ball)
                (new ball% BALL_START_POS 0) 20)
  (check-within ((new ball% 90+34i 1000+4i) . new-ball)
                (new ball% BALL_START_POS 0) 20)
                
                
    
  ;; move -> Ball
  ;; moves the ball
  (define (move)
    (cond
      [(this . wall-hit?) (this . wall-bounce)]
      [else 
       (new ball% (+ (this . position) (this . velocity)) (this . velocity))]))
  ;; Examples/Tests
  (check-expect (ball-test . move) (new ball% 405+255i 5+5i))
  (check-expect ((new ball% 250+2i 5+5i) . move)
                (new ball% 255-3i 5-5i))
  
  
  
  ;; wall-hit? : -> Ball
  ;; is the ball hitting a wall?
  (define (wall-hit?)
    (or 
     (<= (- (imag-part (this . position)) BALL_RADIUS) 0)
     (>= (+ (imag-part (this . position)) BALL_RADIUS) 
         SCENE_H)))
  ;; Examples/Tests
  (check-expect ((new ball% 250+0i 5-12i) . wall-hit?) #t)
  (check-expect ((new ball% (make-rectangular 250 SCENE_H) 5+5i)
                 . wall-hit?) #t)
  (check-expect (ball-test . wall-hit?) #f)
  
  
  
  ;; wall-bounce : -> Ball
  ;; bounces the ball off the wall
  (define (wall-bounce)
    (new ball% (+ (this . position)
                  (make-rectangular (real-part (this . velocity))
                                    (- 0 (imag-part (this . velocity)))))
         (make-rectangular (real-part (this . velocity))
                           (- 0 (imag-part (this . velocity))))))
  ;; Examples/Tests
  (check-expect (ball-test . wall-bounce) (new ball% 405+245i 5-5i))
  (check-expect ((new ball% 250+250i 5-5i) . wall-bounce)
                (new ball% 255+255i 5+5i))
  

  ;; paddle-hit? : Player -> Boolean
  ;; is the ball hitting a paddle?
  (define (paddle-hit? player)
    (and (or (and (negative? (real-part (this . velocity)))
                  (negative? (- (real-part (this . position)) SCENE_W/2)))
             (and (positive? (real-part (this . velocity)))
                  (positive? (- (real-part (this . position)) SCENE_W/2))))
     (<= (- (imag-part (this . position)) BALL_RADIUS)
         (+ (imag-part (player . position)) PADDLE_HEIGHT/2))
     (>= (+ (imag-part (this . position)) BALL_RADIUS)
         (- (imag-part (player . position)) PADDLE_HEIGHT/2))
     (<= (- (real-part (this . position)) BALL_RADIUS)
         (+ (real-part (player . position)) PADDLE_WIDTH/2))
     (>= (+ (real-part (this . position)) BALL_RADIUS)
         (- (real-part (player . position)) PADDLE_WIDTH/2))))
  ;; Examples/Tests
  (check-expect (ball-test . paddle-hit? p1-test) #f)
  (check-expect ((new ball% 40+250i -5+5i) . paddle-hit? p1-test) #t)
  (check-expect ((new ball% 100+250i -5+5i) . paddle-hit? p1-test) #f)
  (check-expect ((new ball% 100+250i -5+5i) . paddle-hit? p2-test) #f)

  
  
  ;; paddle-bounce : -> Ball
  ;; Bounces the ball off a paddle
  (define (paddle-bounce)
    (new ball% (+ (this . position)
                  (make-rectangular (- 0 (real-part (this . velocity)))
                                    (imag-part (this . velocity))))
         (make-rectangular 
          (if (> (magnitude (if (> (- 0 (real-part (this . velocity))) 0)
                                (add1 (- 0 (real-part (this . velocity))))
                                (sub1 (- 0 (real-part (this . velocity)))))) 20)
              (- 0 (real-part (this . velocity)))
              (if (> (- 0 (real-part (this . velocity))) 0)
                  (add1 (- 0 (real-part (this . velocity))))
                  (sub1 (- 0 (real-part (this . velocity))))))
          (imag-part (this . velocity)))))
  ;; Examples/Tests
  (check-expect (ball-test . paddle-bounce)
                (new ball% 395+255i -6+5i))
  (check-expect ((new ball% 400+250i -5+5i) . paddle-bounce)
                (new ball% 405+255i 6+5i)))

(define p1-test (new player% iworld1 40+250i 0))
(define p2-test (new player% iworld2 760+250i 0))
(define p3-test (new player% iworld3 760+250i 0))
(define ball-test (new ball% 400+250i 5+5i))

(define test-server
  (new game-server% p1-test p2-test ball-test))

(define (run-server)
  (universe (new no-connect%)))
(run-server)

;;> Very nice code and design.
