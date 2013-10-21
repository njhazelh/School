;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname lab2rewrite) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Lab 2 Rewrite
Nicholas Jones
9/18/2012
|#
#|
;; Exercise 1
(define-struct animal (name species age b-hour d-hour))

;; Some test constants to use later
(define test-animal1 (make-animal "a" "dog" 3 7 17))
(define test-animal2 (make-animal "b" "cat" 7 8 16))
(define test-animal3 (make-animal "c" "t-rex" 2000000 8 16))

#|
Data Definition:
Animal is a (make-animal String String Number Number Number)
where:
name is the name of the animal
species is the species of the animal
age is the age of the animal in years
b-hour is the breakfast hour of the animal
d-hour is the dinner hour of the animal

Template:
(define (animal-template an-animal)
    (...  (animal-name an-animal)    ...
          (animal-species an-animal) ...
          (animal-age an-animal) ...
          (animal-b-hour an-animal)  ...
          (animal-d-hour an-animal)  ...))

Examples: ....

|#

;;Exercise 2
(define-struct staff (name anim1 anim2 anim3))

;; Some test constants to be used later on
(define test-staff1 (make-staff "Bob" test-animal1 test-animal2 test-animal3))
(define test-staff2 (make-staff "Bill" test-animal1 test-animal2 test-animal3))
(define test-staff3 (make-staff "Bonny" test-animal1 test-animal2 test-animal3))

#|
Data Definition:
Staff is a (make-staff String Animal Animal Animal)
where:
name is the name of the staff member
anim1 is the first animal under the staff-member's care
anim2 is the second animal under the staff-member's care
anim3 is the third animal under the staff-member's care

Template:
(define (staff-template a-staff)
    (... (staff-name a-staff)  ...
         (staff-anim1 a-staff) ...
         (staff-anim2 a-staff) ...
         (staff-anim3 a-staff) ...))

Examples: ....

|#

;;Exercise 3
(define-struct zone (type cleaner num-animals))

