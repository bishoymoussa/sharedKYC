;; Simple voting contract
;; a variable that holds the votes
(define-data-var vote-count uint u0)
;; a function that takes a voter's name
;; increments that vote count
;; and prints that voter's name
(define-constant SimonsAddress 'SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB)

(define-constant ERROR-UNAUTHORIZED u401)
(define-map votes-for-legislations {legislation: uint} {votes: uint})
(define-map vote-registry {voter: principal, legislation: uint} {did-vote: bool})

(define-public (vote (name (string-ascii 256)) (legislation-id uint)) 
  (let (
    (current-votes (var-get vote-count))
    (new-vote-count (+ current-votes u1))
    (voter-registration (map-get? vote-registry {voter: tx-sender, legislation: legislation-id}))
    (did-vote (is-some voter-registration))
    (number-of-votes (default-to u0
      (get votes 
        (map-get? votes-for-legislations {legislation: legislation-id}))))
  )
    (if did-vote 
      (err ERROR-UNAUTHORIZED)
      (begin
        (var-set vote-count new-vote-count)
        (map-insert vote-registry 
          {voter: tx-sender, legislation: legislation-id} 
          {did-vote: true})
        (map-set votes-for-legislations
          {legislation: legislation-id} 
          {votes: (+ u1 number-of-votes)})
        (print name)
        ;; 0.00001
        ;;
        (stx-transfer? u100 tx-sender SimonsAddress)
      ))))


(define-constant creator tx-sender)

(define-map validation-service-providers
  {id: principal}
  {active: bool, name: (string-ascii 256)}
)

(map-insert validation-service-providers 
  {id: 'SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB} {active: true, name: "CIB"})

(define-public (add-provider (address principal) (name (string-ascii 256))) 
  (begin
    (asserts! (is-eq creator tx-sender) (err ERROR-UNAUTHORIZED))
    (ok 
      (map-insert validation-service-providers 
        {id: address} {active: true, name: name}))
  ))


;; consider the validation map

(define-map validations {id: uint} {hash: (buff 256)})

(define-private (is-a-validator) 
  (is-some (map-get? validation-service-providers {id: tx-sender})))

(define-public (add-hash (id uint) (hash (buff 256)))
  (begin 
    (asserts! (is-a-validator) 
      (err ERROR-UNAUTHORIZED))
    (map-insert validations {id: id} {hash: hash})
    (ok true)
  ))


;; legacy issue

;; create account
;; upload sensitive data
;; assign beneficiary that would get data

(define-non-fungible-token data principal)

(define-map wills 
  {owner: principal}
  {beneficiary: principal, is-dead: bool}
)

(define-constant contract-address (as-contract tx-sender))


(define-private (get-will (owner principal)) 
  (unwrap-panic (map-get? wills {owner: owner})))

(define-public (register-data-point (owner principal)) 
  (begin 
    (asserts! (is-eq creator tx-sender) (err ERROR-UNAUTHORIZED))
    (nft-mint? data owner contract-address)
  ))

(define-public (mark-dead (owner principal)) 
  (let
    (
      (will (get-will owner))
    ) 
    (asserts! (is-eq creator tx-sender) (err ERROR-UNAUTHORIZED))
    (map-set wills {owner: owner} (merge will {is-dead: true}))
    (as-contract (nft-transfer? data owner tx-sender (get beneficiary will)))
    ))

(define-public (set-beneficiary (beneficiary principal)) 
  (ok (map-set wills 
    {owner: tx-sender} 
    {beneficiary: beneficiary, is-dead: false})))


;; DB => data

;; Best club u1
;; RM => u1, CH => u2, AlAhly => u3

;; SC => pointers


(define-map votes-meta 
  {id: uint}
  {vote-ends-at: uint}
)

;; voting-duration e.g. 3000 block
(define-public (add-vote-meta (id uint) (voting-duration uint)) 
  (let () 
    (asserts! (is-eq creator tx-sender) (err ERROR-UNAUTHORIZED))
    (map-insert votes-meta 
    {id: id} 
    {vote-ends-at: block-height + voting-durations})
  )
)

(define-public (vote (id uint) (choice uint)) 
  (let (
    (vote-meta (map-get? votes-meta {id: id}))
  ) 
    (asserts! (is-some vote-meta) 
      (err u404))
    (let (
      (vote-meta-unpacked (unwrap-panic vote-meta))
      (vote-ends-at (get vote-ends-at vote-meta-unpacked))
    ) 
    (asserts! (> vote-ends-at block-height) (err ERROR-UNATHORIZED)))))

(define-map votes 
  {voter: principal, id: uint}
  {choice: uint}
)