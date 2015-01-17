#lang class/1

(require 2htdp/image)
(require class/universe)

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
  
  ;; Template:
  #;(define (mtree%-temp)
      ... (field length) ...
      ... (field left) ...
      ... (field right) ...)
  
  
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
  (fields height total-weight color)
  
  ;; template:
  #;(define (mleaf%-temp)
      ... (field height) ...
      ... (field total-weight) ...
      ... (field color) ...))

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
  
  ;; template
  #;(define (consLoE%-temp)
      (field first) ...
      (field rest) ...)
            
  
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
  
  ;; template:
  #; (define (mtLoE%-temp)
       ...)
  
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
  
  ;; Template:
  #; (define (boss%-temp)
       ... (field name) ...
       ... (field unit) ...
       ... (field tasks) ...
       ... (field peons) ...)
  
  
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
  
  
  ;; Template:
  #;(define (worker%-temp)
      ... (field name) ...
      ... (field tasks) ...)
  
  
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
  
  ;; Template:
  #;(define (end%-temp)
      ...)
  
  
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
  
  
  ;; template:
  #;(define (possession%-temp)
      ... (field start) ...
      ... (field end) ...
      ... (field points) ...
      ... (field next) ...)
  
  
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

;; Exercise 4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Interfaces

;; A ITime implements:
;; ->minutes : -> Number
;; converts this time to the number of minutes since midnight

;; An IEvent implements:
;; duration : -> Number
;; computes the duration of this event in minutes
;; ends-before? : Event -> Boolean
;; determines if this event ends before a given event starts
;; overlap? : Event -> Boolean
;; determines whether this event overlaps with a given event

;; Definitions

;; A Time is a (new time% Hours Mins)
;; where Hours is an Integer in [0,24)
;; and Mins is an Integer in [0,60)

(define-class time%
  (fields hours mins)
  
  ; Template:
  #;(define (time%-temp)
      ... (this . hours) ...
      ... (this . mins)  ...)
  
  
  ;; ->minutes : -> Number
  ;; converts this time to the number of minutes since midnight
  (define (->minutes)
    (+ (* 60 (field hours)) (field mins)))
  ;; Tests/Examples:
  (check-expect (time1 . ->minutes) 630)
  (check-expect (time2 . ->minutes) 720)
  (check-expect ((new time% 14 23) . ->minutes) 863))



;; An Event is a (new event% String Time Time)
;; Interp: an event with a name and a start and end time
(define-class event%
  (fields name start end)
  
  ;; Template:
  #;(define (event%-temp)
      ... (this . name)  ...
      ... (this . start) ...
      ... (this . end)   ...)
  
  
  ;; duration : -> Number
  ;; computes the duration of this event in minutes
  (define (duration)
    (- ((field end) . ->minutes) ((field start) . ->minutes)))
  ;; Tests/Examples:
  (check-expect (event1 . duration) 90)
  (check-expect (event2 . duration) 240)
  (check-expect (event3 . duration) 300)
  
  
  
  ;; ends-before? : Event -> Boolean
  ;; determines if this event ends before a given event starts
  (define (ends-before? x)
    (< ((field end) . ->minutes) (x . start . ->minutes)))
  ;; Tests/Examples:
  (check-expect (event1 . ends-before? event2) false)
  (check-expect (event1 . ends-before? (new event% "Lunch2"
                                            (new time% 12 0)
                                            (new time% 2 0))) false)
  (check-expect (event1 . ends-before? event3) true)
  
  
  
  ;; overlap? : Event -> Boolean
  ;; determines whether this event overlaps with a given event
  (define (overlap? x)
    (not (this . ends-before? x)))
  ;; Tests/Examples:
  (check-expect (event1 . overlap? event2) true)
  (check-expect (event1 . overlap? (new event% "Lunch2"
                                        (new time% 12 0)
                                        (new time% 2 0))) true)
  (check-expect (event1 . overlap? event3) false))




;; A Schedule is one of:
;; - (new no-event%)
;; - (new cons-event% Event Schedule)

