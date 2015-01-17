#lang class/1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A Mobile is one of
;; - MobileTree
;; - MobileLeaf
;; and implements
;; total-weight: -> Number
;; height: -> Number

;; A MobileTree is a (new mtree% Number Mobile Mobile)
(define-class mtree%
  (fields length left right)
  
  ;; total-weight: -> Number
  ;; the total weight of both sides
  (define (total-weight)
    (+ (this . left  . total-weight)
       (this . right . total-weight)))
  ;; Tests/Examples:
  (check-expect (mobile1 . total-weight) 115)
  (check-expect (mobile2 . total-weight) 100)
  (check-expect (mobile3 . total-weight) 15)
  
  ;; height: -> Number
  ;; the height of the longer side
  (define (height)
    (+ (this . length)
       (max (this . left  . height)
            (this . right . height))))
  ;; Tests/Examples:
  (check-expect (mobile1 . height) 7)
  (check-expect (mobile2 . height) 3)
  (check-expect (mobile3 . height) 12))

;; A MobileLeaf is a (new %mleaf Number Number Color)
(define-class mleaf%
  (fields height total-weight color))

;; Example:
(define mobile1 (new mtree%
                     1
                     (new mleaf% 1 60 'blue)
                     (new mtree%
                          2
                          (new mtree%
                               2
                               (new mleaf% 1 10 'green)
                               (new mleaf% 2 5 'red))
                          (new mleaf% 1 40 'red))))
(define mobile2 (new mleaf% 3 100 'black))
(define mobile3 (new mtree%
                     10
                     (new mleaf% 2 10 'orange)
                     (new mleaf% 1 5  'pink)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; Lists ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; An ILoE implements
;; Is the list empty?
;; empty? : -> Boolean
;; append : ILoE -> ILoE


;; A ConsLoE is a (new consLoE% Emp ILoE)
(define-class consLoE%
  (fields first rest)
  
  ;; empty? : -> Boolean
  ;; It's not an empty class
  (define (empty?)
    false)
  ;; Tests/Examples:
  (check-expect (list4 . empty?) false)
  (check-expect (list3 . empty?) false)
  (check-expect (list2 . empty?) false)
  
  ;; append : ILoE -> ILoE
  ;; Stick the elements of this given list
  ;; on the end of this one.
  (define (append list)
    (cond [(list . empty?) this]
          [else (new consLoE%
                     (this . first)
                     (this . rest . append list))]))
  ;; Tests/Examples:
  (check-expect (list1 . append list2) list2)
  (check-expect (list2 . append list3)
                (new consLoE%
                     (new worker% "Bob" 5)
                     (new consLoE%
                          (new worker% "Frank" 2)
                          (new consLoE% (new boss%
                                             "Ralph"
                                             "U.N.I.T."
                                             1
                                             list2)
                               list1)))))




;; A MtLoE is a (new mtLoE%)
(define-class mtLoE%
  
  ;; empty? : -> Boolean
  ;; It's an empty list
  (define (empty?)
    true)
  ;; Tests/Examples
  (check-expect (list1 . empty?) true)
  
  ;; append : ILoE -> ILoE
  ;; Append a list to this empty list
  ;; by returning the given list
  (define (append list)
    list)
  (check-expect (list1 . append list2) list2)
  (check-expect (list1 . append list3) list3)
  (check-expect (list1 . append list4) list4))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; Employees ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; An Emp implements
;; name  : -> String
;; tasks : -> Number
;; count-subs : -> Number
;; full-unit : -> ILoE
;; has-peon? : String -> Boolean

;; A Boss is a (new boss% String String Number ILoE)
(define-class boss%
  (fields name unit tasks peons)
  
  ;; count-subs : -> Number
  ;; How many subordinates does this boss have?
  (define (count-subs)
    (local ((define (count-subs list)
              (cond [(list . empty?) 0]
                    [else (+ 1
                             (list . first . count-subs)
                             (count-subs (list . rest)))])))
      (count-subs (this . peons))))
  ;; Tests/Examples:
  (check-expect (emp4 . count-subs) 1)
  (check-expect (emp5 . count-subs) 5)
  
  ;; full-unit : -> ILoE
  ;; A complete list of this boss' subordinates
  (define (full-unit)
    (local ((define (full-unit list)
              (cond [(list . empty?) (new mtLoE%)]
                    [else ((new consLoE%
                                (list . first)
                                (new mtLoE%))
                           . append
                           ((list . first . full-unit)
                            . append
                            (full-unit (list . rest))))])))
      (full-unit (this . peons))))
  ;; Tests/Examples:
  (check-expect (emp4 . full-unit) (new consLoE% emp1
                                        (new mtLoE%)))
  (check-expect (emp5 . full-unit) (new consLoE% emp1
                                        (new consLoE% emp2
                                             (new consLoE% emp3
                                                  (new consLoE% emp4
                                                       (new consLoE% emp1
                                                            (new mtLoE%)))))))
  
  ;; has-peon? : String -> Boolean
  ;; Does this employee have a subordinate with the given name?
  (define (has-peon? peon-name)
    (local ((define (has-peon? list)
              (and (not (list . empty?))
                   (or (string=? (list . first . name) peon-name)
                       (list . first . has-peon? peon-name)
                       (has-peon? (list . rest))))))
      (has-peon? (this . peons))))
  ;; Tests/Examples:
  (check-expect (emp4 . has-peon? "Bob") true)
  (check-expect (emp4 . has-peon? "Ben") false)
  (check-expect (emp5 . has-peon? "Bob") true)
  (check-expect (emp5 . has-peon? "Tommy") false))



;; A Worker is a (new worker% String Number)
(define-class worker%
  (fields name tasks)
  
  ;; count-subs : -> Number
  ;; How many subordinates does this boss have?
  (define (count-subs)
    0)
  ;; Tests/Examples:
  (check-expect (emp1 . count-subs) 0)
  (check-expect (emp2 . count-subs) 0)
  (check-expect (emp3 . count-subs) 0)
  
  ;; full-unit : -> ILoE
  ;; A complete list of this boss' subordinates
  (define (full-unit)
    (new mtLoE%))
  ;; Tests/Examples:
  (check-expect (emp1 . full-unit) (new mtLoE%))
  (check-expect (emp2 . full-unit) (new mtLoE%))
  (check-expect (emp3 . full-unit) (new mtLoE%))
  
  ;; has-peon? : String -> Boolean
  ;; Does this employee have a subordinate with the given name?
  (define (has-peon? peon-name)
    false)
  ;; Tests/Examples:
  (check-expect (emp1 . has-peon? "x") false)
  (check-expect (emp2 . has-peon? "x") false)
  (check-expect (emp3 . has-peon? "x") false))

;; Example data:

;; Lists
(define list1 (new mtLoE%))
(define list2 (new consLoE%
                   (new worker% "Bob" 5)
                   (new consLoE%
                        (new worker% "Frank" 2)
                        (new mtLoE%))))
(define list3 (new consLoE%
                   (new boss%
                        "Ralph"
                        "U.N.I.T."
                        1
                        list2)
                   list1))
(define list4 (new consLoE%
                   (new worker% "Tom" 8)
                   list3))

;; Employees:
(define emp1 (new worker% "Bob" 2))
(define emp2 (new worker% "Ben" 4))
(define emp3 (new worker% "Ralph" 10))
(define emp4 (new boss%
                  "Tom"
                  "UNIT"
                  4
                  (new consLoE% emp1
                       (new mtLoE%))))
(define emp5 (new boss%
                  "Tim"
                  "B"
                  9
                  (new consLoE% emp1
                       (new consLoE% emp2
                            (new consLoE% emp3
                                 (new consLoE% emp4
                                      (new mtLoE%)))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A FootballPossesion implements
;; The total offense scored by the team with the ball first.
;; - total-offense : -> Number
;; The total points scored in the game.
;; - total-score : -> Number
;; The next possesion.
;; - next -> FootballPossesion

;; A End is a (new end%)
(define-class end%
  
  ;; total-offense : -> Number
  ;; Total points scored by the offense
  (define (total-offense)
    0)
  ;; Tests/Examples:
  (check-expect (game1 . total-offense) 0)
  
  
  ;; total-score : -> Number
  ;; Total points score by both teams.
  (define (total-score)
    0)
  ;; Tests/Examples:
  (check-expect (game1 . total-score) 0)
  
  
  ;; next : -> End
  ;; returns this end again.
  (define (next)
    this)
  ;; Tests/Examples:
  (check-expect (game1 . next) game1))





;; A Possesion is a (new possesion% Number Number)
(define-class possesion%
  (fields start end points next)
  
  ;; total-offense : -> Number
  ;; Total score of the offense
  (define (total-offense)
    (+ (this . points)
       (this . next . next . total-offense)))
  ;; Tests/Examples:
  (check-expect (game2 . total-offense) 7)
  (check-expect (game3 . total-offense) 0)
  (check-expect (game4 . total-offense) 17)
  
  
  ;; total-score : -> Number
  ;; Total score of both teams
  (define (total-score)
    (+ (this . points)
       (this . next . total-score)))
  ;; Tests/Examples:
  (check-expect (game2 . total-score) 7)
  (check-expect (game3 . total-score) 3)
  (check-expect (game4 . total-score) 24))



;; Examples:
(define game1 (new end%))
(define game2 (new possesion% 0 100 7
                   (new end%)))
(define game3 (new possesion% 0 30 0
                   (new possesion% 20 80 3
                        (new end%))))
(define game4 (new possesion% 0 60 3
                   (new possesion% 20 100 7
                        (new possesion% 50 100 7
                             (new possesion% 20 50 0
                                  (new possesion% 50 100 7
                                       (new end%)))))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; A Time is a (new time% Hours Mins)
; where Hours is an Integer in [0,24)
;   and  Mins is an Integer in [0,60)
(define-class time%
  (fields hours minutes)
  
  ;; ->minutes : -> Number
  ;; Convert the time to minutes since midnight.
  (define (->minutes)
    (+ (* 60 (this . hours))
       (this . minutes)))
  ;; Tests/Examples:
  (check-expect ((new time% 0 0) . ->minutes) 0)
  (check-expect ((new time% 3 23) . ->minutes) 203))


; An Event is a (new event% String Time Time)
; Interp: an event with a name and a start and end time.
(define-class event%
  (fields name start end)
  
  ;; duration : -> Number
  ;; Duration of the event in minutes
  (define (duration)
    (- (this . end . ->minutes)
       (this . start . ->minutes)))
  ;; Tests/Examples:
  (check-expect (event1 . duration) 120)
  (check-expect (event2 . duration) 120)
  (check-expect (event3 . duration)  60)
  
  ;; ends-before? : Event -> Boolean
  ;; Does this event end before the given event starts?
  (define (ends-before? e)
    (< (this . end . ->minutes)
       (e . start . ->minutes)))
  ;; Tests/Examples:
  (check-expect (event1 . ends-before? event2) true)
  (check-expect (event1 . ends-before? event3) false)
  (check-expect (event2 . ends-before? event1) false)
  
  ;; overlap? : Event -> Boolean
  ;; Does this event overlap the given event?
  (define (overlap? e)
    (or (and (> (this . end   . ->minutes)
                (e    . start . ->minutes))
             (< (this . start . ->minutes)
                (e    . start . ->minutes)))
        (and (> (e    . end   . ->minutes)
                (this . start . ->minutes))
             (< (e    . start . ->minutes)
                (this . start . ->minutes)))))
  ;; Tests/Examples:
  (check-expect (event1 . overlap? event2) false)
  (check-expect (event1 . overlap? event3) true))

;;Examples:
(define event1 (new event%
                    "event 1"
                    (new time% 8 30)
                    (new time% 10 30)))
(define event2 (new event%
                    "event 2"
                    (new time% 12 0)
                    (new time% 14 0)))
(define event3 (new event%
                    "event 3"
                    (new time% 9 0)
                    (new time% 10 0)))

#|

; A Schedule is one of:
; - (new no-event%)
; - (new cons-event% Event Schedule)
(define-class no-event%
  
  ;; no-event? : -> Boolean
  ;; Does this schedule have events
  ;; quick answer: no
  (define (no-event?)
    true)
  ;; Tests/Examples:
  
  
  
  ;; good : -> Boolean
  ;; Is the schedule good?
  (define (good?)
    true)
  ;; Tests/Examples:
  (check-expect ((new no-event%) . good?) true)
  
  
  ;; scheduled-time : -> Number
  ;; Total time of all events in minutes
  ;; No events = no time, duh
  (define (scheduled-time)
    0)
  ;; Tests/Examples:
  (check-expect ((new no-event%) . scheduled-time) 0)
  
  
  ;; free-time : -> Schedule
  ;; Schedule of free time
  (define (free-time)
      (new cons-event%
           (new event%
                "Free time"
                (new time% 0 0)
                (new time% 23 59))
           (new no-event%)))
  ;; Tests/Examples:
  (check-expect ((new no-event%) . free-time)
                  (new cons-event%
                       (new event%
                            "Free time"
                            (new time% 0 0)
                            (new time% 23 59))
                       (new no-event%))))

(define-class cons-event%
  (fields event rest)
  
  ;; no-event? : -> Boolean
  ;; Does this schedule have events
  ;; quick answer: yes
  (define (no-event?)
    false)
  ;; Tests/Examples:
  
  
  
  ;; good?
  ;; Are the events in non-overlapping order?
  (define (good?)
    (and (this . event . ends-before? (this . rest . event))
         (this . rest . good?)))
  ;; Tests/Examples:
  
  
  ;; scheduled-time
  ;; Total-time in minutes of scheduled events.
  ;; Assumed the schedule is good.
  (define (scheduled-time)
    (+ (this . event . duration)
       (this . rest . scheduled-time)))
  ;; Tests/Examples:
  
  
  
  ;; free-time
  ;; Compute a schedule of free-time named "Free time"
  (define (free-time)
      (local ((define (free-time_acc acc after)
                (cond [(no-event? after) acc]
                       [(= 
                         (free-schedule_acc
                 
                     (new cons-event%
                          (new event%
                               "Free time"
                               (acc . event . start)
                               (time-- (after . event . start)))
                          (free-schedule (new cons-event%
                                              (new event%
                                                   "Free time"
                                                   (time++ (after . event . end))
                                                   (acc . event . end))
                                              (new no-event%))
                                         (after . rest)))))
                (free-time ((new no-event%) . free-time)
                           this)))))
  ;; Tests/Examples:
  )


(define (time-- time)
  (local ((define in-mins (sub1 (time . ->minutes))))
    (new time%
         (floor (/ in-mins 60))
         (modulo (in-mins 60)))))
        
(define (time++ time)
  (local ((define in-mins (add1 (time . ->minutes))))
    (new time%
         (floor (/ in-mins 60))
         (modulo (in-mins 60)))))|#


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A ListOfNumber is one of
;; - (new lon% Number List)
;; - (new mtlon%)
;; an implements:
;; The same list with the numbers in opposite order
;; - reverse : -> ListOfNumber
;; Is the list empty?
;; mt? : -> Boolean

;; --------------- lon% -----------------
(define-class lon%
  (fields num rest)
  
  ;; mt? : -> Boolean
  ;; Is this empty?
  (define (mt?)
    false)
  ;; Tests/Examples:
  (check-expect (lon1 . mt?) false)
  (check-expect (lon2 . mt?) false)
  (check-expect (lon3 . mt?) false)
  
  
  ;; reverse : -> ListOfNumber
  ;; The same list with the numbers in opposite order
  (define (reverse)
    (local ((define (reverse_acc acc remain)
              (if (remain . mt?)
                  acc
                  (reverse_acc (new lon%
                                    (remain . num)
                                    acc)
                               (remain . rest)))))
            (reverse_acc (new mtlon%) this)))
  ;; Tests/Examples:
  (check-expect (lon3 . reverse)
                (new lon% 1
                          (new lon% 2
                               (new lon% 3
                                    (new mtlon%)))))
  (check-expect (lon2 . reverse)
                (new lon% 1
                     (new lon% 2
                          (new mtlon%))))
  (check-expect (lon1 . reverse)
                lon1))


;; -------------- mtlon% ----------------
(define-class mtlon%
  
  ;; mt? : -> Boolean
  ;; is this empty?
  (define (mt?)
    true)
  ;; Tests/Examples:
  (check-expect (lon0 . mt?) true)
  
  ;; reverse : -> ListOfNumber
  ;; The same list with the numbers in opposite order
  (define (reverse)
    this)
  ;; Tests/Examples:
  (check-expect (lon0 . reverse)
                lon0))

;; Examples:
(define lon0 (new mtlon%))
(define lon1 (new lon% 1
                  lon0))
(define lon2 (new lon% 2
                  lon1))
(define lon3 (new lon% 3
                  lon2))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 6 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ALREADY DONE AS ACCUMULATOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 2htdp/image)

; A Shape is one of:
; - (new circle% radius)
; - (new rectangle% width height)
; and implements:
; size : -> Number
; draw : Color -> Image
; overlay : Shape -> Shape

;; A Circle is a (new circle% Number)
(define-class circle%
  (fields radius)
  
  ;; size : -> Number
  ;; Area of the circle
  (define (size)
    (* pi (this . radius) (this . radius)))
  ;; Tests/Examples:
  (check-expect (circ1 . size) 0)
  (check-expect (floor (inexact->exact (circ2 . size))) 314)
  
  
  ;; draw : Color -> Image
  ;; Draw this circle
  (define (draw color)
    (circle (this . radius)
            'solid
            color))
  ;; Tests/Examples:
  (check-expect (circ1 . draw 'red)   (circle 0 'solid 'red))
  (check-expect (circ2 . draw 'green) (circle 10 'solid 'green))
  
  ;; overlay : Shape -> Shape
  ;;
  )

;; Examples:
(define circ1 (new circle% 0))
(define circ2 (new circle% 10))


;; A Rectangle is a (new rectangle% Number Number)
(define-class rectangle%
  (fields width height)
  
  ;; size : -> Number
  ;; Area of the rectangle
  (define (size)
    (* (this . width)
       (this . height)))
  
  ;; draw : Color -> Image
  ;; Draw this rectangle
  (define (draw color)
    (rectangle (this . width)
               (this . height)
               'solid
               color))
  ;; Tests/Examples:
  (check-expect (rect1 . draw 'red) (rectangle 0 0 'solid 'red))
  (check-expect (rect2 . draw 'green) (rectangle 10 5 'solid 'green)))

;; Examples:
(define rect1 (new rectangle% 0 0))
(define rect2 (new rectangle% 10 5))
  
  
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  

;; A Population as a
;; (new pop% [Listof Number])
;; and implements:
;; Make everyone a year older.
;; - age-all -> Population
;; Find the age of the oldest person.
;; - max-age -> Number
;; Age until there are half as many adults as when started.
;; - half-working -> Population

(define-class pop%
  (fields people)
  
  ;; age-all : -> Population
  ;; Make everyone a year older
  (define (age-all)
    (new pop%
         (filter (λ (p) (>= 90 p))
            (map add1 (this . people)))))
  ;; Tests/Examples:
  
  
  
  ;; max-age : -> Number
  ;; Find the age of the oldest person
  (define (max-age)
    (foldr (λ (p oldest)
             (if (> p oldest)
                 p
                 oldest))
           0
           (this . people)))
  ;; Tests/Examples:
  (check-expect ((new pop% empty) . max-age) 0)
  (check-expect ((new pop% (list 70)) . max-age) 70)
  (check-expect ((new pop% (list 70 20)) . max-age) 70)
  (check-expect ((new pop% (list 20 70 90)) . max-age) 90)
  (check-expect ((new pop% (list 20 90 70)) . max-age) 90)
  
  
  ;; num-adults : -> Number
  ;; How many people are >= 25 && < 65
  (define (num-adults)
    (foldr (λ (p result)
             (if (and (>= p 25)
                      (<  p 65))
                 (add1 result)
                 result))
           0
           (this . people)))
  ;; Tests/Examples:
  (check-expect (pop1 . num-adults) 0)
  (check-expect (pop2 . num-adults) 4)
  (check-expect (pop3 . num-adults) 8)
  (check-expect (pop4 . num-adults) 13)
  (check-expect ((new pop% (list 20 35 60)) . num-adults) 2)
                 
                 
  ;; half-working : -> Population
  ;; Age until there are half as many adults as when started.
  (define (half-working)
    (local ((define adults (this . num-adults))
            (define (age&check pop)
              (if (>= (quotient adults 2) (pop . num-adults))
                  pop
                  (age&check (pop . age-all)))))
      (age&check this)))
  ;; Tests/Examples:
  (check-expect (pop1 . half-working) pop1)
  (check-expect (pop2 . half-working) (new pop% (list 45 55 65 75 85)))
  (check-expect (pop3 . half-working) (new pop% '(40 50 55 60 65 70 75 80 85 90)))
  (check-expect (pop4 . half-working) (new pop% '(41 51 61 62 63 64 65 66 67 68 69 69 71))))


;; Examples:
(define pop1 (new pop% empty))
(define pop2 (new pop% (list 10 20 30 40 50 60 70 80)))
(define pop3 (new pop% (list 10 20 25 30 35 40 45 50 55 60 65 70 75 80 85)))
(define pop4 (new pop% (list 25 35 45 46 47 48 49 50 51 52 53 53 55)))





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 10 : PONG ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require class/universe)

;;--------------------------------------------------------------;;
;;;;;;;;;;;;;;;;;;;;;;;;; CONSTANTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;--------------------------------------------------------------;;

;; WORLD CONSTANTS
(define SCENE_W 700)
(define SCENE_W/2 (/ SCENE_W 2))
(define SCENE_H 500)
(define SCENE_H/2 (/ SCENE_H 2))
(define BACK_COLOR 'black)
(define BACK_IMAGE (scene+line (overlay (rectangle SCENE_W
                                                   SCENE_H
                                                   'solid
                                                   BACK_COLOR)
                                        (empty-scene SCENE_W
                                                     SCENE_H))
                               SCENE_W/2
                               0
                               SCENE_W/2
                               SCENE_H
                               (make-pen 'white
                                         5
                                         'long-dash
                                         'butt
                                         'miter)))
(define WINNING_SCORE 10)

;; PLAYER CONSTANTS 
(define PAD_LEFT_X 40)
(define PAD_RIGHT_X (- SCENE_W 40))
(define PAD_Y_START (/ SCENE_H 2))
(define PAD_W 20)
(define PAD_W/2 (/ PAD_W 2))
(define PAD_H 150)
(define PAD_H/2 (/ PAD_H 2))
(define PAD_VEL 8)
(define PAD_IMAGE (rectangle PAD_W
                             PAD_H
                             'solid
                             'white))
(define SCORE_Y 20)
(define SCORE_LEFT_X 20)
(define SCORE_RIGHT_X (- SCENE_W SCORE_LEFT_X))


;; BALL CONSTANTS
(define BALL_X_START (/ SCENE_W 2))
(define BALL_Y_START (/ SCENE_H 2))
(define BALL_RAD 10)
(define BALL_IMAGE (circle BALL_RAD
                           'solid
                           'white))
(define BALL_SPEED 15)
(define BALL_MAX_Y_SPEED 7)

;; A World is a (new World Player Player Ball)
(define-class world%
  (fields left right ball)
  
  
  ;; Template:
  #; (define (world%-temp)
       (this . left)  ...
       (this . right) ...
       (this . ball)  ...)
  
  
  ;; to-draw : -> Scene
  ;; Draw the parts of the world
  (define (to-draw)
    (cond [(= 10 (this . left . score))
           (overlay (text "LEFT WINS!" 70 'green)
                    BACK_IMAGE)]
          [(= 10 (this . right . score))
           (overlay (text "RIGHT WINS!" 70 'green)
                    BACK_IMAGE)]
          [else (this . ball . draw-on
                      (this . left . draw-on
                            (this . right . draw-on
                                  BACK_IMAGE)))]))
  ;; Tests/Examples:
  
  
  
  ;; on-key : MouseEvent -> World
  ;; Manage key events
  (define (on-key me)
    (cond [(key=? me (this . left . up-key))
           (new world%
                (this . left . move -)
                (this . right)
                (this . ball))]
          [(key=? me (this . left . down-key))
           (new world%
                (this . left . move +)
                (this . right)
                (this . ball))]
          [(key=? me (this . right . up-key))
           (new world%
                (this . left)
                (this . right . move -)
                (this . ball))]
          [(key=? me (this . right . down-key))
           (new world%
                (this . left)
                (this . right . move +)
                (this . ball))]
          [else this]))
  ;; Tests/Examples:
  
  
  
  ;; on-tick : -> World
  ;; Move the elements in the world and check conditions
  (define (on-tick)
    ((new world%
         (this . left)
         (this . right)
         (this . manage-ball)) . check-goals))
  ;; Tests/Examples:
  
  ;; stop-when : -> Boolean
  (define (stop-when)
    (or (= WINNING_SCORE (this . left  . score))
        (= WINNING_SCORE (this . right . score))))
  
  
  ;; check-goals : -> World
  ;; Check for goals
  (define (check-goals)
    (local ((define edge (this . ball . at-edge)))
      (cond [(symbol=? edge 'left)
             (new-world (this . left) (this . right . score++))]
            [(symbol=? edge 'right)
             (new-world (this . left . score++) (this . right))]
            [else this])))
  ;; Tests/Examples:
  
  ;; mangage-ball : -> Ball
  ;; Manage ball collisions and stuff
  (define (manage-ball)
    ((local ((define wall-collision (this . ball . at-edge)))
      (cond [(symbol=? wall-collision 'top)
             (this . ball . bounce 'top)]
            [(symbol=? wall-collision 'bottom)
             (this . ball . bounce 'bottom)]
            [(this . left . collide-ball? (this . ball))
             (this . ball . bounce 'left)]
            [(this . right . collide-ball? (this . ball))
             (this . ball . bounce 'right)]
            [else
             (this . ball)])) . move))
  ;; Tests/Examples:
  )

   
    
    
;; A Player is a (new player% Number Number KeyEvent KeyEvent Number Number)
(define-class player%
  (fields score score-x up-key down-key pad-x pad-y)
  
  ;; Template:
  #; (define (player%-temp)
       (this . score) ...
       (this . score-x) ...
       (this . up-key) ...
       (this . down-key) ...
       (this . pad-x) ...
       (this . pad-y) ...)
  
  
  ;; draw-on : Scene -> Scene
  ;; draw the score and pad on the scene
  (define (draw-on scene)
    (place-image (text (number->string (this . score)) 20 'white)
                 (this . score-x)
                 SCORE_Y
                 (place-image PAD_IMAGE
                              (this . pad-x)
                              (this . pad-y)
                              scene)))
  ;; Tests/Examples:
  
  
  
  ;; move : [Number Number -> Number] -> Player
  ;; Move the pad up or down
  ;; - = up
  ;; + = down
  (define (move op)
    (new player%
         (this . score)
         (this . score-x)
         (this . up-key)
         (this . down-key)
         (this . pad-x)
         (max PAD_H/2
              (min (- SCENE_H
                      PAD_H/2)
                   (op (this . pad-y)
                       PAD_VEL)))))
  ;; Tests/Examples:
  
  
  
  ;; collide-ball? : Ball -> Boolean
  ;; Is the ball on the pad?
  (define (collide-ball? ball)
    (and (<= (ball . pos-x)
             (+ (this . pad-x)
                PAD_W/2
                BALL_RAD))
         (> (ball . pos-x)
            (- (this . pad-x)
               PAD_W/2))
         (> (ball . pos-y)
            (- (this . pad-y)
               PAD_H/2))
         (< (ball . pos-y)
            (+ (this . pad-y)
               PAD_H/2))))
  ;; Tests/Examples:
  
  
  
  ;; score++ : -> Player
  ;; add to the score
  (define (score++)
    (new player%
         (add1 (this . score))
         (this . score-x)
         (this . up-key)
         (this . down-key)
         (this . pad-x)
         (this . pad-y)))
  ;; Tests/Examples:
  
  
  )

;; A Ball is a (new ball% Number Number Number Number)
(define-class ball%
  (fields pos-x pos-y vel-x vel-y)
  
  
  ;; Template:
  #;(define (ball%-temp)
      (this . pos-x) ...
      (this . pos-y) ...
      (this . vel-x) ...
      (this . vel-y) ...)
  
  
  ;; draw-on : Scene -> Scene
  ;; Draw the ball on the scene
  (define (draw-on scene)
    (place-image BALL_IMAGE
                 (this . pos-x)
                 (this . pos-y)
                 scene))
  ;; Tests/Examples:
  
  
  ;; move : -> Ball
  ;; Move the ball
  (define (move)
    (new ball%
         (+ (this . pos-x)
            (this . vel-x))
         (+ (this . pos-y)
            (this . vel-y))
         (this . vel-x)
         (this . vel-y)))
  ;; Tests/Examples:
  
  
  
  ;; bounce -> Ball
  ;; Change the ball's velocity as if it's bouncing
  (define (bounce edge)
    (new ball%
         (this . pos-x)
         (this . pos-y)
         (if (or (symbol=? edge 'left)
                 (symbol=? edge 'right))
             (- (this . vel-x))
             (this . vel-x))
         (if (or (symbol=? edge 'top)
                 (symbol=? edge 'bottom))
             (- (this . vel-y))
             (this . vel-y))))
  ;; Tests/Examples:
  
  
  
  ;; at-edge : -> Edge
  ;; Which edge is the ball at?
  (define (at-edge)
    (cond [(and (<= (this . pos-x)
                    10)
                (negative? (this . vel-x)))
           'left]
          [(and (>= (this . pos-x)
                    (- SCENE_W 10))
                (positive? (this . vel-x)))
           'right]
          [(and (<= (this . pos-y)
                    BALL_RAD)
                (negative? (this . vel-y)))
           'top]
          [(and (>= (this . pos-y)
                    (- SCENE_H
                       BALL_RAD))
                (positive? (this . vel-y)))
           'bottom]
          [else 'none]))
  ;; Tests/Examples:
  )

;; rand-ball-vel : -> Posn
;; Create a random velocity of constant R speed.
(define (rand-ball-vel)
  (local ((define y-speed (random BALL_MAX_Y_SPEED))
          (define x-speed (* BALL_SPEED (cos (asin (/ y-speed BALL_SPEED))))))
    (make-posn (* (expt -1 (random 2)) x-speed)
               (* (expt -1 (random 2)) y-speed))))
;; Tests/Examples:

;; new-world : -> World
;; Generate a world with random ball vel
;; and pieces in default places.
(define (new-world left right)
  (local ((define ball_vel (rand-ball-vel)))
    (new world%
               left
               right
               (new ball%
                    BALL_X_START
                    BALL_Y_START
                    (posn-x ball_vel)
                    (posn-y ball_vel)))))
;; Tests/Examples:
(check-expect (local ((define result (new-world LEFT_START
                                                RIGHT_START)))
                (and (equal? (result . left) LEFT_START)
                     (equal? (result . right RIGHT_START))
                     (= BALL_SPEED
                        (sqrt (+ (sqr (result . ball . vel-x))
                                 (sqr (result . ball . vel-y)))))))
              true)
                
                                             

(define LEFT_START (new player%
                        0
                        SCORE_LEFT_X
                        "w"
                        "s"
                        PAD_LEFT_X
                        PAD_Y_START))
(define RIGHT_START (new player%
                         0
                         SCORE_RIGHT_X
                         "up"
                         "down"
                         PAD_RIGHT_X
                         PAD_Y_START))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; BIG BANG ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#;(big-bang (new-world LEFT_START RIGHT_START))








































