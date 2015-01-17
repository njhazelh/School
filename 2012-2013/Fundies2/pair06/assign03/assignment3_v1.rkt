#lang class/1

;;;;;;;;;;;;;;;;;;
;; Assignment 3 ;;
;; Tiffany Chao ;;
;; Nick Jones ;;;;
;;;;;;;;;;;;;;;;;;

;; "Super Classes" for Assignment 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add to this in next update

;; Exercise 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A Mobile is one of: 
;; - (new node% Symbol Number Number Number Mobile Mobile)
;; - (new object% Symbol Number Number String)

;; type: is the mobile a node or an object?
;; line represents the vertical support of the mobile, represented by length n
;; l-strut is the strut on the left side of the mobile, represented by length n
;; r-strut is the strut on the right side of the mobile, represented by length n
;; weight is the weight of the object
;; color is the color of the object

(define-class object%
  (fields type line weight color)
  
  ; -> Number
  ; computes total weight of an object
  ; a line of length n has weight n
  (define (total-weight)
    (+ (field line) (field weight)))
  
  (check-expect (mobile1 . total-weight) 11)
  
  ; -> Number
  ; computes height of an object
  (define (height) (field line))
  
  (check-expect (mobile1 . height) 1))

(define-class node%
  (fields type line l-strut r-strut left right)
  
  ; -> Number
  ; computes total weight of a mobile
  ; a line/strut of length n has weight n
  (define (total-weight)
    (cond [(symbol=? (field type) 'object) (this . total-weight)]
          [else (+ (field line) 
                   (field l-strut)
                   (field r-strut)
                   ((field left) . total-weight)
                   ((field right) . total-weight))]))
  
  (check-expect (mobile2 . total-weight) 75)
  (check-expect (example . total-weight) 153)
  
  ; -> Number
  ; computes total height of a mobile
  (define (height)
    (cond [(symbol=? (field type) 'object) (this . height)]
          [(> (this . left . height) (this . right . height))
           (+ (field line) (this . left . height))]
          [else (+ (field line) (this . right . height))])) 
  
  (check-expect (mobile2 . height) 3)
  (check-expect (example . height) 7))

;; Examples
;; Representation of given example of a mobile:
(define example (new node% 
                     'node 1 6 6 
                     (new object% 'object 1 60 "blue")
                     (new node% 'node 2 6 4 
                          (new node% 'node 2 2 4 
                               (new object% 'object 1 10 "green") 
                               (new object% 'object 2 5 "red"))
                          (new object% 'object 1 40 "red"))))

(define mobile1 (new object% 'object 1 10 "red"))
(define mobile2 (new node% 'node 1 2 2
                     (new node% 'node 1 3 3 
                          (new object% 'object 1 20 "blue")
                          (new object% 'object 1 30 "green"))
                     mobile1))

;; Exercise 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Interfaces

;; An Emp or employee implements
;; count-subs : -> Number
;; computes total number of suborninates of this employee
;; full-unit : -> ILoE
;; collects all of the subordinates of this employee
;; has-peon? : String -> Boolean
;; determines if this employee has a peon with the given name

;; An ILoE or list of employees implements
;; append: ILoE -> ILoE
;; appends two lists of employees to create one list
;; rest-LoE: ILoE -> ILoE
;; creates new ILoE from (field rest)

;; Definitions

;; A Worker is a (new worker% String Number)
;; name is the name of the worker
;; tasks is the number of tasks assigned to worker
(define-class worker%
  (fields name tasks)
  
  ; count-subs : -> Number
  ; computes total number of suborninates of this employee
  (define (count-subs) 0)
  
  (check-expect (send worker1 count-subs) 0) 
  
  ; full-unit : -> ILoE
  ; collects all of the subordinates of this employee
  (define (full-unit) empty-LoE)
  
  (check-expect (send worker1 full-unit) empty-LoE)
  
  ; has-peon? : String -> Boolean
  ; determines if this employee has a peon with the given name
  (define (has-peon? n) false)
  
  (check-expect (send worker1 has-peon? "Steve") false))

;; A Boss is a (new boss% String String Number ILoE)
;; name is the name of the boss
;; unit is the name of the unit the boss is assigned to
;; tasks is the number of tasks assigned to boss
;; peons represents the employees under boss
(define-class boss%
  (fields name unit tasks peons)
  
  ; count-subs : -> Number
  ; computes total number of suborninates of this employee
  (define (count-subs)
    (cond [(equal? (field peons) empty-LoE) 0]
          [else (add1 ((new boss%
                            (field name)
                            (field unit)
                            (field peons)
                            ((field peons) . rest-LoE)) . count-subs))]))
  
  (check-expect (boss1 . count-subs) 0)
  (check-expect (boss2 . count-subs) 2)
  
  ; full-unit : -> ILoE
  ; collects all of the subordinates of this employee
  (define (full-unit)(field peons))
  
  (check-expect (boss1 . full-unit) empty-LoE)
  (check-expect (boss2 . full-unit) cons2)
    
  ; has-peon? : String -> Boolean
  ; determines if this employee has a peon with the given name
  (define (has-peon? n)
    (cond [(equal? (field peons) empty-LoE) false] 
      [(string=? n ((field peons) . first . name)) true]
          [else ((new boss% 
                      (field name)
                      (field unit)
                      (field tasks)
                      ((field peons) . rest-LoE)) . has-peon? n)]))
  
  (check-expect (boss1 . has-peon? "Joe") false)
  (check-expect (boss2 . has-peon? "Joe") true))

;; A cons-LoE is a (new cons-LoE% ILoE ILoE)
;; Interp: first is first employee in list, rest is rest of employees in list
(define-class cons-LoE%
  (fields first rest)
  
  ; append: ILoE -> ILoE
  ; appends two lists of employees to create one list
  (define (append x)
    (cond [(equal? x empty-LoE) this]
          [else (new cons-LoE% (field first) ((field rest) . append x))]))
  
  (check-expect (cons1 . append empty-LoE) cons1)
  (check-expect (cons1 . append cons1) (new cons-LoE% worker1
                                            (new cons-LoE% worker1 empty-LoE)))
  
  ; rest-LoE: ILoE -> ILoE
  ; creates new ILoE from (field rest)
  (define (rest-LoE)
   ((field rest) . append empty-LoE))
  
  (check-expect (cons1 . rest-LoE) empty-LoE)
  (check-expect (cons2 . rest-LoE) cons1))

;; An empty-LoE is a (new empty-LoE%)
;; Interp: the empty list
(define-class empty-LoE%
  ; append: ILoE -> ILoE
  ; returns x
  (define (append x) x)
  
  (check-expect (empty-LoE . append empty-LoE) empty-LoE)
  (check-expect (empty-LoE . append cons1) cons1)
  
  ; rest-LoE: ILoE -> ILoE
  ; returns empty list
  (define (rest-LoE) this)
  
  (check-expect (empty-LoE . rest-LoE) empty-LoE))
  
;; Examples

(define empty-LoE (new empty-LoE%)) ; empty ILoE

(define worker1 (new worker% "Joe" 2))
(define worker2 (new worker% "Kate" 3))
(define cons1 (new cons-LoE% worker1 empty-LoE))
(define cons2 (new cons-LoE% worker2 cons1))
(define boss1 (new boss% "Teresa" "Unit1" 4 empty-LoE)) ; no peons 
(define boss2 (new boss% "Steve" "Unit1" 4 cons2))

;; Exercise 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Definitions

;; I wasn't sure about the wording of Exercise 3 so I emailed a professor to 
;; check that I had the correct definition. Meanwhile I moved on to Exercises 
;; 4 and 5.

;; A FootballGame is a (new game% [listof Possession])

;; A Possession is a (new possession% Symbol Number Number Result)

;; team represents which team ('Team1 or 'Team2) is in possession of the ball
;; for the duration of this Possession.
;; start is where the Possession starts on the field (a yard from 0 to 100)
;; end is where the Possession ends on the field (a yard from 0 to 100)

;; A Result is one of:
;; - Number
;; - Boolean
;; The score can either be 3 or 7 points.
;; if Result is true, next Possession in [listof Possession] will be in 
;; possession of the opposing team

(define-class possession%
  (fields team start end result))

(define-class game%
  (fields a-list))
        
;; Examples

(define possession1 (new possession% 'team1 20 50 true))
(define possession2 (new possession% 'team2 80 0 7))
(define possession3 (new possession% 'team2 70 50 true))
(define possession4 (new possession% 'team1 30 100 7))
(define possession5 (new possession% 'team1 20 100 3))
(define game1 
  (list possession1 possession2 possession3 possession4 possession5))
 
;; Exercise 4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Interfaces

;; A ITime implements:
;; minutes : -> Number
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
  
  ;; minutes : -> Number
  ;; converts this time to the number of minutes since midnight
  (define (minutes)
    (+ (* 60 (field hours)) (field mins)))
  
  (check-expect (time1 . minutes) 630))

;; An Event is a (new event% String Time Time)
;; Interp: an event with a name and a start and end time
(define-class event%
  (fields name start end)
  
  ;; duration : -> Number
  ;; computes the duration of this event in minutes
  (define (duration)
    (- ((field end) . minutes) ((field start) . minutes)))
  
  (check-expect (event1 . duration) 90)
  
  ;; ends-before? : Event -> Boolean
  ;; determines if this event ends before a given event starts
  (define (ends-before? x)
   (< ((field end) . minutes) (x . start . minutes)))
  
  (check-expect (event1 . ends-before? event2) false)
  (check-expect (event1 . ends-before? (new event% "Lunch2"
                                            (new time% 12 0)
                                            (new time% 2 0))) false)
  (check-expect (event1 . ends-before? event3) true)
  
  ;; overlap? : Event -> Boolean
  ;; determines whether this event overlaps with a given event
  (define (overlap? x)
    (not (this . ends-before? x)))
  
  (check-expect (event1 . overlap? event2) true)
  (check-expect (event1 . overlap? (new event% "Lunch2"
                                            (new time% 12 0)
                                            (new time% 2 0))) true)
  (check-expect (event1 . overlap? event3) false))

;; A Schedule is one of:
;; - (new no-event%)
;; - (new cons-event% Event Schedule)
(define-class no-event%
  
  ;; rest-event : -> Schedule
  ;; returns no-event
  (define (rest-event) no-event)
  
  (check-expect (no-event . rest-event) no-event)
  
  ;; append : Schedule
  ;; returns x
  (define (append x) x)
  
  (check-expect (no-event . append no-event) no-event)
  (check-expect (no-event . append schedule1) schedule1)
  
  ;; good? : -> Boolean
  ;; determines if the events in this schedule are in order
  ;; and do not overlap
  (define (good?) true)
  
  (check-expect (no-event . good?) true)
  
   ;; scheduled-time : -> Number
   ;; computes total time in minutes scheduled in this schedule
  (define (scheduled-time) 0)
  
  (check-expect (no-event . scheduled-time) 0)
  
  ;; free-time : -> Number
  ;; computes schedule of events named "Free time" that are all times 
  ;; NOT scheduled in this schedule
  (define (free-time)
    (new cons-event% (new event% "Free time" (new time% 0 0) (new time% 23 59))
         no-event)))
  
(define-class cons-event%
  (fields first rest)
  
  ;; rest-event : -> Schedule
  ;; creates new schedule from (field rest)
  (define (rest-event)
    (cond [(equal? (field rest) no-event) no-event]
          [else (new cons-event% ((field rest) . first) 
                     ((field rest) . rest))]))
  
  (check-expect ((new cons-event% event1 no-event) . rest-event) no-event)
  (check-expect (schedule1 . rest-event) (new cons-event% event3 no-event))
  
  ;; append : -> Schedule
  ;; appends two schedules to create new schedule
  (define (append x)
    (cond [(equal? x no-event) this]
          [else (new cons-event% (field first) 
                     ((field rest) . append x))]))
  
  (check-expect ((new cons-event% event1 no-event) 
                 . append (new cons-event% event3 no-event)) schedule1)
    
  ;; good? : -> Boolean
  ;; determines if the events in this schedule are in order
  ;; and do not overlap
  (define (good?)
      (cond [(equal? (field rest) no-event) (no-event . good?)]
            [(and (< ((field first) . end . minutes) 
                     ((field rest) . first . start . minutes))
                  ((field first) . ends-before? 
                                 ((field rest) . first)))
             ((this . rest-event) . good?)]
            [else false]))
  
  (check-expect (schedule1 . good?) true)
  (check-expect (schedule2 . good?) false)
  (check-expect (schedule3 . good?) false)
  
  ;; scheduled-time : -> Number
  ;; computes total time in minutes scheduled in this schedule
  (define (scheduled-time)
    (+ ((field first) . duration) 
                   ((field rest) . scheduled-time)))
  
  (check-expect (schedule1 . scheduled-time) 390)
  
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

;; sub1-time : Time -> Time
;; subtracts 1 minute from Time
(define (sub1-time x)
  (cond [(and (not (zero? (x . hours)))
              (zero? (x . mins)))
         (new time% (sub1 (x . hours)) 59)]
        [else (new time% (x . hours) (sub1 (x . mins)))]))

;; add1-time : Time -> Time
;; adds 1 minute to Time
(define (add1-time x)
  (cond [(and (not (= 23 (x . hours)))
              (= 59 (x . mins)))
         (new time% (add1 (x . hours)) 0)]
        [else (new time% (x . hours) (add1 (x . mins)))]))

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

;; Exercise 5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A ListNum is one of:
;; - (new empty-num%)
;; - (new cons-num% ListNum)
;; and implements:
;; reverse : -> ListNum
;; produces new ListNum with elements in reverse order

(define-class empty-num%)
(define-class cons-num%
  (fields first rest))
