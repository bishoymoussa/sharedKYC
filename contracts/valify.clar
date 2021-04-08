
(define-constant creator tx-sender)
(define-constant ERROR-UNAUTHORIZED u401)
(define-constant ERROR-NOT-GRANTED u402)
(define-constant NOT-OWNER-ERR (err 1))
(define-data-var is-receipt bool false)
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

(define-map validations {id: principal} {hash: (buff 256)})

(define-private (is-a-validator) 
  (is-some (map-get? validation-service-providers {id: tx-sender})))

;; add hash
(define-public (add-hash (id principal) (hash (buff 256)))
  (begin 
    (asserts! (is-a-validator) 
      (err ERROR-UNAUTHORIZED))
    (map-insert validations {id: id} {hash: hash})
    (ok true)
  ))

;; As a user (client) I could grant company Y access to my data within company X
;; Ids: ie. --STX address-- or NID or Biometrics
;; User: Principal
;; Company: Principal

;; access model
(define-map access-log
  {user: principal, recipient: principal, created-at: uint}
  {granted: bool}
)

(define-public (grant-access (validator principal) (recipient principal)) 
  (begin 
    (asserts! (is-some (map-get? validations {id: tx-sender})) 
      (err ERROR-UNAUTHORIZED))
    (map-set access-log 
      {user: tx-sender, recipient: recipient, created-at: block-height}
      {granted: false})
    (ok true)))


;; ownership model 
;; i.e the users blockstack data 
;; name and nid that i verify with and match stx address 
;; it is a map that matches all data with corresponding stx adresses 

(define-public (get-ownership) 
  (ok 
    {
      name: (map-get? access-log {user: princapl}),  
      id: (map-get? access-log {id: tx-sender}),
      owner: owner, 
      created-block: (map-get? access-log {created-at: block-height})
      data: (hash: (buff 256))
    }))


;; Always validate that the tx-sender
;; is the (contract owner, the kyc holder)
;; and validate that the request wasn't already granted
(define-private (is-kyc-holder) 
   (is-eq tx-sender (var-get (get-ownsership {id: tx-sender}))
)


;; Acess grant using ownership model
(define-public (mark-access-granted (user principal) (recipient principal) (created-at uint)) 
  (begin
    (asserts! (if (map-get? access-log {granted: tx-sender})) (err ERROR-UNAUTHORIZED))
    (if (is-kyc-holder)
    (begin map-set access-log
      {user: tx-sender, recipient: recipient, created-at: block-height}
      {granted: true})
      NOT-OWNER-ERR))
      (ok true))



;; Mark access recieved
;; each SP mints the valifications nfts 
(define-public (register-data-point (owner principal)) 
  (begin 
    (asserts! (is-eq creator tx-sender) (err ERROR-UNAUTHORIZED))
    (var-set is-reciept true)
    (nft-mint? data owner contract-address)
  ))


