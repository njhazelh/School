;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname astar) (read-case-sensitive #t) (teachpacks ((lib "convert.ss" "teachpack" "htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "convert.ss" "teachpack" "htdp")))))
#|
Nicholas Jones
9/28/2012

This shall be my first attempt at an A*
path finding algorith using Racket.
Should this not work, I may try java or even
php. Hopefully, I have sufficient programming
knowledge to complete this puzzel.
|#

#|
Plan:

Need a:
 node that has a parent and a location. : node
 list of open nodes                     : open-set
 list of closed nodes                   : closed-set
 struct to contain all date             : algo-data

 function to calculate g
 function to calculate h
 function to add g and h to get f
 function that recurses while open-set is not empty
 function to sort lists
 function to find lowest f value in list

World to Work in:
 divided into square titles
 capable of having walls
 
 
|#

;; CONSTANTS
(define MOVE_COST 10)
(define SCENE_WIDTH 500)
(define SCENE_WIDTH 500)

;; Data Structures are informal and may change
(define-struct algo-data (open closed))
(define-struct node (posn parent g-cost walkable))

;; list->node : Number Number List -> Node
;; Purpose    : Finds a node in a list of nodes
;;              based on the x,y coord.
;; Examples   :
;;     TO COME
(define (list->node x y list)
  (cond
    [(empty? list) (error 'node-not-in-list list->node)]
    [(and (= x (node-x (first list)))
          (= y (node-y (first list))))
     (first list)]
    [else (list->node x y (rest list))]))

;; in-list? : Node List -> Boolean
;; Purpose  : Is a node in the list?
;; Examples :
;;    TO COME
(define (in-list? node list)
  (cond [(empty? list) false]
        [(and (equals? node
                       (first list))
              (equals? node
                       (first list))
              (not (in-list? node 
                             (rest list))))]))

;; g       : Number -> Number
;; Purpose : Simple function that adds the
;;           previous cost to the constant
;;           move cost to find g (move cost
;;           of a node)
(define (g parent-cost)
  (+ parent-cost MOVE_COST))

;; g       : Node -> Number
;; Purpose : Finds the heuristic cost of movement
;;           to this node.
(define (h )
  ;; fancy stuff
  )

(define (f parent-cost)
  (+ (g ) (h )))

;; analyse-neighbors : open-list closed-list Node Node-> open-list
#;
(define (analyse-neighbors ol cl map node fin)
  
  )

;; analyse-cheapest-node : List List List Posn -> completed-closed-list
;; Purpose               : This is the main algorithm loop.
;;                         Give it the current open-list, closed-list
;;                         and the map to work in.
(define (analyse-cheapest-node ol cl map fin)
  (cond [(or (in-list fin ol)
             (empty? ol))
         cl]
        [else (analyse-cheapest-node ;; need variables
  )

;; find-path : Posn Posn LoLoN -> List of nodes to take
;; Purpose   : This is the start point of the
;;             path finding algorithm.  Give it a
;;             start posn and an end posn, plus
;;             a list of the nodes to work in.
(define (find-path start finish map)
  (analyse-path (analyse-cheapest-node (cons start empty)
                                       cons
                                       map
                                       fin)))