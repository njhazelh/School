;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ps10) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
12/5/2012

PS 10h

---------------------------MY PARTNER DID NOTHING-------------------------------
Just saying. Didn't even contact me.

|#


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; posn-sum : [Listof Posn] -> Posn
;; Compute a posn whose x coordinate is the sum of the x coordinates in ps
;; and whose y coordinates is the sum of the y coordinates in ps
(define (posn-sum ps)
  (local ((define (posn-sum.acc list acc)
            (cond [(empty? list) acc]
                  [else (posn-sum.acc (rest list)
                                      (make-posn (+ (posn-x (first list))
                                                    (posn-x acc))
                                                 (+ (posn-y (first list))
                                                    (posn-y acc))))])))
    (posn-sum.acc ps (make-posn 0 0))))
;; Tests/Examples:
(check-expect (posn-sum empty)
              (make-posn 0 0))
(check-expect (posn-sum (list (make-posn 1 2)))
              (make-posn 1 2))
(check-expect (posn-sum (list (make-posn 1 2)
                              (make-posn 3 4)))
              (make-posn 4 6))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A Digit is a Number in the range [0-9]
;; digits->num : [Listof Digit] -> Number
;; Compute the number represented by the list of digits
(define (digits->num ds)
  (local ((define (digits->num.acc ds power sum)
            (cond [(empty? ds) sum]
                  [else (digits->num.acc (rest ds)
                                         (sub1 power)
                                         (+ sum (* (first ds)
                                                   (expt 10 power))))])))
    (digits->num.acc ds (sub1 (length ds)) 0)))
;; Tests/Examples:
(check-expect (digits->num (list 1 2 3)) 123)
(check-expect (digits->num empty) 0)
(check-expect (digits->num (list 1 2 3 4)) 1234)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A FamilyTree is either:
;; - empty
;; - (make-node String FamilyTree FamilyTree)
(define-struct node (name mom dad))

;; second? : FamilyTree -> Boolean
;; Determine if any child has the same name as an ancestor of theirs.
(define (second? ft)
  (local ((define (second?.acc ft decendants)
            (cond [(empty? ft) false]
                  [else (or (member? (node-name ft)
                                     decendants)
                            (second?.acc (node-mom ft)
                                         (cons (node-name ft)
                                               decendants))
                            (second?.acc (node-dad ft)
                                         (cons (node-name ft)
                                               decendants)))])))
    (second?.acc ft empty)))
;; Tests/Examples:
(check-expect (second? empty) false)
(check-expect (second? (make-node "bob" empty empty))
              false)
(check-expect (second? (make-node "bob"
                                  (make-node "mary"
                                             (make-node "rachel"
                                                        empty
                                                        empty)
                                             empty)
                                  empty))
              false)
(check-expect (second? (make-node "bob"
                                  (make-node "mary"
                                             (make-node ""
                                                        empty
                                                        empty)
                                             (make-node "bob"
                                                        empty
                                                        empty))
                                  empty))
              true)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;================================ GRAPHS ======================================;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A [Graph X] is:
;; (make-graph [Listof X] [X -> [Listof X]] [X X -> Boolean])
(define-struct graph (nodes neighbors node=?))

