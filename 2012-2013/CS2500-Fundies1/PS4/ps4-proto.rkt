;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname ps4-proto) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#|
Nicholas Jones
Zachary Wassall
Problem Set 4
Due: 10/1/2012
|#

;; REQUIREMENTS
(require 2htdp/image)
(require 2htdp/universe)



;; CONSTANTS
(define EDITOR_WIDTH 200)
(define EDITOR_HEIGHT 33)
(define EDITOR_PAD_X 4)
(define EDITOR_PAD_Y 4)
(define CURSOR_HEIGHT 25)



(define-struct editor (pre post))
;; An Editor is a (make-editor String String) where
;;     pre  : The text before the cursor
;;     post : The text after the cursor
(define e1 (make-editor "hello " "world"))
(define e2 (make-editor "01234" "56789"))

#|
Template:
(define (editor-temp editor)
   ...   (editor-pre  editor) ...
   ...   (editor-post editor) ...)
|#



;; cursor-left : Editor -> Editor
;; Purpose     : Moves the cursor left
;; Examples:
;;    e1 -> (make-editor "hello" " world")
;;    e2 -> (make-editor "0123" "456789")
;;    (make-editor "" "test") -> (make-editor "" "test")
(define (cursor-left editor)
  (cond [(string=? "" (editor-pre editor)) editor]
        [else (make-editor (substring (editor-pre editor)
                                      0
                                      (- (string-length (editor-pre editor)) 1))
                           (string-append (substring (editor-pre editor)
                                                     (- (string-length (editor-pre editor)) 
                                                        1))
                                          (editor-post editor)))]))

;; TESTS
(check-expect (cursor-left e1) (make-editor "hello" " world"))
(check-expect (cursor-left e2) (make-editor "0123" "456789"))
(check-expect (make-editor "" "test") (make-editor "" "test"))



;; cursor-right : Editor -> Editor
;; Purpose      : Moves the cursor right
;; Examples:
;;    e1 -> (make-editor "hello w" "orld")
;;    e2 -> (make-editor "012345" "6789")
;;    (make-editor "test" "") -> (make-editor "test" "")
(define (cursor-right editor)
  (cond [(string=? "" (editor-post editor)) editor]
        [else (make-editor (string-append (editor-pre editor)
                                          (substring (editor-post editor)
                                                     0
                                                     1))
                           (substring (editor-post editor)
                                      1))]))

;; TESTS
(check-expect (cursor-right e1) (make-editor "hello w" "orld"))
(check-expect (cursor-right e2) (make-editor "012345" "6789"))
(check-expect (make-editor "test" "") (make-editor "test" ""))



;; type-unsafe    : Editor Key -> Editor
;; Purpose        : Appends the key to the end of pre in
;;                  the given editor regardless of size constraints.
;; Examples:
;;    e1 "1" -> (make-editor "hello 1" "world")
;;    e2 "h" -> (make-editor "01234h" "56789")
;;   (make-editor "00000000000000000000000000000000000000000" "1111") "2" ->
;;   (make-editor "000000000000000000000000000000000000000002" "1111")
(define (type-unsafe editor key)
  (make-editor (string-append (editor-pre editor)
                              key)
               (editor-post editor)))

;; TESTS
(check-expect (type-unsafe e1 "1") (make-editor "hello 1" "world"))
(check-expect (type-unsafe e2 "h") (make-editor "01234h" "56789"))
(check-expect (type-unsafe (make-editor "00000000000000000000000000000000000000000" "1111") "2")
              (make-editor "000000000000000000000000000000000000000002" "1111"))



;; type    : Editor Key -> Editor
;; Purpose : Appends the key to the end of pre in
;;           the given editor so long as enough room in line.
;; Examples:
;;    e1 "1" -> (make-editor "hello 1" "world")
;;    e2 "h" -> (make-editor "01234h" "56789")
;;   (make-editor "00000000000000000000000000000000000000000" "1111") "2" ->
;;   (make-editor "00000000000000000000000000000000000000000" "1111")
(define (type editor key)
  (cond [(> (+ (image-width (string-render (string-append (editor-pre (type-unsafe editor
                                                                                   key))
                                                          (editor-post (type-unsafe editor
                                                                                    key)))))
               (* 2 EDITOR_PAD_X))
            EDITOR_WIDTH)
         editor]
        [else (type-unsafe editor
                           key)]))

;; TESTS
(check-expect (type e1 "1") (make-editor "hello 1" "world"))
(check-expect (type e2 "h") (make-editor "01234h" "56789"))
(check-expect (type (make-editor "00000000000000000000000000000000000000000" "1111") "2")
              (make-editor "00000000000000000000000000000000000000000" "1111"))



