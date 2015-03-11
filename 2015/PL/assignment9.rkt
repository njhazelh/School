#lang pl 09

#|
Why tail call optimization is crucial:

In this problem, what we want is that when we jump to
a label it appears as though we jumped back to that
section in the instructions.  Because of tail recursive optimization,
goto a label basically just adds the commands under the label
in front of the current instruction pointer (like a train that
lays rails in front of itself).  Furthermore, since
we're not using the stack, we can do this as many times as needed
without worring about a stack overflow.  Finally, whatever the
final instruction returns is passed up unchanged as the result.
|#

;; we represent labels (goto targets) as thunks, and registers (or
;; memory locations in general) as integer boxes.
(define-type Label    = (-> Integer))
(define-type Register = (Boxof Integer))

;; "X = Y"
;; assigns the contents of register Y to register X
(: mov : Register Register -> Void)
(define (mov X Y) (set-box! X (unbox Y)))

;; "X = N"
;; assigns the constant N (an "immediate" value)  to register X
;(: movi : Register Integer -> Void)
;(define (movi X N) (set-box! X N))

;; "X += Y"
;; increments register X by register Y
(: add : Register Register -> Void)
(define (add X Y) (set-box! X (+ (unbox X) (unbox Y))))

;; "X += N"
;; increments register X by a constant N
;(: addi : Register Integer -> Void)
;(define (addi X N) (set-box! X (+ (unbox X) N)))

;; "X -= Y"
;; deccrements register X by register Y
(: sub : Register Register -> Void)
(define (sub X Y) (set-box! X (- (unbox X) (unbox Y))))

;; "X -= N"
;; decrements register X by a constant N
(: subi : Register Integer -> Void)
(define (subi X N) (set-box! X (- (unbox X) N)))

;; "X &= Y"
;; sets X to the bitwise "and" of X and Y
;(: and : Register Register -> Void)
;(define (and X Y) (set-box! X (bitwise-and (unbox X) (unbox Y))))

;; "X &= N"
;; sets X to the bitwise "and" of X and a constant N
(: andi : Register Integer -> Void)
(define (andi X N) (set-box! X (bitwise-and (unbox X) N)))

;; "X >>= N"
;; shifts register X right by N bits
(: shri : Register Integer -> Void)
(define (shri X N) (set-box! X (arithmetic-shift (unbox X) (- N))))

;; "goto L"
;; (goto L) jumps to the label -- labels are represented as nullary
;; functions (also called "thunks")
(: goto : Label -> Integer)
(define (goto L) (L))

;; "ret X"
;; return the contents of register X
(: ret : Register -> Integer)
(define (ret X) (unbox X))

;; "ret N"
;; return the constant N
(: reti : Integer -> Integer)
(define (reti N) N)

;; "if X=0 goto L1 else goto L2"
;; if register X is zero, jump to L1, else jump to L2
(: if0 : Register Label Label -> Integer)
(define (if0 a l1 l2) (if (zero? (unbox a)) (goto l1) (goto l2)))

;; "if X>0 goto L1 else goto L2"
;; if register X is positive, jump to L1, else jump to L2
(: ifp : Register Label Label -> Integer)
(define (ifp a l1 l2) (if (positive? (unbox a)) (goto l1) (goto l2)))

(: fib : Integer -> Integer)
;; compute the nth fibonacci number using the assembly language
(define (fib n)
  (: A : Register) (define A (box 0))
  (: B : Register) (define B (box 1))
  (: C : Register) (define C (box 0))
  (: N : Register) (define N (box n))
  ;;
  (: main : Label)
  (: step : Label)
  (: done : Label)
  ;;
  (define (main) (if0  N done step))
  (define (step) (mov  C A)
                 (add  C B)
                 (mov  A B)
                 (mov  B C)
                 (subi N 1)
                 (goto main))
  (define (done) (ret  A))
  ;;
  (main))
;; test
(test (map fib '(0 1 2 3 4 5 6 7 8 9 10))
      => '(0 1 1 2 3 5 8 13 21 34 55))

(: more-ones? : Integer Integer -> Integer)
;; returns 1 if `a' has more 1s in its binary representation than `b'
(define (more-ones? a b)
  (: A : Register) (define A (box a)) ;; input a
  (: B : Register) (define B (box b)) ;; input b
  (: C : Register) (define C (box 0)) ;; temp reg
  (: A-BITS : Register) (define A-BITS (box 0)) ;; ones in a
  (: B-BITS : Register) (define B-BITS (box 0)) ;; ones in b
  ;;
  (: main : Label)
  (: count-A : Label)
  (: count-A* : Label)
  (: count-B : Label)
  (: count-B* : Label)
  (: find-difference : Label)
  (: ret-true : Label)
  (: ret-false : Label)
  ;;
  (define (main) (count-A))
  (define (count-A) (if0 A count-B count-A*))
  (define (count-A*) (mov C A)
                     (andi C 1)
                     (add A-BITS C)
                     (shri A 1)
                     (goto count-A))
  (define (count-B) (if0 B find-difference count-B*))
  (define (count-B*) (mov C B)
                     (andi C 1)
                     (add B-BITS C)
                     (shri B 1)
                     (goto count-B))
  (define (find-difference) (sub A-BITS B-BITS)
                            (ifp A-BITS ret-true ret-false))
  (define (ret-true) (reti 1))
  (define (ret-false) (reti 0))
  ;;
  (main))
;; tests
(test (more-ones? 0 0) => 0)
(test (more-ones? 1 0) => 1)
(test (more-ones? 1 2) => 0)
(test (more-ones? 2 0) => 1)
(test (more-ones? 0 1) => 0)
(test (more-ones? 0 2) => 0)
(test (more-ones? 2 1) => 0)
(test (more-ones? 2 2) => 0)
(test (more-ones? 3 1) => 1)
(test (more-ones? 0 1) => 0)
(test (more-ones? 31 32) => 1)
(test (more-ones? 32 31) => 0)

(define minutes-spent 80)