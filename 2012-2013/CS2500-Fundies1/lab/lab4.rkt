;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname lab4) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; A File is a Symbol

;; An FS (FileSystem) is one of
;; -- empty
;; -- (cons File FS)
;;TEMPLATE
#;(define (fs-temp fs)
    (cond
      [(empty? fs) ...]
      [else (first fs) (rest fs)]))


;;total : FS -> Number
;;counts the number of files in FS
;;EXAMPLES
; (total (cons 'f1 (cons 'f2 empty))) -> 2
; (total (list 'f1 'f2 'f3 'f4)) -> 4
; (total empty) -> 0

(define (total fs)
  (cond
    [(empty? fs) 0]
    [else (+ 1 (total (rest fs)))]))

(check-expect (total (cons 'f1 (cons 'f2 empty))) 2)
(check-expect (total (list 'f1 'f2 'f3 'f4)) 4)
(check-expect (total empty) 0)

;; file-in-system? : FS File -> Boolean
;; checks if a given file is in a given filesystem
;;EXAMPLES
; (file-in-system? (cons 'f1 (cons 'f2 empty)) 'f1) -> true
; (file-in-system? (cons 'f1 (cons 'f2 empty)) 'f5) -> false

(define (file-in-system? fs file)
  (cond
    [(empty? fs) false]
    [(symbol=? (first fs) file) true]
    [else (file-in-system? (rest fs) file)]))