(define G1
  (make-graph '(A B C D E F G)
              (lambda (n)
                (cond [(symbol=? n 'A) '(B E)]
                      [(symbol=? n 'B) '(E F)]
                      [(symbol=? n 'C) '(D)]
                      [(symbol=? n 'D) '()]
                      [(symbol=? n 'E) '(C F A)]
                      [(symbol=? n 'F) '(D G)]
                      [(symbol=? n 'G) '()]))
              symbol=?))

(define G2 
  (make-graph '(A B C)
              (lambda (n)
                (cond [(symbol=? n 'A) '(B)]
                      [(symbol=? n 'B) '(A C)]
                      [(symbol=? n 'C) '(B)]))
              symbol=?))

(define G3 
  (make-graph '(A B C D E F G)
              (lambda (n)
                (cond [(symbol=? n 'A) '(C E)]
                      [(symbol=? n 'B) '(E F)]
                      [(symbol=? n 'C) '(D)]
                      [(symbol=? n 'D) '()]
                      [(symbol=? n 'E) '(C F A)]
                      [(symbol=? n 'F) '(D G)]
                      [(symbol=? n 'G) '()]))
              symbol=?))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; find-paths : [Graph X] X X -> [Listof [Listof X]]
;; Find all of the paths in the graph from src to dest
(define (find-paths g src dest)
  (local ((define (find-paths.acc current path-traveled)
            (cond [(symbol=? current
                             dest)
                   (list (append path-traveled
                                 (list current)))] ;; reached dest
                  [else  ;; else find paths to dest from current w/ no rep
                   (foldr (λ (neighbor rest)
                            (append (find-paths.acc neighbor
                                                    (append path-traveled
                                                            (list current)))
                                    rest))
                          empty
                          (filter (λ (n) (not ;; filter out neighbors visited
                                          (member? n
                                                   (cons current
                                                         path-traveled))))
                                  ((graph-neighbors g) current)))])))
    (find-paths.acc src empty)))

;; Tests/Examples:
(check-expect (find-paths G1 'C 'C) (list (list 'C))) ; src = dest
(check-expect (find-paths G1 'C 'G) empty) ; no paths from 'C to 'G
(check-expect (find-paths G1 'A 'B) 
              (list (list 'A 'B)))
(check-expect (find-paths G1 'E 'G)
              (list (list 'E 'F 'G) 
                    (list 'E 'A 'B 'F 'G)))
(check-expect (find-paths G1 'B 'G)
              (list (list 'B 'E 'F 'G) 
                    (list 'B 'F 'G)))
(check-expect (find-paths G1 'A 'G)
              (list (list 'A 'B 'E 'F 'G) 
                    (list 'A 'B 'F 'G) 
                    (list 'A 'E 'F 'G)))      


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;list=? : [Listof X] -> Boolean
;; Do the lists contains the same members, regardless of order.
(define (list=? l1 l2)
  (or (and (empty? l1)
           (empty? l2))
      (and (not (empty? l1))
           (not (empty? l2))
           (equal? (first l1)
                   (first l2))
           (list=? (rest l1)
                   (rest l2)))))
;; Tests/Examples:
(check-expect (list=? empty empty) true)
(check-expect (list=? '(1 2) '(1 2)) true)
(check-expect (list=? '(1 2) '(1 3)) false)

;; same-graph? : [Graph X] [Graph X] -> Boolean
;; Do g1 and g2 have the same nodes, and does each node in g1 have
;; the same neighbors as that node in g2.
(define (same-graph? g1 g2)
  (and (= (length (graph-nodes g1))
          (length (graph-nodes g2)))
       (andmap (λ (n) (and (member? n (graph-nodes g2))
                           (list=? ((graph-neighbors g1) n)
                                   ((graph-neighbors g2) n))))
               (graph-nodes g1))))
;; Tests/Examples:
(check-expect (same-graph? G1 G1) true)
(check-expect (same-graph? G2 G2) true)
(check-expect (same-graph? G3 G3) true)
(check-expect (same-graph? G1 G2)
              false)
(check-expect (same-graph? G1 G3)
              false)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 6 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; reverse-edge-graph : [Graph X] -> [Graph X]
;; Build a graph with the same nodes as g, but with reversed edges.
;; That is, if g has an edge from a to b then the result graph will 
;; have an edge from b to a.
(define (reverse-edge-graph g)
  (make-graph (graph-nodes g)
              (λ (n)
                (filter (λ (n1) (member? n
                                         ((graph-neighbors g) n1)))
                        (graph-nodes g)))
              (graph-node=? g)))
;; Tests/Examples:
(check-expect (local ((define result (reverse-edge-graph G1)))
                (and (list=? (graph-nodes G1) (graph-nodes result))
                     (local ((define neighbors (graph-neighbors result)))
                       (and (list=? (neighbors 'A) '(E))
                            (list=? (neighbors 'B) '(A))  
                            (list=? (neighbors 'C) '(E))  
                            (list=? (neighbors 'D) '(C F))  
                            (list=? (neighbors 'E) '(A B))  
                            (list=? (neighbors 'F) '(B E))  
                            (list=? (neighbors 'G) '(F))))
                     (equal? (graph-node=? G1)
                             (graph-node=? result))))
              true)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Exercise 7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; undirected? : [Graph X] -> Boolean
;; Determine if each edge in g has a matching edge going the opposite direction
(define (undirected? g)
  (local ((define neighbors (graph-neighbors g)))
    (andmap (λ (n1)
              (andmap (λ (n2) (member? n1 (neighbors n2)))
                      (neighbors n1)))
            (graph-nodes g))))
;; Tests/Examples:
(check-expect (undirected? G1) false)
(check-expect (undirected? G2) true)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;============================== RACKETBOT =====================================;
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; I've got a few minutes left, not even gonna try.
;; YOLO!