;; delete  : Editor -> Editor
;; Purpose : Deletes the last character in pre
;; Examples:
;;    e1 -> (make-editor "hello" "world")
;;    e2 -> (make-editor "0123" "56789")
;;    (make-editor "" "1234") -> (make-editor "" "1234")
;;    (make-editor "" "") -> (make-editor "" "")
(define (delete editor)
  (cond [(= 0
            (string-length (editor-pre editor)))
         editor]
        [else (make-editor (substring (editor-pre editor)
                                      0
                                      (- (string-length (editor-pre editor))
                                         1))
                           (editor-post editor))]))

;; TESTS
(check-expect (delete e1) (make-editor "hello" "world"))
(check-expect (delete e2) (make-editor "0123" "56789"))
(check-expect (delete (make-editor "" "1234")) (make-editor "" "1234"))
(check-expect (delete (make-editor "" "")) (make-editor "" ""))



;; key-is-char? : Key -> Boolean
;; Purpose      : True if key is a character (alphanumeric/symbolic)
;;                False if key is a control-key e.g. "shift", "\r"
;; Examples:
;;    "shift"   -> false
;;    "control" -> false
;;    "menu"    -> false
;;    "\r"      -> false
;;    "a"       -> true
;;    "1"       -> true
;;    "-"       -> true
(define (key-is-char? key)
  (and (= 1 
          (string-length key))
       (not (key=? key "\r"))
       (not (key=? key "\t"))
       (not (key=? key "\b"))))

;; TESTS
(check-expect (key-is-char? "shift")   false)
(check-expect (key-is-char? "control") false)
(check-expect (key-is-char? "menu")    false)
(check-expect (key-is-char? "\r")      false)
(check-expect (key-is-char? "a")       true)
(check-expect (key-is-char? "1")       true)
(check-expect (key-is-char? "-")       true)



;; edit    : Editor Key -> Editor
;; Purpose : Dispatches key events according to key input.
;; Examples:
;; e1 "left"    -> see cursor-left
;; e1 "right"   -> see cursor-right
;; e1 "\b"      -> see delete
;; e1 "a"       -> see type
;; e1 "control" -> e1
(define (edit editor key)
  (cond [(key=? key "left") (cursor-left editor)]
        [(key=? key "right") (cursor-right editor)]
        [(key=? key "\b") (delete editor)]
        [(key-is-char? key) (type editor key)]
        [else editor]))



;; editor->scene : Editor -> Scene
;; Purpose       : Draw the editor as a scene
;; Examples: You will see
(define (editor->scene editor)
  (place-image (render editor)
               (+ EDITOR_PAD_X
                  (/ (image-width (render editor))
                     2))
               (+ EDITOR_PAD_Y
                  (/ EDITOR_HEIGHT 2))
               (empty-scene EDITOR_WIDTH
                            EDITOR_HEIGHT)))

;; TESTS
;; YOU WILL SEE



;; string-render  : String -> Image
;; Purpose        : Render the string into an image.
;; Examples: You will see
(define (string-render string)
  (text string
        20
        "black"))

;; TESTS
;; YOU WILL SEE



;; render  : Editor -> Image
;; Purpose : Render the text and cursor into an image.
;; Examples: You will see
(define (render editor)
  (place-image (rectangle 1
                          CURSOR_HEIGHT
                          "solid"
                          "red")
               (image-width (string-render (editor-pre editor)))
               (/ EDITOR_HEIGHT 2)
               (string-render (string-append (editor-pre editor)
                                             (editor-post editor)))))

;; TESTS
;; YOU WILL SEE



;; Boom!
(big-bang (make-editor ""
                       "")
          (to-draw editor->scene)
          (on-key edit))



;#######################################################
;#                     SOLUTION 2                      #
;#######################################################
#|

(define-struct editor (pre post))
;; An Editor is a (make-editor String String) where
;;     text   : The text contained in the editor
;;     cursor : The index of the character in the text 
;;              immediately before which the cursor exists
(define e1 (make-editor "hello world" 6))
(define e2 (make-editor "0123456789" 5))

#|
Template:
(define (editor-temp editor)
   ...   (editor-text   editor) ...
   ...   (editor-cursor editor) ...)
|#



;; cursor-left : Editor -> Editor
;; Purpose     : Moves the cursor left
;; Examples:
;;    e1 -> (make-editor "hello world" 5)
;;    e2 -> (make-editor "0123456789" 4)
;;    (make-editor "test" 0) -> (make-editor "test" 0)
(define (cursor-left editor)
  (cond [(= 0 (editor-cursor editor)) editor]
        [else (make-editor (editor-text editor)
                           (- (editor-cursor editor) 1))]))

;; TESTS
(check-expect (cursor-left e1) (make-editor "hello world" 5))
(check-expect (cursor-left e2) (make-editor "0123456789" 4))
(check-expect (make-editor "test" 0) (make-editor "test" 0))


