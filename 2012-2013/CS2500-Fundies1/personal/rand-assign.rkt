;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname rand-assign) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require 2htdp/image)
(require 2htdp/universe)

;; FILL THIS LIST WITH PARTICIPATING PEOPLE
(define LIST_OF_PEOPLE (list "a" "b" "c" "d"))


;; IMAGE CONSTANT
(define BACKGROUND (overlay (rectangle 400 400 'solid 'white)
                            (empty-scene 400 400)))


;; STRUCTURE DEFINTIONS
(define-struct assignment (giver reciever))
;; An Assignment is a (make-assignment String String)

(define-struct world (assignment role current-name))
;; A World is a (make-world Number Symbol String)

;; random-assign: [Listof String] -> [Listof Assignment]
;; Randomly pairs the different strings together into assignments
(define (random-assign lst)
  (local ((define (random-assign.acc givers recievers assignments)
            (cond [(= 1 (length givers))
                   (append  assignments
                            (list (make-assignment (first givers)
                                                   (first recievers))))]
                  [else (local ((define list-no-giver (remove (first givers) recievers))
                                (define rand (random (length list-no-giver)))
                                (define reciever (list-ref list-no-giver rand))
                                (define new-recievers (remove reciever recievers)))
                          (random-assign.acc (rest givers)
                                             new-recievers
                                             (append  assignments
                                                      (list (make-assignment (first givers)
                                                                             reciever)
                                                            ))))])))
    (random-assign.acc lst lst empty)))
;; Test/Examples:
;;(random-assign (list 1 2 3 4 5 6 7 8 9 10 11 12 13))

;; Assign members
(define ASSIGNMENTS (random-assign LIST_OF_PEOPLE))


;; key : World KeyEvent -> World
;; advances the world one step
(define (key w key)
  (if (symbol=? (world-role w)
                'giver)
      (make-world (world-assignment w)
                  'reciever
                  (string-append "Reciever: "
                                 (assignment-reciever (list-ref ASSIGNMENTS
                                                                (world-assignment w)))))
      (make-world (min (sub1 (length ASSIGNMENTS))
                       (add1 (world-assignment w)))
                  'giver
                  (string-append "Giver: "
                                 (assignment-giver (list-ref ASSIGNMENTS
                                                             (min (sub1 (length ASSIGNMENTS))
                                                                  (add1 (world-assignment w)))))))))

;; draw : World -> Scene
;; Renders the Scene
(define (draw w)
  (overlay (text (world-current-name w)
                 40
                 'black)
           BACKGROUND))


;; BIG BANG!
(big-bang (make-world -1 'reciever "Any Key to Begin")
          (on-key key)
          (to-draw draw))



