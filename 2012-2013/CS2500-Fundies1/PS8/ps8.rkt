;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ps8) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
November 6th 2012
PS 8h
|#


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PROBLEM A2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


#|

Part 1:

Develop data definitions for binary trees of Symbols, and binary trees of Numbers.
The numbers and symbols should occur at the leaf positions only.

Create two instances of each, and abstract over the data definitions.

Design the function height, which consumes any binary tree and computes
its height. That is, the maximum number of nodes from the root of the
given tree to a leaf.

Here's some tests to further explain:
      (check-expect (height 5) 0)
      (check-expect (height (make-node 'yes (make-node 'no 'maybe))) 2)

|#


(define-struct node (left right))
;; A Node is a (make-node [BTof X] [BTof X])

#;(define (node-temp n)
    ... (node-left n) ...
    ... (node-right n) ...)

;; A [BTof X] is one of:
;; - X
;; - (make-node [Btof X] [BTof X])

#;(define (bt-temp bt)
    (cond [(node? bt) ... (node-left bt)  ...
                      ... (node-right bt) ...]
          [else ...]))

;; [BTof Number] Examples:
(define btn1 3)
(define btn2 (make-node 6 8))
(define btn3 (make-node (make-node 4 8)
                        (make-node 7 12)))
(define btn4 (make-node (make-node (make-node 23 7)
                                   (make-node 4 8))
                        (make-node (make-node 2 8)
                                   (make-node 0 1))))

;; [BTof Symbol] Examples:
(define bts1 'yes)
(define bts2 (make-node bts1 'no))
(define bts3 (make-node bts2
                        (make-node 'maybe 'yes)))
(define bts4 (make-node bts3
                        (make-node (make-node 'up 'down)
                                   (make-node 'left 'right))))

;; height: [BTof X] [BTof X] -> Number
;; Finds the height of the Binary Tree
(define (height bt)
  (cond [(node? bt)
         (add1 (max (height (node-left bt))
                    (height (node-right bt))))]
        [else 0]))
;; Tests/Examples:
(check-expect (height 5) 0)
(check-expect (height (make-node 'yes (make-node 'no 'maybe))) 2)
(check-expect (height btn4) 3)
(check-expect (height bts4) 3)






#|

PART II:

A leafy binary tree is a binary tree with the symbol 'leaf at its leafs.

Design a function that consumes a natural number n and creates (a list of)
all leafy binary trees of height n.

Hint: Design a function that consumes a natural number n and creates
(a list of) all leafy binary trees of height equal or less than n.

Warning: this is not about abstraction; it's just a reminder that
more interesting (and complex) programs are around the corner.

|#


;; THIS IS MY FIRST ATTEMPT AT THE PROBLEM. IT WORKS BUT IT"S MUCH SLOWER
;; SECOND VERSION BELOW.
;; gen-trees<=height : Number -> [BTof Symbol]
;; Generates a list of all trees with the height <= the given height.
(define (gen-trees<=height h)
  (cond [(zero? h) '(leaf)]
        [else (local ((define lower-levels (gen-trees<=height (sub1 h))))
                (append (foldr (λ (bt1 rest1)
                                 (append (foldr (λ (bt2 rest2)
                                                  (if (or (= (height bt1)
                                                             (sub1 h))
                                                          (= (height bt2)
                                                             (sub1 h)))
                                                      (cons (make-node bt1 bt2)
                                                            rest2)
                                                      rest2))
                                                empty
                                                lower-levels)
                                         rest1))
                               empty
                               lower-levels)
                        lower-levels))]))
;; Tests/Examples:
(check-expect (gen-trees<=height 0) '(leaf))
(check-expect (gen-trees<=height 1) (list (make-node 'leaf 'leaf) 'leaf))
(check-expect (gen-trees<=height 2) (list (make-node (make-node 'leaf 'leaf)
                                                     (make-node 'leaf 'leaf))
                                          (make-node (make-node 'leaf 'leaf)
                                                     'leaf)
                                          (make-node 'leaf
                                                     (make-node 'leaf 'leaf))
                                          (make-node 'leaf 'leaf)
                                          'leaf))

;; gen-trees=height : Number -> [BTof Symbol]
;; Generates all the possible binary trees of given height
(define (gen-trees=height h)
  (filter (λ (bt) (= (height bt)
                     h))
          (gen-trees<=height h)))
;; Tests/Examples:
(check-expect (gen-trees=height 0) '(leaf))
(check-expect (gen-trees=height 1) (list (make-node 'leaf 'leaf)))
(check-expect (gen-trees=height 2) (list (make-node (make-node 'leaf 'leaf)
                                                    (make-node 'leaf 'leaf))
                                         (make-node (make-node 'leaf 'leaf)
                                                    'leaf)
                                         (make-node 'leaf
                                                    (make-node 'leaf 'leaf))))




;; Attempt 2
;; USING ACCUMULATORS
;; THIS IS  ABOUT 30-50 TIMES FASTER

;; symbol-node=? [BTof Symbol] [BTof Symbol] -> Boolean
;; Does every leaf of the first BT match every node of the second?
(define (symbol-node=? n1 n2)
  (or (and (symbol? n1)
           (symbol? n2)
           (symbol=? n1 n2))
      (and (node? n1)
           (node? n2)
           (symbol-node=? (node-left n1)
                          (node-left n2))
           (symbol-node=? (node-right n1)
                          (node-right n2)))))
;; Texts/Examples
(check-expect (symbol-node=? 'leaf 'leaf) true)
(check-expect (symbol-node=? 'leaf 'halo4Rules) false)
(check-expect (symbol-node=? (make-node 'leaf 'leaf) 'leaf) false)
(check-expect (symbol-node=? (make-node 'leaf 'leaf)
                             (make-node 'leaf 'leaf))
              true)



;; gen-tree-combos-from-subs : [Listof [BTof Symbol]]
;;                             [Listof [BTof Symbol]] -> [Listof [BTof Symbol]]
;; Combines the level underneath with itself and all the levels below
;; to generate all possible trees of the current height.
;;
;; i.e.
;; if current-level == 4 then list contains combos where match
;;     (make-node "node-height = 3" "node-height = 0|1|2|3") OR
;;     (make-node "node-height = 0|1|2|3" "node-height = 3")
;;
(define (tree-combos-from-subs level-under sub-levels)
  (append 
   #|Combos of level-under|#
   (foldr (λ (t1 rest1)
            (append (map (λ (t2)
                           (make-node t1 t2))
                         level-under)
                    rest1))
          empty
          level-under)
   
   #|Combos of the level-under with sub-levels|#
   (foldr (λ (t1 rest1)
            (append (foldr (λ (t2 rest2)
                             (cons (make-node t1 t2)
                                   (cons (make-node t2 t1)
                                         rest2)))
                           empty 
                           sub-levels)
                    rest1))
          empty
          level-under)))
;; Tests/Examples:
(check-expect (tree-combos-from-subs '(a b) '(1 2))
              (list (make-node 'a 'a)
                    (make-node 'a 'b)
                    (make-node 'b 'a)
                    (make-node 'b 'b)
                    (make-node 'a 1)
                    (make-node 1 'a)
                    (make-node 'a 2)
                    (make-node 2 'a)
                    (make-node 'b 1)
                    (make-node 1 'b)
                    (make-node 'b 2)
                    (make-node 2 'b)))



;; gen-trees=height.acc : Number -> [Listof [BTof Symbol]]
;; generates a list of all trees with the given height and 'leaf for each leaf.
(define (gen-trees=height.acc height)
  (local ((define (gen-trees.acc level-under sub-levels level)
            (cond [(>= level height) level-under]
                  [else (local ((define current-level (tree-combos-from-subs level-under sub-levels)))
                          (gen-trees.acc current-level
                                         (append level-under
                                                 sub-levels)
                                         (add1 level)))])))
    (gen-trees.acc (list 'leaf) empty 0)))
;; Tests/Examples
(check-expect (gen-trees=height.acc 0) '(leaf))
(check-expect (gen-trees=height.acc 1) (list (make-node 'leaf 'leaf)))
(check-expect (gen-trees=height.acc 2) (list (make-node (make-node 'leaf 'leaf)
                                                        (make-node 'leaf 'leaf))
                                             (make-node (make-node 'leaf 'leaf)
                                                        'leaf)
                                             (make-node 'leaf
                                                        (make-node 'leaf 'leaf))))




;; COMPARISION OF FIRST AND SECOND METHODS:
#;(time (length (gen-trees=height 5)))     ;; FIRST
#;(time (length (gen-trees=height.acc 5))) ;; SECOND








