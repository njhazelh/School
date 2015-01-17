#lang class/1

;; A [List X] implements
;; - cons : X -> [List X]
;;   Cons given element on to this list.
;; - first : -> X
;;   Get the first element of this list 
;;   INVARIANT: (only defined on non-empty lists).
;; - rest : -> [List X]
;;   Get the rest of this 
;;   INVARIANT: (only defined on non-empty lists).
;; - list-ref : Natural -> X
;;   Get the ith element of this list 
;;   INVARIANT: (only defined for lists of i+1 or more elements)
;; - length : -> Natural
;;   Compute the number of elements in this list.
 
;; empty is a [List X] for any X.

;; A Binary Tree (BT) is a
;; - (new bt% X Number BT BT)
;; - (new leaf% X)

;; A Forest is one of:
;; - (new forest% BT Forest)
;; - (new no-forest%)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; YAY CODE!!  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-class bt%
  (fields thing size left right)
  
  ;; Template:
  #;(define (bt%-temp)
      (this . thing) ...
      (this . size) ...
      (this . left) ...
      (this . right) ...)
  
  
  ;; list-ref: Number -> X
  ;; gets the ith element from the tree
  ;; INVARIANT: The Number is greater than 0 and 
  ;;  less than the size of the tree
  (define (list-ref i)
    (cond
      [(= i 0) (this . thing)]
      [(<= i (/ (sub1 (this . size)) 2)) (this . left . list-ref (sub1 i))]
      [(> i (/ (sub1 (this . size)) 2))
       (this . right . list-ref (sub1 (- i (/ (sub1 (this . size)) 2))))]))
  ;; Examples/Tests
  (check-expect (SMALL_TREE . list-ref 0) 'c)
  (check-expect (SMALL_TREE . list-ref 1) 'b)
  (check-expect (SMALL_TREE . list-ref 2) 'a)
  (check-expect (MID_TREE . list-ref 4) 'c)
  (check-expect (MID_TREE . list-ref 6) 'a))
  
  

(define-class leaf%
  (fields thing)
  
  ;; Template:
  #;(define (leaf%-temp)
      (this . thing) ...)
  
  
  ;; size: -> Number
  ;; The size of the leaf
  (define (size) 1)
  ;; Examples/Tests
  (check-expect ((new leaf% 'a) . size) 1)  
    
  ;; list-ref: Number -> X
  ;; Fetches the element from the leaf
  ;; "whoops" should never be called or seen by the user
  (define (list-ref i)
    (if (= i 0) (this . thing)
        "whoops"))
  ;; Examples/Tests
  (check-expect ((new leaf% 'a) . list-ref 0) 'a)
  (check-expect ((new leaf% 'a) . list-ref 1)
                "whoops")) ;; This should never happen


(define-class forest%
  (fields tree rest-trees)
  
  ;; Template:
  #;(define (forest%-temp)
      (this . tree) ...
      (this . rest-trees) ...)
  
  
  ;; length: -> Number
  ;; The length of the forest
  (define (length)
    (+ (this . tree . size) (this . rest-trees . length)))
  ;; Examples/Tests
  (check-expect ((new forest%
                      SMALL_TREE
                      (new no-forest%)) . length) 3)
  (check-expect ((new forest%
                      SMALL_TREE
                      (new forest%
                           (new bt% 'f 3 (new leaf% 'e) (new leaf% 'd))
                           (new no-forest%))) . length) 6)
  
  ;; list-ref: Number -> X
  ;; gets the ith element from the list
  (define (list-ref i)
    (cond
      [(< i (this . tree . size)) (this . tree . list-ref i)]
      [else (this . rest-trees . list-ref (- (sub1 i) (sub1 (this . tree . size))))]))
  ;; Examples/Tests
  (check-expect (MID_FOREST . list-ref 0) 'c)
  (check-expect (MID_FOREST . list-ref 1) 'b)
  (check-expect (MID_FOREST . list-ref 2) 'a)
  (check-expect (MID_FOREST . list-ref 3) 'g)
  (check-expect (MID_FOREST . list-ref 4) 'f)
  (check-expect (MID_FOREST . list-ref 6) 'd)
  
  
  ;; tree-length: -> Number
  ;; How many trees are in the forest
  (define (tree-length)
    (+ 1 (this . rest-trees . tree-length)))
  ;; Examples/Tests
  (check-expect (SMALL_FOREST . tree-length) 1)
  (check-expect (MID_FOREST . tree-length) 2)
  (check-expect (LARGE_FOREST . tree-length) 3)
  
  ;; first: -> X
  ;; The first element in the forest
  (define (first)
    (this . tree . thing))
  ;; Examples/Tests
  (check-expect (SMALL_FOREST . first) 'c)
  
  ;; rest -> Forest
  ;; The rest of the forest
  (define (rest)
    (cond
      [(= (this . tree . size) 1)
       (this . rest-trees)]
      [else (new forest% (this . tree . left)
                 (new forest% (this . tree . right) (this . rest-trees)))]))
  ;; Examples/Tests
  (check-expect (SMALL_FOREST . rest)
                (new forest% (new leaf% 'b) 
                     (new forest% (new leaf% 'a) (new no-forest%))))
  (check-expect (MID_FOREST . rest)
                (new forest% (new leaf% 'b) 
                     (new forest% (new leaf% 'a)                             
                          (new forest% MID_TREE (new no-forest%)))))
  (check-expect ((new forest% (new leaf% 'a) (new no-forest%)) . rest)
                (new no-forest%))
  
  
  ;; cons: X -> Forest
  ;; Adds an element to the beginning of the list
  (define (cons e)
    (cond
      [(= (this . length) 1)
       (new forest% (new leaf% e) this)]
      [(= (this . length) 2)
       (new forest%
            (new bt% e 3 (this . tree) (this . rest-trees . tree))
            (new no-forest%))]
      [(and (>= (this . tree-length) 2)
            (= (this . tree . size) (this . rest-trees . tree . size)))
       (new forest% (new bt% e (add1 (+ (this . tree . size) 
                                        (this . rest-trees . tree . size)))
                         (this . tree) (this . rest-trees . tree)) 
            (new no-forest%))]
      [else (new forest% (new leaf% e) this)]))
  ;; Examples/Tests
  (check-expect ((new forest% (new leaf% 'a) (new no-forest%)) . cons 'b)
                (new forest% (new leaf% 'b) 
                     (new forest% (new leaf% 'a) (new no-forest%))))
  (check-expect ((new forest% (new leaf% 'b) 
                     (new forest% (new leaf% 'a) (new no-forest%))) . cons 'c)
                SMALL_FOREST)
  (check-expect ((new forest% SMALL_TREE SMALL_FOREST) . cons 'z)
                (new forest% (new bt% 'z 7 SMALL_TREE SMALL_TREE) 
                     (new no-forest%)))
  (check-expect (MID_FOREST . cons 'z)
                (new forest% (new leaf% 'z) MID_FOREST))) 



(define-class no-forest%
  
  ;; Template:
  #;(define (no-forest%-temp)
      ...)
  
  
  ;; length: -> Number
  ;; The length of the forest
  (define (length) 0)
  ;; Examples/Tests
  (check-expect ((new no-forest%) . length) 0)
  
  
  ;; tree-length: -> Number
  ;; How many trees are in the forest
  (define (tree-length) 0)
  ;; Examples/Tests
  (check-expect ((new no-forest%) . tree-length) 0)
  
  ;; cons: X -> Forest
  ;; Adds the given element to the forest
  (define (cons e)
    (new forest% (new leaf% e) (new no-forest%)))
  ;; Examples/Tests
  (check-expect ((new no-forest%) . cons 'a)
                (new forest% (new leaf% 'a) (new no-forest%))))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tests Galore!  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define empty (new no-forest%))

(define ls (empty . cons 'a . cons 'b . cons 'c . cons 'd . cons 'e))
 
(check-expect (empty . length) 0)
(check-expect (ls . length) 5)
(check-expect (ls . first) 'e)
(check-expect (ls . rest . first) 'd)
(check-expect (ls . rest . rest . first) 'c)
(check-expect (ls . rest . rest . rest . first) 'b)
(check-expect (ls . rest . rest . rest . rest . first) 'a)
 
(check-expect (ls . list-ref 0) 'e)
(check-expect (ls . list-ref 1) 'd)
(check-expect (ls . list-ref 2) 'c)
(check-expect (ls . list-ref 3) 'b)
(check-expect (ls . list-ref 4) 'a)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Testable Constnts  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define SMALL_TREE (new bt% 'c 3 (new leaf% 'b) (new leaf% 'a)))
(define MID_TREE (new bt% 'g 7 
                      (new bt% 'f 3 (new leaf% 'e) (new leaf% 'd))
                      (new bt% 'c 3 (new leaf% 'b) (new leaf% 'a))))
(define LARGE_TREE (new bt% 15 'z MID_TREE MID_TREE))
 
(define SMALL_FOREST (new forest% SMALL_TREE (new no-forest%)))
(define MID_FOREST (new forest% SMALL_TREE 
                        (new forest% MID_TREE (new no-forest%))))
                                                
(define LARGE_FOREST (new forest% SMALL_TREE
                          (new forest% MID_TREE
                               (new forest% LARGE_TREE 
                                    (new no-forest%)))))

(define (build-treelist n)
  (local ((define (build list n)
            (cond
              [(= n 0) list]
              [else (build (list . cons (random 100)) (sub1 n))])))
    (build (new no-forest%) n)))
