
<!-- saved from url=(0073)http://www.ccs.neu.edu/course/csu211/Assignments/advanced-chat-server.rkt -->
<html><head><meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;">;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname advanced-chat-server) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; Advanced Chat Server used in lab.

(require 2htdp/universe)
(require srfi/1)

;; A (chat) Server is (make-server worlds [Listof String])
;; where worlds is [Listof iworld]
(define-struct server (worlds statuses))

(define server-ex1 (make-server empty empty))
(define server-ex2 (make-server (list iworld1) '("")))
(define server-ex3 (make-server (list iworld2 iworld1) '("" "")))

;; handle-new : Server iworld -&gt; Bundle
;; Handles new connections
(define (handle-new srv i)
  (make-bundle (make-server (cons i (server-worlds srv))
                            (cons "Available" (server-statuses srv)))
               (cons (make-clients-mail srv i)
                     (map (lambda (w)
                            (make-mail w (list "JOIN" (iworld-name i))))
                          (server-worlds srv)))
               (list)))

(define (remove-nth n l)
    (if (zero? n)
        (rest l)
        (cons (first l)
              (remove-nth (sub1 n) (rest l)))))

(define (set-nth n l new)
  (if (zero? n)
      (cons new (rest l))
      (cons (first l) (set-nth (sub1 n) (rest l) new))))

;; handle-disconnect : Server iworld -&gt; Bundle
;; Handles disconnections by clients
(define (handle-disconnect s i)
  (local [(define index (list-index (lambda (x) (iworld=? x i))
                                    (server-worlds s)))
          (define new-worlds (filter (lambda (x) (not (iworld=? x i)))
                                     (server-worlds s)))
          (define new-statuses (remove-nth index (server-statuses s)))]
    (make-bundle (make-server new-worlds new-statuses)
                 (map (lambda (w)
                        (make-mail w (list "PART"
                                           (iworld-name i))))
                      new-worlds)
                 (list i))))

;; a SimpleIncomingMessage is one of:
;;  - (list "MSG" &lt;content&gt;)
;;    meaning that the client who sent this message has sent the given message.
;;  - (list "ACTION" &lt;content&gt;)
;;    meaning that the client who sent this message has /me'd the given message.
;;  - (list "STATUS" &lt;content&gt;)
;;    meaning that the client who sent this message has set their status to
;;    &lt;content&gt;

;; a IncomingMessage is one of:
;;  - SimpleIncomingMessage
;;  - (list "CLIENTS")
;;    meaning that the client who sent this message has requested a list of
;;    connected clients
;;  - (list "PRIVMSG" &lt;name&gt; &lt;content&gt;)
;;    meaning that the client who sent this message would like to send the
;;    private message &lt;content&gt; to the client with name &lt;name&gt;

;; an OutgoingMessage is one of:
;;  - (list "MSG" &lt;name&gt; &lt;content&gt;)
;;    meaning that the client with the name &lt;name&gt; has sent the given message.
;;  - (list "ACTION" &lt;name&gt; &lt;content&gt;)
;;    meaning that the client with the name &lt;name&gt; has /me'd the given message.
;;  - (list "STATUS" &lt;name&gt; &lt;content&gt;)
;;    meaning that the client with the name &lt;name&gt; has set his or her status to
;;    &lt;content&gt;
;;  - (list "CLIENTS" &lt;number&gt; &lt;list-of-names&gt;)
;;    meaning that there are &lt;number&gt; clients connected to the server and their
;;    names, in no particular order, are &lt;list-of-names&gt;
;;  - (list "PRIVMSG" &lt;name&gt; &lt;content&gt;)
;;    meaning that &lt;name&gt; sent a message to the receiver of this message

;; message-content : SimpleIncomingMessage -&gt; String
(define (message-content x)
  (second x))

;; tagged-list? : Any String
(define (tagged-list? x tag)
  (and (cons? x)
       (string? (first x))
       (string=? (first x) tag)))

(check-expect (tagged-list? '("FOO" bar baz) "FOO") true)
(check-expect (tagged-list? '(fizz bar baz) "FOO") false)
(check-expect (tagged-list? '() "FOO") false)
(check-expect (tagged-list? 'bar "FOO") false)
(check-expect (tagged-list? "FOO" "FOO") false)

;; length-check : [ListOf Any] Number -&gt; Boolean
;; checks the length, but is bounded by n
(define (length-check ls n)
  (cond [(&lt; n 0) false]
        [(empty? ls) (zero? n)]
        [else (length-check (rest ls) (sub1 n))]))

(check-expect (length-check '() 0) true)
(check-expect (length-check '(foo) 0) false)
(check-expect (length-check '(foo bar baz) 2) false)
(check-expect (length-check '(foo bar baz) 3) true)

(define (valid-simple-message/tag? x tag)
  (and (tagged-list? x tag)
       (length-check x 2)
       (string? (second x))))

(define (valid-msg-message? x)
  (valid-simple-message/tag? x "MSG"))

(define (valid-action-message? x)
  (valid-simple-message/tag? x "ACTION"))

(define (valid-status-message? x)
  (valid-simple-message/tag? x "STATUS"))

(define (valid-update-status-message? x)
  (valid-simple-message/tag? x "UPDATE-STATUS"))

(define (valid-clients-message? x)
  (and (tagged-list? x "CLIENTS")
       (length-check x 1)))

(define (valid-privmsg-message? x)
  (and (tagged-list? x "PRIVMSG")
       (length-check x 3)
       (string? (second x))
       (string? (third x))))

(check-expect (valid-msg-message? '("PART" "BOB")) false)
(check-expect (valid-msg-message? '("JOIN" "BOB")) false)
(check-expect (valid-msg-message? '("MSG" "BOB")) true)
(check-expect (valid-msg-message? 'foo) false)

;; send-to-all : String Server -&gt; [ListOf Mail]
(define (send-to-all content srv)
  (map (lambda (w)
         (make-mail w content))
       (server-worlds srv)))

;; send-to-name : String String Server -&gt; Mail
;; NOTE: we assume name is a name of one of thes server's worlds
(define (send-to-name content name srv)
  (make-mail (first (memf (lambda (w)
                            (equal? (iworld-name w) name))
                          (server-worlds srv)))
             content))

(define (real-name? name srv)
  (member? name (map iworld-name (server-worlds srv))))

;; handle-msg : Server iworld IncomingMessage -&gt; Bundle
;; Handles messages coming from the clients
(define (handle-msg srv i msg)
  (cond [(valid-msg-message? msg)
         (make-bundle srv
                      (send-to-all (list "MSG"
                                         (iworld-name i)
                                         (message-content msg))
                                   srv)
                      (list))]
        [(valid-action-message? msg)
         (make-bundle srv
                      (send-to-all (list "ACTION"
                                         (iworld-name i)
                                         (message-content msg))
                                   srv)
                      (list))]
        [(valid-status-message? msg)
         (make-bundle srv
                      (list
                       (make-mail i
                                  (local
                                    [(define index (list-index
                                                    (lambda (iw) (string=?
                                                             (iworld-name iw)
                                                             (message-content msg)))
                                                    (server-worlds srv)))]
                                    (list "NEW-STATUS"
                                          (message-content msg)
                                          (if (not (false? index))
                                              (list-ref (server-statuses srv) index)
                                              "Offline")))))
                      (list))]
        [(valid-update-status-message? msg)
         (make-bundle (make-server (server-worlds srv)
                                   (local [(define index (list-index
                                                          (lambda (x) (iworld=? x i))
                                                          (server-worlds srv)))
                                           (define new-statuses
                                             (set-nth index (server-statuses srv)
                                                      (message-content msg)))]
                                     new-statuses))
                      (send-to-all (list "NEW-STATUS"
                                         (iworld-name i)
                                         (message-content msg))
                                   srv)
                      (list))]
        [(valid-clients-message? msg)
         (make-bundle srv
                      (list (make-clients-mail srv i))
                      (list))]
        [(valid-privmsg-message? msg)
         (if (real-name? (second msg) srv)
             (make-bundle srv
                          (list (send-to-name (list "PRIVMSG"
                                                    (iworld-name i)
                                                    (third msg))
                                              (second msg)
                                              srv))
                          (list))
             (make-bundle srv (list) (list)))]
        [else (make-bundle srv
                           (list)
                           (list))])) ; reject message, disconnect user

;; make-clients-mail : Server iworld -&gt; Mail
;; constructs a mail to i that details who else is connected to the server
(define (make-clients-mail srv i)
  (make-mail i
             (list "CLIENTS"
                   (length (server-worlds srv))
                   (map iworld-name
                        (server-worlds srv)))))

(universe (make-server empty empty)
          (on-msg handle-msg)
          (on-new handle-new)
          (on-disconnect handle-disconnect))</pre></body></html>