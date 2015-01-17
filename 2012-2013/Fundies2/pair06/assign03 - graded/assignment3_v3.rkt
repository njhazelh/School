#lang class/1
(require 2htdp/image)
(require class/universe)

;;;;;;;;;;;;;;;;;;
;; Assignment 3 ;;
;; Tiffany Chao ;;
;; Nick Jones ;;;;
;;;;;;;;;;;;;;;;;;

;; "Super Classes" for Assignment 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#|

Super classes seem to have been removed from the assignment.
This file needs templates.

|#
;; Exercise 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Definitions

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
  (check-expect (boss2 . full-unit) cons-LoE2)
  
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
  
  (check-expect (cons-LoE1 . append empty-LoE) cons-LoE1)
  (check-expect (cons-LoE1 . append cons-LoE1) (new cons-LoE% worker1
                                                    (new cons-LoE% worker1 empty-LoE)))
  
  ; rest-LoE: ILoE -> ILoE
  ; creates new ILoE from (field rest)
  (define (rest-LoE)
    ((field rest) . append empty-LoE))
  
  (check-expect (cons-LoE1 . rest-LoE) empty-LoE)
  (check-expect (cons-LoE2 . rest-LoE) cons-LoE1))

;; An empty-LoE is a (new empty-LoE%)
;; Interp: the empty list
(define-class empty-LoE%
  
  ; append: ILoE -> ILoE
  ; returns x
  (define (append x) x)
  
  (check-expect (empty-LoE . append empty-LoE) empty-LoE)
  (check-expect (empty-LoE . append cons-LoE1) cons-LoE1)
  
  ; rest-LoE: ILoE -> ILoE
  ; returns empty list
  (define (rest-LoE) this)
  
  (check-expect (empty-LoE . rest-LoE) empty-LoE))

;; Examples

(define empty-LoE (new empty-LoE%)) ; empty ILoE

(define worker1 (new worker% "Joe" 2))
(define worker2 (new worker% "Kate" 3))
(define cons-LoE1 (new cons-LoE% worker1 empty-LoE))
(define cons-LoE2 (new cons-LoE% worker2 cons-LoE1))
(define boss1 (new boss% "Teresa" "Unit1" 4 empty-LoE)) ; no peons 
(define boss2 (new boss% "Steve" "Unit1" 4 cons-LoE2))

;; Exercise 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Definitions

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
  (fields a-list)
  
  ;; total-offense : -> Number
  ;; records the number of yards gained by the team that started with the ball
  (define (total-offense)
    (local ((define (select-team x) ((first x) . team))
            (define (filter-team x)
              (filter (λ (y) (symbol=? (y . team) (select-team x))) x))
            (define (add-yards x)
              (cond [(empty? x) 0]
                    [else (+ (abs (- ((first x) . end) ((first x) . start))) 
                             (add-yards (rest x)))])))
      (add-yards (filter-team (field a-list)))))
  
  (check-expect ((new game% empty) . total-offense) 0)
  (check-expect (game1 . total-offense) 180)
  (check-expect (game2 . total-offense) 100)
  
  ;; total-score : -> Number
  ;; records the total number of points scored by both teams
  (define (total-score)
    (cond [(empty? (field a-list)) 0]
          [(number? ((first (field a-list)) . result))
           (+ ((first (field a-list)) . result)
              ((new game% (rest (field a-list))) . total-score))]
          [else ((new game% (rest (field a-list))) . total-score)]))
  
  (check-expect ((new game% empty) . total-score) 0)
  (check-expect (game1 . total-score) 17)
  (check-expect (game2 . total-score) 14))

;; Examples

