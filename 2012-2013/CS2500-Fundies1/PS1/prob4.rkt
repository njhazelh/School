;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname prob4) (read-case-sensitive #t) (teachpacks ((lib "convert.ss" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "convert.ss" "teachpack" "htdp")))))
;; author: Nicholas Jones
;; date: 9/9/2012

;; Define Constants
(define tuitionPerYear 39320)
(define roomAndBoardPerYear 13140)
(define mandatoryFeesPerYear 766)
(define semestersPerYear 2)
(define classesPerSemester 4)
(define lecturesPerWeek 3)
(define weeksPerSemester 13)

;; Define MetaConstants

;; Analyse constants to find cost per semester
;; (tuition + roomAndBoard + fees)/semestersPerYear
(define CostPerSemester (/ (+ tuitionPerYear roomAndBoardPerYear mandatoryFeesPerYear) semestersPerYear))

;; Analyse constants to find lectures per semester
;; classesPerSemester * lecturesPerWeek * weeksPerSemester
(define LecturesPerSemester (* classesPerSemester lecturesPerWeek weeksPerSemester))

;; Analyse constants to find cost per lecture
;; costPerSemester / lecturesPerSemester
(define CostPerLecture (/ CostPerSemester LecturesPerSemester))