(define-class no-event%
  
  ;; Template:
  #;(define (no-event%-temp)
      ...)
  
  ;; rest-event : -> Schedule
  ;; returns no-event
  (define (rest-event) no-event)
  ;; Tests/Examples:
  (check-expect (no-event . rest-event) no-event)
  
  
  
  ;; append : Schedule
  ;; returns x
  (define (append x) x)
  ;; Tests/Examples:
  (check-expect (no-event . append no-event) no-event)
  (check-expect (no-event . append schedule1) schedule1)
  
  
  
  ;; good? : -> Boolean
  ;; determines if the events in this schedule are in order
  ;; and do not overlap
  (define (good?) true)
  ;; Tests/Examples:
  (check-expect (no-event . good?) true)
  
  
  
  ;; scheduled-time : -> Number
  ;; computes total time in minutes scheduled in this schedule
  (define (scheduled-time) 0)
  ;; Tests/Examples:
  (check-expect (no-event . scheduled-time) 0)
  
  
  
  ;; free-time : -> Number
  ;; computes schedule of events named "Free time" that are all times 
  ;; NOT scheduled in this schedule
  (define (free-time)
    (new cons-event% (new event% "Free time" (new time% 0 0) (new time% 23 59))
         no-event))
  ;; Tests/Examples:
  (check-expect ((new no-event%) . free-time)
                (new cons-event% (new event%
                                      "Free time"
                                      (new time% 0 0)
                                      (new time% 23 59))
                     no-event)))
 

(define-class cons-event%
  (fields first rest)
  
  ;; Template:
  #; (define (cons-event%-temp)
       ... (this . first) ...
       ... (this . rest)  ...)
  
  
  ;; rest-event : -> Schedule
  ;; creates new schedule from (field rest)
  (define (rest-event)
    (cond [(equal? (field rest) no-event) no-event]
          [else (new cons-event% ((field rest) . first) 
                     ((field rest) . rest))]))
  ;; Tests/Examples:
  (check-expect ((new cons-event% event1 no-event) . rest-event) no-event)
  (check-expect (schedule1 . rest-event) (new cons-event% event3 no-event))
  
  
  
  ;; append : -> Schedule
  ;; appends two schedules to create new schedule
  (define (append x)
    (cond [(equal? x no-event) this]
          [else (new cons-event% (field first) 
                     ((field rest) . append x))]))
  ;; Tests/Examples:
  (check-expect ((new cons-event% event1 no-event) 
                 . append (new cons-event% event3 no-event)) schedule1)
  
  
  
  ;; good? : -> Boolean
  ;; determines if the events in this schedule are in order
  ;; and do not overlap
  (define (good?)
    (cond [(equal? (field rest) no-event) (no-event . good?)]
          [(and (< ((field first) . end . ->minutes) 
                   ((field rest) . first . start . ->minutes))
                ((field first) . ends-before? 
                               ((field rest) . first)))
           ((this . rest-event) . good?)]
          [else false]))
  ;; Tests/Examples:
  (check-expect (schedule1 . good?) true)
  (check-expect (schedule2 . good?) false)
  (check-expect (schedule3 . good?) false)
  
  
  
  ;; scheduled-time : -> Number
  ;; computes total time in minutes scheduled in this schedule
  (define (scheduled-time)
    (+ ((field first) . duration) 
       ((field rest) . scheduled-time)))
  ;; Tests/Examples:
  (check-expect (schedule1 . scheduled-time) 390)
  (check-expect (schedule2 . scheduled-time) 630)
  (check-expect (schedule3 . scheduled-time) 390)
  
  
  ;; free-time : -> Number
  ;; computes schedule of events named "Free time" that are all times 
  ;; NOT scheduled in this schedule
  (define (free-time)
    (local ((define (free-time-acc x acc1 acc2)
              (cond [(equal? x no-event) (acc1 . append acc2)]
                    [else (free-time-acc (x . rest-event) 
                                         (acc1 . append 
                                               (new cons-event% 
                                                    (new event% "Free time" 
                                                         (acc2 . first . start)
                                                         (sub1-time (x . first . start))) no-event))
                                         (new cons-event% 
                                              (new event% "Free time"
                                                   (add1-time (x . first . end))
                                                   (acc2 . first . end)) no-event))])))
      (free-time-acc this no-event (no-event . free-time))))
  ;; Tests/Examples:
  (check-expect (schedule1 . free-time)
                (new cons-event% (new event% "Free time"
                                      (new time% 0 0)
                                      (new time% 10 29)) 
                     (new cons-event% (new event% "Free time"
                                           (new time% 12 1)
                                           (new time% 15 59))
                          (new cons-event% (new event% "Free time"
                                                (new time% 21 1)
                                                (new time% 23 59)) no-event)))))
  