(define possession1 (new possession% 'team1 20 50 true))
(define possession2 (new possession% 'team2 80 0 7))
(define possession3 (new possession% 'team2 70 50 true))
(define possession4 (new possession% 'team1 30 100 7))
(define possession5 (new possession% 'team1 20 100 3))
(define game1 
  (new game% 
       (list possession1 possession2 possession3 possession4 possession5)))
(define game2
  (new game% (list possession2 possession3 possession4))) ; 'team2 starts first

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

;; Note: These should be helper methods

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
;; - (new cons-num% Number ListNum)
;; and implements:
;; last (helper method) : -> Listnum
;; returns last element in ListNum
;; all-but-last (helper method) : -> ListNum
;; returns all but last element in ListNum
;; reverse : -> ListNum
;; produces new ListNum with elements in reverse order

(define-class empty-num%
  
  ; append : ListNum -> ListNum
  ; returns x
  (define (append x) x)
  
  (check-expect (empty-num . append empty-num) empty-num)
  (check-expect (empty-num . append cons-num1) cons-num1)
  
  ; last : -> Listnum
  ; returns empty-num  
  (define (last) empty-num)
  
  (check-expect (empty-num . last) empty-num)
  
  ; all-but-last : -> ListNum
  ; returns empty-num
  (define (all-but-last) empty-num)
  
  (check-expect (empty-num . all-but-last) empty-num)
  
  ; reverse : -> ListNum
  ; returns empty-num
  (define (reverse) empty-num)
  
  (check-expect (empty-num . reverse) empty-num))

(define-class cons-num%
  (fields first rest)
  
  ; append : ListNum -> ListNum
  ; appends two ListNums to create new ListNum
  (define (append x)
    (cond [(equal? x empty-num) this]
          [else (new cons-num% (field first) 
                     ((field rest) . append x))]))
  
  (check-expect (cons-num1 . append empty-num) cons-num1)
  (check-expect (cons-num1 . append (new cons-num% -7 empty-num))
                (new cons-num% 7 (new cons-num% -7 empty-num)))
  
  ; last : -> ListNum
  ; Interp: returns last element in ListNum
  (define (last)
    (cond [(and (number? (field first)) 
                (equal? empty-num (field rest))) this]
          [else ((new cons-num% ((field rest) . first) ((field rest) . rest))
                 . last)]))
  
  (check-expect (cons-num1 . last) cons-num1)
  (check-expect (cons-num2 . last) (new cons-num% 1 empty-num))
  
  ; all-but-last : -> ListNum
  ; Interp: returns all but the last cons-num in ListNum
  (define (all-but-last)
    (cond [(and (number? (field first)) 
                (equal? empty-num (field rest))) empty-num]
          [else (new cons-num% (field first) ((field rest) . all-but-last))]))
  
  (check-expect (cons-num1 . all-but-last) empty-num)
  (check-expect (cons-num2 . all-but-last)
                (new cons-num% 5
                     (new cons-num% 4
                          (new cons-num% 3
                               (new cons-num% 2 empty-num)))))
  
  ; reverse : -> ListNum
  ; produces new ListNum with elements in reverse order
  (define (reverse)
    (local ((define (reverse-acc x acc)
              (cond [(equal? x empty-num) acc]
                    [else (reverse-acc (x . all-but-last) 
                                       (acc . append (x . last)))])))
      (reverse-acc this empty-num)))
  
  (check-expect (cons-num1 . reverse) cons-num1)
  (check-expect (cons-num2 . reverse)
                (new cons-num% 1
                     (new cons-num% 2
                          (new cons-num% 3
                               (new cons-num% 4
                                    (new cons-num% 5 empty-num)))))))

;; Examples

(define empty-num (new empty-num%))
(define cons-num1 (new cons-num% 7 empty-num))
(define cons-num2 (new cons-num% 5
                       (new cons-num% 4
                            (new cons-num% 3
                                 (new cons-num% 2
                                      (new cons-num% 1 empty-num))))))

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

;; Exercise 8 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Interfaces

;; An IPerson implements:
;; next : -> Person
;; ages the Person
;; Note: A child becomes an adult at 25, an adult becomes a senior at 65,
;; and a senior dies at 90

;; Definitions

;; A Person is one of:
;; - (new child% Age)
;; - (new adult% Age)
;; - (new senior% Age)
;; - (new ghost%)

;; Age is a Number and positive integer

(define-class ghost%
  
  ; next : -> Person
  ; returns ghost
  (define (next) ghost)
  
  (check-expect (ghost . next) ghost))

(define-class senior%
  (fields age)
  
  ; next : -> Person
  ; ages the Person
  (define (next)
    (cond [(>= (add1 (field age)) 90) ghost]
          [else (new senior% (add1 (field age)))]))
  
  (check-expect (senior1 . next) (new senior% 71))
  (check-expect (senior2 . next) ghost))

(define-class adult%
  (fields age)
  
  ; next : -> Person
  ; ages the Person
  (define (next)
    (cond [(>= (add1 (field age)) 65) (new senior% (add1 (field age)))]
          [else (new adult% (add1 (field age)))]))
  
  (check-expect (adult1 . next) (new adult% 31))
  (check-expect (adult2 . next) (new senior% 65)))

(define-class child%
  (fields age)
  
  ; next : -> Person
  ; ages the Person
  (define (next)
    (cond [(>= (add1 (field age)) 25) (new adult% (add1 (field age)))]
          [else (new child% (add1 (field age)))]))
  
  (check-expect (child1 . next) (new child% 11))
  (check-expect (child2 . next) (new adult% 25)))

;; A Population is one of:
;; - (cons-pop% Person Population)
;; - (new empty-pop%)

(define-class empty-pop%
  
  ; filter-ghost : -> Population
  ; returns empty-pop
  (define (filter-ghost) empty-pop)
  
  (check-expect (empty-pop . filter-ghost) empty-pop)
  
  ; age-all : -> Population
  ; returns empty-pop
  (define (age-all) empty-pop)
  
  (check-expect (empty-pop . age-all) empty-pop)
  
  ; max-age : -> Popuation
  ; returns 0
  (define (max-age) 0)
  
  (check-expect (empty-pop . max-age) 0)
  
  ; half-working : -> Population
  ; returns empty-pop
  (define (half-working) empty-pop)
  
  (check-expect (empty-pop . half-working) empty-pop))

(define-class cons-pop%
  (fields first rest)
  
  ; filter-ghost : -> Population
  ; filters ghosts from population
  (define (filter-ghost)
    (cond [(equal? this empty-pop)(empty-pop . filter-ghost)]
          [(equal? (field first) ghost)((field rest) . filter-ghost)]
          [else (new cons-pop% (field first) ((field rest) . filter-ghost))]))
  
  (check-expect (population1 . filter-ghost) population1)
  (check-expect (population4 . filter-ghost) empty-pop)
  
  ; age-all : -> Population
  ; ages all Persons by one year
  (define (age-all)
    (cond [(equal? this empty-pop)(empty-pop . age-all)]
          [else ((new cons-pop% ((field first) . next) 
                      ((field rest) . age-all)) . filter-ghost)]))
  
  (check-expect (population1 . age-all)
                (new cons-pop% (new child% 11)
                     (new cons-pop% (new adult% 31)
                          (new cons-pop% (new senior% 71) empty-pop))))
  (check-expect (population2 . age-all)
                (new cons-pop% (new child% 11) empty-pop))
  
  ; max-age : -> Age
  ; computes the age of the oldest person
  (define (max-age)
    (local ((define (max-age-acc x acc)
              (cond [(equal? x empty-pop) acc]
                    [(>= acc (x . first . age))
                     (max-age-acc (x . rest) acc)]
                    [else (max-age-acc (x . rest) (x . first . age))])))
      (max-age-acc this ((field first) . age))))
  
  (check-expect (population1 . max-age) 70)
  (check-expect ((new cons-pop% child2 
                      (new cons-pop% senior2
                           (new cons-pop% adult2 empty-pop))) ; out of order 
                 . max-age) 89)
  
  ; half-working : -> Population
  ; ages the population until there are half as many adults
  ; as there were to start with
  (define (half-working)
    (local ((define (count-adults x)
              (cond [(equal? x empty-pop) 0]
                    [(or (equal? (x . first) ghost)
                         (<= (x . first . age) 24)
                         (>= (x . first . age) 65))
                     (count-adults (x . rest))]
                    [else (add1 (count-adults (x . rest)))]))
            (define (half-working-acc y initial) ; initial # of adults
              (cond [(= (count-adults y) (round (/ initial 2))) y]
                    [else (half-working-acc (y . age-all) initial)])))
      (half-working-acc this (count-adults this))))
  
  (check-expect ((new cons-pop% adult1 (new cons-pop% adult2 empty-pop))
                 . half-working) (new cons-pop% (new adult% 31)
                                      (new cons-pop% (new senior% 65)
                                           empty-pop)))
  (check-expect (population3 . half-working)
                (new cons-pop% (new child% 16)
                     (new cons-pop% (new senior% 75)
                          (new cons-pop% (new senior% 65)
                               (new cons-pop% (new adult% 55)
                                    (new cons-pop% (new adult% 45)
                                         empty-pop)))))))

;; Examples

(define child1 (new child% 10))
(define child2 (new child% 24))
(define adult1 (new adult% 30))
(define adult2 (new adult% 64))
(define senior1 (new senior% 70))
(define senior2 (new senior% 89))
(define ghost (new ghost%))

(define empty-pop (new empty-pop%))
(define population1 (new cons-pop% child1
                         (new cons-pop% adult1
                              (new cons-pop% senior1 empty-pop))))
(define population2 (new cons-pop% child1
                         (new cons-pop% senior2 empty-pop)))
(define population3 (new cons-pop% (new child% 1)
                         (new cons-pop% (new adult% 60)
                              (new cons-pop% (new adult% 50)
                                   (new cons-pop% (new adult% 40)
                                        (new cons-pop% (new adult% 30)
                                             empty-pop))))))
(define population4 (new cons-pop% ghost empty-pop)) ; no population

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

(define-class empty-bond%)

(define-class cons-bond%
  (fields bond-type atom-type rest))

;; An Atom is a (new atom% Symbol Bond) and is one of:
;; - (new atom% 'carbon Bond) Interp: carbon atom
;; - (new atom% 'hydrogen Bond) Interp: hydrogen atom

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
                                          
                           
                            
                    