(check-expect (file-in-system? (cons 'f1 (cons 'f2 empty)) 'f1) true)
(check-expect (file-in-system? (cons 'f1 (cons 'f2 empty)) 'f5) false)

;; A File is a Symbol

;; A Dir is one of
;; -- empty
;; -- (cons File Dir)
;; -- (cons Dir Dir)

;; A Dir is constructed by gradually adding files and directories together:
;;  - (cons f d) creates a directory adding file f to the contents of directory d
;;  - (cons f (cons d empty)) creates a directory containing file f and subdirectory d
;;  - (cons d1 d2) creates a directory adding subdirectory d1 to the contents of directory d2
;;  - (cons d1 (cons d2 empty)) creates a directory containing subdirectories d1 and d2

#;
(define (dir-temp d)
  (cond [(empty? d) ...]
        [(symbol? d) ... (dir-temp (first d)) ...]
        [else ... (dir-temp (rest d)) ...]))

;; Part 3
(define dir1 (list 'hw3.ss
                   'hw1.ss
                   (list 'lists-and-recursion.ss
                         'structs.ss
                         'tetris.ss)
                   'syllabus.pdf
                   (list 'olin.png
                         'amal.png
                         'r6rs.pdf
                         'kitteh.png)
                   'hw2.ss))

;; files-in-dir : Dir -> Number
;; Purpose      : Returns total number of files in dir
;; Examples:
;;    dir1 -> 11
;;    (list 'a 'b (list 'c 'd) 'e 'f)) -> 6
(define (files-in-dir d)
  (cond [(empty? d) 0]
        [(symbol? (first d)) (+ 1 (files-in-dir (rest d)))]
        [else (+ (files-in-dir (first d))
                 (files-in-dir (rest d)))]))

;; Tests
(check-expect (files-in-dir dir1) 11)
(check-expect (files-in-dir (list 'a 'b (list 'c 'd) 'e 'f)) 6)

;; file-in-dir? : Dir File -> Boolean
;; Purpose      : True if file in Dir
;;                False if not.
;; Examples
;;    dir1 'hello -> false
;;    dir1 'kitteh.png -> true


(define (file-in-dir? dir file)
  (cond [(empty? dir) false]
        [(cons? (first dir)) (or (file-in-dir? (first dir) file)
                                 (file-in-dir? (rest dir) file))]
        [(symbol? (first dir)) (or (symbol=? (first dir) file)
                                   (file-in-dir? (rest dir) file))]))
;; Tests
(check-expect (file-in-dir? dir1 'hello) false)
(check-expect (file-in-dir? dir1 'kitteh.png) true)

;; rename-files : Dir File File -> Dir
;; Purpose      : Renames all files src in dir to target
;; Examples:
;;    (list 's1 's2 's3) 's1 's4 -> (list 's4 's2 's3)
;;    (list 's1 's2 's3) 's5 's4 -> (list 's1 's2 's3)
(define (rename-files dir src target)
  (cond [(empty? dir) empty]
        [(cons? (first dir)) (cons (rename-files (first dir)
                                                 src 
                                                 target)
                                   (rename-files (rest dir)
                                                 src 
                                                 target))]
        [(and (symbol? (first dir))
              (symbol=? (first dir)
                        src)) (cons target (rename-files (rest dir)
                                                         src
                                                         target))]
        [else (cons (first dir)
                    (rename-files (rest dir)
                                  src
                                  target))]))

(check-expect (rename-files (list 's1 's2 's3) 's1 's4) (list 's4 's2 's3))
(check-expect (rename-files (list 's1 's2 's3) 's5 's4 ) (list 's1 's2 's3))
(check-expect (rename-files dir1 'olin.png 'prof.png) (list 'hw3.ss
                                                            'hw1.ss
                                                            (list 'lists-and-recursion.ss
                                                                  'structs.ss
                                                                  'tetris.ss)
                                                            'syllabus.pdf
                                                            (list 'prof.png
                                                                  'amal.png
                                                                  'r6rs.pdf
                                                                  'kitteh.png)
                                                            'hw2.ss))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct file (name size owner))
;; A File is (make-file Symbol Number Symbol)
;; (make-file s n o) creates a File with name s, size n kilobytes, and owned by o.


;; An LoF (List-of-Files) is one of
;; -- empty
;; -- (cons File LoF)

(define-struct dir (name dirs files))
;; A Dir is a (make-dir Symbol LoD LoF)
;; (make-dir s ds fs) creates a Dir with name s containing ds as its list of
;; directories and fs as its list of files.

;; An LoD (List-of-Dir) is one of
;; -- empty
;; -- (cons Dir LoD)

#;(define (recursive-temp dir)
    (cond
      [(dir? dir) ... (dir-name dir) ...
                  ... (dir-dirs dir) ...
                  ... (dir-files dir) ...]
      [(file? dir) ... (file-name dir) ...
                   ... (file-dirs dir) ...
                   ... (file-files dir) ...]
      [else ...]))

(define bigdir (make-dir 'dir1 (list (make-dir 'dir2 empty (list
                                                            (make-file 'file1 45 'chuck)
                                                            (make-file 'file2 67 'larry)))
                                     (make-dir 'dir3 empty (list
                                                            (make-file 'file4 54 'barry)
                                                            (make-file 'file5 78 'larry))))
                         (list (make-file 'file5 34 'billy))))



;; total-files  : Dir -> Number
;; counts the number of files in a directory
;;EXAMPLES
; bigdir -> 5

(define (total-files d)
  (cond
    [(empty? d) 0]
    [(dir? d) (+ (total-files (dir-files d))
                 (total-files (dir-dirs d)))]
    [(file? (first d)) (+ 1 (total-files (rest d)))]
    [(dir? (first d)) (+ (total-files (first d))
                         (total-files (rest d)))]))

(check-expect (total-files bigdir) 5)


;; Problem 8:

;; files-owned-lod : Symbol LoD -> LoF
;; Purpose         : Returns an LoF of the files in the LoD
;;                   owned by the given person
(define (files-owned-lod o lod)
  (cond [(empty? lod) empty]
        [else (append (files-owned o (first lod))
                      (files-owned-lod o (rest lod)))]))

;; files-owned-lof : Symbol LoF -> LoF
;; Purpose         : Returns an LoF of the files in the LoF
;;                   owned by the given person
(define (files-owned-lof o lof)
  (cond [(empty? lof) empty]
        [(symbol=? (file-owner (first lof))
                   o)
         (cons (first lof)
               (files-owned-lof o (rest lof)))]
        [else (files-owned-lof o (rest lof))]))

;; files-owned  : Symbol Dir -> LoF
;; consumes a Dir d and a Symbol s representing an owner and returns a list of 
;; files owned by s in the directory tree of d.
;;EXAMPLES
;;  'larry bigdir -> (list (make-file 'file2 67 'larry)
;;                        (make-file 'file5 78 'larry))
;;  'barry bigdir -> (list (make-file 'file4 54 'barry))
;;  'bob bigdir   -> empty
(define (files-owned o d)
  (append (files-owned-lod o
                           (dir-dirs d))
          (files-owned-lof o
                           (dir-files d))))

;; TESTS
(check-expect (files-owned 'larry bigdir) (list (make-file 'file2 67 'larry)
                                                (make-file 'file5 78 'larry)))
(check-expect (files-owned 'barry bigdir) (list (make-file 'file4 54 'barry)))
(check-expect (files-owned 'bob   bigdir) empty)

;; Problem 9:

;; files-larger-lod : Number LoD -> LoF
;; Purpose         : Returns an LoF of the files in the LoD
;;                   owned by the given person
(define (files-larger-lod size lod)
  (cond [(empty? lod) empty]
        [else (append (files-larger size (first lod))
                      (files-larger-lod size (rest lod)))]))

;; files-larger-lof : Number LoF -> LoF
;; Purpose         : Returns an LoF of the files in the LoF
;;                   owned by the given person
(define (files-larger-lof size lof)
  (cond [(empty? lof) empty]
        [(>= (file-size (first lof))
             size)
         (cons (first lof)
               (files-larger-lof size (rest lof)))]
        [else (files-larger-lof size (rest lof))]))

;; files-larger  : Number Dir -> LoF
;; consumes a Dir d and a Symbol s representing an owner and returns a list of 
;; files owned by s in the directory tree of d.
;;EXAMPLES
;;  1000 bigdir -> empty
;;  54   bigdir -> (list (make-file 'file2 67 'larry)
;;                       (make-file 'file4 54 'barry)
;;                       (make-file 'file5 78 'larry))
;;  0    bigdir  -> (list (make-file 'file1 45 'chuck)
;;                        (make-file 'file2 67 'larry)
;;                        (make-file 'file4 54 'barry)
;;                        (make-file 'file5 78 'larry)
;;                        (make-file 'file5 34 'billy))
(define (files-larger size d)
  (append (files-larger-lod size
                            (dir-dirs d))
          (files-larger-lof size
                            (dir-files d))))

;; TESTS
(check-expect (files-larger 1000 bigdir) empty)
(check-expect (files-larger 54   bigdir) (list (make-file 'file2 67 'larry)
                                               (make-file 'file4 54 'barry)
                                               (make-file 'file5 78 'larry)))
(check-expect (files-larger 0    bigdir) (list (make-file 'file1 45 'chuck)
                                               (make-file 'file2 67 'larry)
                                               (make-file 'file4 54 'barry)
                                               (make-file 'file5 78 'larry)
                                               (make-file 'file5 34 'billy)))

;; Problem 10

;; total-size-lod : LoD -> Number
;; Purpose    : Returns the sum of all file sizes in LoD
(define (total-size-lod lod)
  (cond [(empty? lod) 0]
        [else (+ (total-size     (first lod))
                 (total-size-lod (rest lod)))]))

;; total-size-lof : LoF -> Number
;; Purpose        : Returns the sum of all file sizes in LoF
(define (total-size-lof lof)
  (cond [(empty? lof) 0]
        [else (+ (file-size (first lof))
                 (total-size-lof (rest lof)))]))

;; total-size  : Dir -> Number
;; Returns the sum of all file sizes in Dir
;; EXAMPLES
;;    bigdir -> 278
(define (total-size d)
  (+ (total-size-lod (dir-dirs d))
     (total-size-lof (dir-files d))))
;; TESTS
(check-expect (total-size bigdir) 278)