;; Helper functions

;; Note: These should be helper methods

;; sub1-time : Time -> Time
;; subtracts 1 minute from Time
(define (sub1-time x)
  (cond [(and (not (zero? (x . hours)))
              (zero? (x . mins)))
         (new time% (sub1 (x . hours)) 59)]
        [else (new time% (x . hours) (sub1 (x . mins)))]))
;; Tests/Examples:
  

;; add1-time : Time -> Time
;; adds 1 minute to Time
(define (add1-time x)
  (cond [(and (not (= 23 (x . hours)))
              (= 59 (x . mins)))
         (new time% (add1 (x . hours)) 0)]
        [else (new time% (x . hours) (add1 (x . mins)))]))
;; Tests/Examples:

  
;; Examples
(define time1 (new time% 10 30))
(define time2 (new time% 12 0))
(define event1 (new event% "Brunch" time1 time2))
(define event2 (new event% "Lunch" (new time% 11 0) (new time% 15 0)))
(define event3 (new event% "Dinner" (new time% 16 0) (new time% 21 0)))

(define no-event (new no-event%))
(define schedule1 (new cons-event% event1
                       (new cons-event% event3 no-event))); good schedule
(define schedule2 (new cons-event% event1
                       (new cons-event% event2
                            (new cons-event% event3 no-event)))); events overlap
(define schedule3 (new cons-event% event3
                       (new cons-event% event1 no-event))); events out of order




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
  
  
  ;; template;
  #; (define (lon%-temp)
       (this . num) ...
       (this . rest) ...)
  
  
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




;; Exercise 6 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; SEE EXERCISE 4



;; Exercise 7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Interface

;; An IShape implements:
;; size : -> Number
;; computes area of Shape
;; draw : String -> Image
;; draws this Shape
;; overlay : Shape -> Image
;; draws and overlays Shapes
;; underlay : Shape -> Image
;; draws and underlays shapes

;; Definitions

; A Shape is one of:
; - (new circle% radius)
; - (new rectangle% width height)

;; Templates

#;(define (circle-temp ...)
(field radius) ...)

#;(define (rectangle-temp ...)
(field width) ...
(field height) ...)

(define-class circle%
  (fields radius)
  
  ; size : -> Number
  ; computes area of Shape
  (define (size)
    (* pi (sqr (field radius))))
  
  (check-expect (inexact->exact (circle1 . size)) (inexact->exact (* pi 900)))
  
  ; draw : String -> Image
  ; draws this Shape
  (define (draw c)
    (circle (field radius) "solid" c))
  
  (check-expect (circle1 . draw "blue") (circle 30 "solid" "blue"))
  
  ; overlay : Image String -> Image
  ; draws and overlays Shape
  (define (overlay i c)
    (overlay/align "middle" "middle" (this . draw c) i))
  
  (check-expect (circle1 . overlay (circle2 . draw "yellow") "purple")
                (overlay/align "middle" "middle" (circle 30 "solid" "purple")
                               (circle 20 "solid" "yellow")))
  
  ; underlay : Image String -> Image
  ; draws and underlays Shape
  (define (underlay i c)
    (underlay/align "middle" "middle" (this . draw c) i))
  
  (check-expect (circle1 . underlay (circle2 . draw "yellow") "purple")
                (underlay/align "middle" "middle" (circle 30 "solid" "purple")
                                (circle 20 "solid" "yellow"))))

