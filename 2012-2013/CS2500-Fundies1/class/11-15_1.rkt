;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname 11-15_1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
Classwork

October 15, 2012

GRAPHS:
A graph is a set of nodes with edges between.
--represent networks
  --subway
  --internet
  --airports


A -> B
|  ^ |
V /  V
C    D -> E -> E

Adjacency Matrix:
  A B C D E
A 0 1 1 0 0
B 0 0 0 1 0
C 0 1 0 0 0
D 0 0 0 0 1
E 0 0 0 0 1

Poor representation for sparsely populated graphs (few connections, many nodes)
|#

;; Stucture Representation:

;; A Graph is a [Listof (make-node Symbol [Listof Symbol])]

#;(define-struct node (name out-edges))
#;(list (make-node 'a '(b c))
        (make-node 'b '(d))
        (make-node 'c '(b))
        (make-node 'd '(e))
        (make-node 'e '(e)))

#;(define-struct node (name in-edges))
#;(list (make-node 'a '())
        (make-node 'b '(a c))
        (make-node 'c '(a))
        (make-node 'd '(b))
        (make-node 'e '(d e)))

;;Could write with an edge predicate:
#;(define-struct node (name edge-to))
;;A Graph is a [Listof (make-node Symbol [Symbol -> Boolean])]
#;(list (make-node 'a (λ (s) (or (symbol=? s 'b)
                                 (symbol=? s 'c)))) 
        (make-node 'b (λ (s) (symbol=? s 'd)))
        (make-node 'c (λ (s) (symbol=? s 'b)))
        (make-node 'd (λ (s) (symbol=? s 'e)))
        (make-node 'e (λ (s) (or (symbol=? s 'e)
                                 (symbol=? s 'e)))))

;; Application:
(define-struct node (name neighbors))
;; A Graph is a [Listof (make-node Symbol [Symbol -> Boolean])]
;; Interpretation: The list represents all nodes and their neighbors
;; one hop away.

(define G1 (list (make-node 'A '(B))
                 (make-node 'B '(C))
                 (make-node 'C '(A E))
                 (make-node 'D '())
                 (make-node 'E '(D))))

;; Graph Symbol -> [Listof Symbol]
;; All of the neighbors of given node
;; Returns error if node not in graph.
(define (neighbors G n)
  (cond [(empty? G) (error 'neighbors "Graph Doesn't contain node")]
        [(symbol=? n (node-name (first G)))
         (node-neighbors (first G))]
        [else (neighbors (rest G) n)]))
;; Test/Examples:
(check-error (neighbors G1 'x) "neighbors: Graph Doesn't contain node")

;; connected? : Graph Symbol Symbol -> Boolean
;; is there an edge from x->y
(define (connected? G x y)
  (member y (neighbors G x)))
;; Tests/Examples:
(check-expect (connected? G1 'A 'B) true)
(check-expect (connected? G1 'A 'E) false)

;; route? : Graph Symbol Symbol -> Boolean
;; Is there a path from x->y in graph G
(define (route? G x y)
  (or (connected? G x y)
      (local ((define G-x (remove-node G x)))
        (ormap (λ (nbr) (route? G-x nbr y))
             (neighbors G x)))))
;; Check-expect
(check-expect (route? G1 'A 'C) true)
(check-expect (route? G1 'A 'D) true)
(check-expect (route? G1 'E 'A) false)

;; remove-node: Graph Symbol -> Graph
;; Remove node x from the graph
(define (remove-node G x)
  (map (λ (n) (make-node (node-name n)
                         (remove x (neighbors G (node-name n)))))
       (filter (λ (n) (not (symbol=? (node-name n)
                                     x)))
                 G)))
;; Tests/Examples:
(check-expect (remove-node G1 'C)
              (list (make-node 'A '(B))
                    (make-node 'B '())
                    (make-node 'D '())
                    (make-node 'E '(D))))

;; route.acc? : Graph Symbol Symbol [Listof Symbol] -> Boolean
(define (route.acc? G x y blackout)
  (and (not (member x blackout))
       (or (connected? G x y)
           (local ((define new-blackout (cons x blackout)))
             (ormap (λ (nbr) (route? G nbr y new-blackout))
                    (neighbors G x))))))