;;
(define z1 (make-zone 'Birds "Bill" 120))
(define z2 (make-zone 'Reptiles "Larry" 200))
(define z3 (make-zone 'Mammals "Ben" 50))

#|
Data Definition:
Zone is a (make-zone Zone-Type String Number)
where:
type is the type of the zone
cleaner is the name of the staff member who cleans the zone
num-animals is the number of animals in the zone

A Zone-Type is one of:
  -- 'Birds
  -- 'Reptiles
  -- 'Mammals

Template:
(define (zone-template a-zone)
    (... (zone-type a-zone)        ...
         (zone-cleaner a-zone)     ...
         (zone-num-animals a-zone) ...))

Examples:  ....
|#

;; Exercise 4
;; I already did this

;; Exercise 5
;; I already did this

;; Exercise 6
;; Contract: animal-birthday: Animal -> Animal
;; Purpose: Takes an animal and returns the same animal, one year older
(define (animal-birthday an-animal)
  (make-animal (animal-name an-animal)
               (animal-species an-animal)
               (add1 (animal-age an-animal))
               (animal-b-hour an-animal)
               (animal-d-hour an-animal)))

;; Tests
(check-expect (animal-age (animal-birthday test-animal1)) (add1 (animal-age test-animal1)))
(check-expect (animal-age (animal-birthday test-animal2)) (add1 (animal-age test-animal2)))
(check-expect (animal-age (animal-birthday test-animal3)) (add1 (animal-age test-animal3)))

;; Exercise 7
;; Contract: is-feeding-time?: Animal Number --> Boolean
;; Takes an animal and an hour, and returns true if
;; it is feeding time or false if it is not.
(define (is-feeding-time? an-animal hour)
  (or (= (animal-b-hour an-animal) hour)
      (= (animal-d-hour an-animal) hour)))

;; Tests
(check-expect (is-feeding-time? test-animal1 7) true)
(check-expect (is-feeding-time? test-animal1 17) true)
(check-expect (is-feeding-time? test-animal1 8) false)

;; Exercise 8
;; Contract: make-dog-years: Animal -> Animal
;; Takes and Animal and converts its age to dog years (* 7 years)
(define (make-dog-years an-animal)
  (make-animal (animal-name an-animal)
               (animal-species an-animal)
               (* 7 (animal-age an-animal))
               (animal-b-hour an-animal)
               (animal-d-hour an-animal)))

;; Tests
(check-expect (animal-age (make-dog-years test-animal1)) (* 7  (animal-age test-animal1)))
(check-expect (animal-age (make-dog-years test-animal2)) (* 7  (animal-age test-animal2)))
(check-expect (animal-age (make-dog-years test-animal3)) (* 7  (animal-age test-animal3)))

;; Exercise 9
;; Contract: total-animal-ages: Staff -> Number
;; Purpose: Adds all the ages of the Animals under the care
;; of the given staff member, and returns the sum.
;; Example: 
;; (total-animal-ages (make-staff ... (make-animal ... 3 ...) (make-animal ... 4 ...) (make-animal ... 5 ...))) --> 12
(define (total-animal-ages a-staff)
  (+ (animal-age (staff-anim1 a-staff))
     (animal-age (staff-anim2 a-staff))
     (animal-age (staff-anim3 a-staff))))

;; A Test
(check-expect (total-animal-ages test-staff1) 2000010)

;; Exercise 10
(define-struct live-album (name year-rec year-pub))
(define-struct studio-album (name year-pub))

(define test-l-album (make-live-album "Love" 1970 1971))
(define test-s-album (make-studio-album "Heights of the Heavens" 2008))

#|
Data Definition:
A Music-Album is one of:
 -- Live-Album
 -- Studio-Album

A Live-Album is a (make-live-album String Number Number)
where:
name is the name of the album
year-rec is the year of recording
year-pub is the year of publication

A Studio-Album is a (make-studio-album String Number)
where:
name is the name of the album
year-pub is the year of publication

Template:
(define (music-album-template an-album)
    (cond [(live-album? an-album) ... (live-album-name an-album) ...
                                      (live-album-year-pub an-album) ...]
          [studio-album? an-album) ... (studio-album-name an-album) ...
                                       (studio-album-year-rec an-album) ...
                                       (studio-album-year-pub an-album) ...])

Examples: ...
|#

;; Exercise 11
(define-struct comp-unpub (serial name release-date)) 
(define-struct incomp-unpub (serial))

(define test-compl-album (make-comp-unpub 239048750984 ">Name Here<" "09/30/12"))
(define test-incompl-album (make-incomp-unpub 2309485))

#|
Data Definition:
An Unpublished-Album is on of:
 -- Incomplete-Album
 -- Complete-Album

An Incomplete-Album is a (make-incomp-album Number)
where:
serial is the serial number of the album

A Complete-Album is a (make-comp-album Number String Date)
where:
serial is the serial number of the album
name is the name of the album
release-date is the release-date of the album

A Date is a String with the format MM/DD/YY

Template:
(define (unpublished-album-template album)
    (cond [(incomp-album? album) ... (incompl-album-serial album) ...]
          [(comp-album?   album) ... (comp-album-serial album) ...
                                     (comp-album-name album) ...
                                     (comp-album-release-date album) ...]))

Examples: ....
|#

;; Exercise 12
;; Contract: finish-album: Unpublished-Album String Date -> Complete-Album
;; Purpose: Completes the given album if incomplete by adding a name and release-date
(define (finish-album unpub-album name release-date)
  (cond [(incomp-unpub? unpub-album) (make-comp-unpub (incomp-unpub-serial unpub-album)
                                                      name
                                                      release-date)]
        [else unpub-album]))

;; Check expects should be here to test if output is correct
;; but I'm lazy and writing tests for structures is annoying
|#
;; Exercise 13
(define-struct world (blue-posn red-posn))
#|
Data Defintion:
A World is a (make-world Posn Posn)

Template:
(define (world-template world)
    ... (world-blue-posn world) ...
        (world-red-posn world) ...)
|#

;; Contract: mouse-click: World Number Number MouseEvent -> World
;; Purpose: If the mouse event is "button-down" then it sets the
;; red-posn as the location of the mouse click
(define (mouse-click world x y me)
  (cond [(string=? me "button-down") (make-world (world-blue-posn world)
                                                (make-posn x y))]
        [else world]))

;; Tests
(check-expect (mouse-click (make-world (make-posn 3 4)
                                       (make-posn 9 8))
                           2
                           3
                           "button-down")
              (make-world (make-posn 3 4)
                          (make-posn 2 3)))
(check-expect (mouse-click (make-world (make-posn 3 4)
                                       (make-posn 9 8))
                           2
                           3
                           "button-up")
              (make-world (make-posn 3 4)
                          (make-posn 9 8)))

;; Exercise 15
;; Contract: tick: World -> World
;; Purpose: slowly brings the circles together at a rate of 2 pixels per tick
;;          by moving the red-circle directly towards the other circle
#|
Thoughts:
dx = blueX - redX
dy = blueY - redY

theta = arctan(dy/dx)
moveX= cos(arctan((blueY-redY)/(blueX-redX)))*PIXELS_ALONG_R
moveY= sin(arctan((blueY-redY)/(blueX-redX)))*PIXELS_ALONG_R
|#
(define (tick world)
  (make-world (world-blue-posn world)
              (make-posn (inexact->exact (round (* 2 (cos (atan (/ (- (posn-y (world-red-posn world)) 
                                                                        (posn-y (world-blue-posn world)))
                                                                     (- (posn-x (world-red-posn world)) 
                                                                        (posn-x (world-blue-posn world)))))))))
                         (inexact->exact (round (* 2 (sin (atan (/ (- (posn-y (world-red-posn world)) 
                                                                        (posn-y (world-blue-posn world)))
                                                                     (- (posn-x (world-red-posn world)) 
                                                                        (posn-x (world-blue-posn world))))))))))))

(check-expect (tick (make-world (make-posn 2 2) (make-posn 0 0))) (make-world (make-posn 2 2) (make-posn 2 2)))
(check-expect (tick (make-world (make-posn 4 4) (make-posn 0 0))) (make-world (make-posn 4 4) (make-posn 2 2)))
(check-expect (tick (make-world (make-posn -4 -4) (make-posn 0 0))) (make-world (make-posn -4 -4) (make-posn -2 -2)))