(define-class rectangle%
  (fields width height)
  
  ; size : -> Number
  ; computes area of Shape
  (define (size)
    (* (field width) (field height)))
  
  (check-expect (rectangle1 . size) 5000)
  
  ; draw : String -> Image
  ; draws this Shape
  (define (draw c)
    (rectangle (field width) (field height) "solid" c))
  
  (check-expect (rectangle1 . draw "magenta")(rectangle 100 50 "solid" "magenta"))
  
  ; overlay : Image String -> Image
  ; draws and overlays Shape
  (define (overlay i c)
    (overlay/align "middle" "middle" (this . draw c) i))
  
  (check-expect (rectangle1 . overlay (rectangle2 . draw "green") "blue") 
                (overlay/align "middle" "middle"
                               (rectangle 100 50 "solid" "blue")
                               (rectangle 80 40 "solid" "green")))
  
  ; underlay : Image String -> Image
  ; draws and underlays Shape
  (define (underlay i c)
    (underlay/align "middle" "middle" (this . draw c) i))
  
  (check-expect (rectangle1 . underlay (rectangle2 . draw "green") "blue") 
                (underlay/align "middle" "middle"
                                (rectangle 100 50 "solid" "blue")
                                (rectangle 80 40 "solid" "green"))))

;; Examples
(define circle1 (new circle% 30))
(define circle2 (new circle% 20))
(define rectangle1 (new rectangle% 100 50))
(define rectangle2 (new rectangle% 80 40))

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
  (check-expect (pop1 . age-all) pop1)
  (check-expect (pop2 . age-all) (new pop% (list 11 21 31 41 51 61 71 81)))
  (check-expect (pop3 . age-all) (new pop% (list 11 21 26 31 36 41 46 51 56 61 66 71 76 81 86)))
  (check-expect (pop4 . age-all) (new pop% (list 26 36 46 47 48 49 50 51 52 53 54 54 56)))
  


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




;; Exercise 9 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; An OrganicMolecule, or OM, is one of:
;; - (new Atom empty-bond)
;; - (new Atom cons-bond)
; Note: There are no empty OM

;; A Bond is one of:
;; - cons-bond, or (new cons-bond% Number Atom Bond)
;; - empty-bond, or (new empty-bond%)
;; Interp:
;; bond-type is either a single-bond (1), double-bond (2) or triple-bond (3)
;; atom-type is either a carbon or hydrogen atom
;; rest is the rest of the bonds associated with the atom

;; Templates

#; (define (empty-bond-temp ...)
...)

#; (define (cons-bond-temp ...)
(field bond-type)...
(field atom-type)...
(field rest)...)

(define-class empty-bond%)

(define-class cons-bond%
  (fields bond-type atom-type rest))

