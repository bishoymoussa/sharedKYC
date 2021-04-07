(define-constant my-int 150)

;; 
(define-constant my-uint u150)

(define-constant my-buffer 0x00)

(define-constant my-ascii-string "Hozz")
(define-constant my-utf8-string u"Mo")

(define-constant my-bool false)


(define-constant my-none-optional none)
(define-constant my-some-optional (some "thing"))

(define-constant my-tuple {name: "Hozz", age: 25})

(define-constant my-ok-response (ok "I got it!"))



(define-constant ERROR-you-poor-lol u1001)

(define-constant my-err-response (err ERROR-you-poor-lol))

(define-constant my-principal 'SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB.hello-world)

(define-constant my-list (list "adf"))

(define-map vote-registry
  {
    voter-name: (string-ascii 122),
    legislation: uint,
  }
  
  {vote: bool})

(map-insert vote-registry {voter-name: "Roland", legislation: u1} {vote: false})

(map-get? vote-registry {voter-name: "Roland", legislation: u1})
;; (some {vote: false})

(map-get? vote-registry {voter-name: "Ahmed", legislation: u1})
;; none


(map-insert vote-registry {voter-name: "Vlad", legislation: u1} {vote: true})
(map-insert vote-registry {voter-name: "Ibrahim", legislation: u1} {vote: true})
(map-delete vote-registry {voter-name: "Ibrahim", legislation: u1})
(map-insert vote-registry {voter-name: "Simon", legislation: u1} {vote: true})

(map-set vote-registry {voter-name: "Mario", legislation: u1} {vote: true})


(define-constant SimonsAddress 'SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB)

(define-public (pay-me (amount uint) (recipient principal)) 
  (begin
  (print "Sent!") 
  (stx-transfer? amount tx-sender recipient)))


;; Simple voting contract
;; a variable that holds the votes
;; a function that takes a voter's name
;; increments that vote count
;; and prints that voter's name