;; cursor-right : Editor -> Editor
;; Purpose      : Moves the cursor right
;; Examples:
;;    e1 -> (make-editor "hello world" 7)
;;    e2 -> (make-editor "0123456789" 6)
;;    (make-editor "test" 4) -> (make-editor "test" 4)
(define (cursor-left editor)
  (cond [(= (string-lengh (editor-text editor)) (editor-cursor editor)) editor]
        [else (make-editor (editor-text editor)
                           (+ (editor-cursor editor) 1))]))

;; TESTS
(check-expect (cursor-left e1) (make-editor "hello world" 7))
(check-expect (cursor-left e2) (make-editor "0123456789" 6))
(check-expect (make-editor "test" 4) (make-editor "test" 4))



;; type    : Editor Key -> Editor
;; Purpose : Inserts the key into the editor text at the current
;;           cursor index so long as enough room in line.
;; Examples:
;;    e1 "1" -> (make-editor "hello 1world" 7)
;;    e2 "h" -> (make-editor "01234h56789" 6)
;;   (make-editor "000000000000000000000000000000000000000001111" 41) "2" ->
;;   (make-editor "000000000000000000000000000000000000000001111" 41)
(define (type editor key)
  (cond [(> (+ (image-width (text (string-append (editor-pre editor)
                                              (editor-post editor)
                                              key)
                                  20
                                  "black"))
               (* 2 EDITOR_PAD_X))
            EDITOR_WIDTH)
         editor]
        [else (make-editor (string-append (editor-pre editor)
                                          key)
                           (editor-post editor))]))

;; TESTS
(check-expect (type e1 "1") (make-editor "hello 1world" 7))
(check-expect (type e2 "h") (make-editor "01234h56789" 6))
(check-expect (type (make-editor "000000000000000000000000000000000000000001111" 41) "2")
              (make-editor "000000000000000000000000000000000000000001111" 41))


;; delete  : Editor -> Editor
;; Purpose : Deletes the last character in pre
;; Examples:
;;    e1 -> (make-editor "hello" "world")
;;    e2 -> (make-editor "0123" "56789")
;;    (make-editor "" "1234") -> (make-editor "" "1234")
;;    (make-editor "" "") -> (make-editor "" "")
(define (delete editor)
  (cond [(= 0
            (string-length (editor-pre editor)))
         editor]
        [else (make-editor (substring (editor-pre editor)
                                      0
                                      (- (string-length (editor-pre editor))
                                         1))
                           (editor-post editor))]))

;; TESTS
(check-expect (delete e1) (make-world ))
(check-expect (delete e2) (make-world ))
(check-expect (delete (make-editor "" "1234")) (make-world (make-editor "" "1234")))
(check-expect (delete (make-editor "" "")) (make-world (make-editor "" "")))

;; key-is-char? : Key -> Boolean
;; Purpose      : True if key is a character
;;                False if key is a control-key e.g. "shift"
(define (key-is-char? key)
  (and (= 1 
         (string-length key))
       (not (key=? key "\r"))
       (not (key=? key "\t"))
       (not (key=? key "\b"))))



;; edit    : Editor Key -> Editor
;; Purpose : Dispatches key events according to key
(define (edit editor key)
  (cond [(key=? key "left") (cursor-left editor)]
        [(key=? key "right") (cursor-right editor)]
        [(key=? key "\b") (delete editor)]
        [(key-is-char? key) (type editor key)]
        [else editor]))



;; editor->scene : Editor -> Scene
;; Purpose       : Draw the editor as a scene
(define (editor->scene editor)
  (place-image (render editor)
               (+ EDITOR_PAD_X
                  (/ (image-width (render editor))
                     2))
               (+ EDITOR_PAD_Y
                  (/ EDITOR_HEIGHT 2))
               (empty-scene EDITOR_WIDTH
                            EDITOR_HEIGHT)))



;; Boom!
(big-bang (make-editor ""
                       "")
          (to-draw editor->scene)
          (on-key edit))





;; string-render  : String -> Image
;; Purpose        : Render the string into an image.
;; Examples: You will see
(define (string-render string)
  (text string
        20
        "black"))

;; TESTS
;; YOU WILL SEE



;; render  : Editor -> Image
;; Purpose : Render the text and cursor into an image.
;; Examples: You will see
(define (render editor)
  (place-image (rectangle 1
                          CURSOR_HEIGHT
                          "solid"
                          "red")
               (image-width (string-render (editor-pre editor)))
               (/ EDITOR_HEIGHT 2)
               (string-render (string-append (editor-pre editor)
                                             (editor-post editor)))))

;; TESTS
;; YOU WILL SEE
|#