;; An Atom is a (new atom% Symbol Bond) and is one of:
;; - (new atom% 'carbon Bond) Interp: carbon atom
;; - (new atom% 'hydrogen Bond) Interp: hydrogen atom

;; Template

#; (define (atom-temp ...)
(field type)...
(field connections)...)

(define-class atom% 
  (fields type connections)
  
  ; count-carbons : -> Number
  ; starting from a carbon atom, counts all of the carbon atoms 
  ; connected to it (including the starting atom)
  ; Note: this definition is incomplete
  (define (count-carbons)
    (cond [(and (not (symbol=? (field type) 'carbon))
                (equal? (field connections) empty-bond)) 0]
          [(and (symbol=? (field type) 'carbon)
                (equal? (field connections) empty-bond)) 1]
          [(symbol=? (field type) 'carbon)
           (add1 ((field connections) . atom-type . count-carbons))]
          [else ((field connections) . atom-type . count-carbons)]))
  
  (check-expect (empty-carbon . count-carbons) 1)
  (check-expect (empty-hydrogen . count-carbons) 0)
  (check-expect (butane . count-carbons) 4)
  #| 
  ; valid? : -> Boolean
  ; determines if every attached carbon atom has at most 4 bonds
  (define (valid?)
    (local ((define (count-bonds c) 
              (cond [(equal? c empty-bond) 0]
                    [else (+ (c . bond-type)
                             (count-bonds (c . rest)))])))
      (not (> (count-bonds (field connections)) 4))))
                   
  
  (check-expect (empty-carbon . valid?) true)
  (check-expect (butane . valid?) true)
; (check-expect (invalid-carbon1 . valid?) false)
; (check-expect (invalid-carbon2 . valid?) false))
  |#
; count-hydrogens : -> Number
 ; counts the number of hydrogens in the molecule
 ; (define (count-hydrogens) ...)
)                             

;; Examples
(define empty-bond (new empty-bond%))
(define empty-carbon (new atom% 'carbon empty-bond)) ; single carbon
(define empty-hydrogen (new atom% 'hydrogen empty-bond)) ; single hydrogen
(define butane (new atom% 'carbon (new cons-bond% 1 
                   (new atom% 'carbon (new cons-bond% 1
                       (new atom% 'carbon (new cons-bond% 1
                           (new atom% 'carbon empty-bond)
                           empty-bond))
                       empty-bond))
                   empty-bond)))
(define invalid-carbon1 
  (new atom% 'carbon (new cons-bond% 1 (new atom% 'carbon empty-bond)
                     (new cons-bond% 1 (new atom% 'carbon empty-bond)
                     (new cons-bond% 1 (new atom% 'carbon empty-bond)
                     (new cons-bond% 1 (new atom% 'carbon empty-bond)
                     (new cons-bond% 1 (new atom% 'carbon empty-bond)
                          empty-bond))))))) 
; 1 carbon atom bonded to 5 carbon atoms
(define invalid-carbon2
  (new atom% 'carbon (new cons-bond% 1 (new atom% 'carbon 
                         (new cons-bond% 2 (new atom% 'carbon
                              (new cons-bond% 5 (new atom% 'carbon empty-bond)
                                   empty-bond))
                              empty-bond))
                         empty-bond))) 
; carbon chain with 1 carbon w/ 5 bonds at the end
(define invalid-carbon3 
  (new atom% 'carbon (new cons-bond% 1 (new atom% 'carbon empty-bond)
                          (new cons-bond% 1 (new atom% 'carbon 
                                                 (new cons-bond% 5 
                                                      (new atom% 'carbon
                                                           empty-bond)
                                                      empty-bond))
                               empty-bond))))
; combination of the two examples above




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

;; Additional Tests ------------------------------------------------------------

;; Tests for on-key

(check-expect ((new world% player-1 player-1 BALL-START) . on-key "w")
              (new world% (new player% 50 (- SCENE-HALF-HEIGHT 10) 10 score0)
                   player-1 BALL-START))

(check-expect ((new world% player-1 player-1 BALL-START) . on-key "s")
              (new world% (new player% 50 (+ SCENE-HALF-HEIGHT 10) 10 score0)
                   player-1 BALL-START))

(check-expect ((new world% player-1 player-1 BALL-START) . on-key "up")
              (new world% player-1 (new player% 50 (- SCENE-HALF-HEIGHT 10) 10 
score0)
                   BALL-START))

(check-expect ((new world% player-1 player-1 BALL-START) . on-key "down")
              (new world% player-1 (new player% 50 (+ SCENE-HALF-HEIGHT 10) 10 
score0)
                   BALL-START))

(check-expect ((new world% player-1 player-1 BALL-START) . on-key "left")
              (new world% player-1 player-1 BALL-START))

;; Test for on-tick
(check-expect ((new world% player-1 player-1 BALL-START) . on-tick)
              (new world% player-1 player-1 
                   (new ball% BALL-RADIUS "white" 
                   (make-rectangular (+ 3 SCENE-HALF-WIDTH) 
(+ 5 SCENE-HALF-HEIGHT)) 
                   (make-rectangular 3 5))))

;; Test for to-draw
(check-expect (initial-world . to-draw)
              (place-image (circle BALL-RADIUS "solid" "white")
                           SCENE-HALF-WIDTH
                           SCENE-HALF-HEIGHT
                           (place-image (text "0" 80 "blue")
                                        (- SCENE-WIDTH 50) 50
                                        (place-image PLAYER
                                                     (- SCENE-WIDTH 100)
                                                     SCENE-HALF-HEIGHT
                                                     (place-image 
                                                      (text "0" 80 "red")
                                                                  50 50
                                                                  (place-image 
                                                                   PLAYER 100
                               SCENE-HALF-HEIGHT SCENE))))))
                                                     
;; Big Bang --------------------------------------------------------------------

(define initial-world (new world% PLAYER1 PLAYER2 BALL-START))

(big-bang initial-world)


