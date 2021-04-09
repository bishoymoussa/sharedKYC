(define-constant creator tx-sender)

(define-map validation-service-providers
  {id: principal}
  {active: bool, name: (string-ascii 256)}
)

(define-non-fungible-token data principal)

(map-insert validation-service-providers 
  {id: 'SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB} {active: true, name: "NBE"})


(define-public (add-provider (address principal) (name (string-ascii 256))) 
  (begin
    (asserts! (is-eq creator tx-sender) (err u404))
    (ok 
      (map-insert validation-service-providers 
        {id: address} {active: true, name: name}))
  ))


;; consider the validation map

(define-map validations {id: principal, validator: principal} {hash: (buff 256)})

(define-private (is-a-validator) 
  (is-some (map-get? validation-service-providers {id: tx-sender})))

(define-public (add-hash (id principal) (hash (buff 256)))
  (begin 
    (asserts! (is-a-validator) 
      (err ERROR-UNAUTHORIZED))
    (map-insert validations {id: id, validator: tx-sender} {hash: hash})
    (nft-mint? data id id)
    (ok true)
  ))

;; As a user I could grant company Y access to my data within company X
;; Ids:
;; User: Principal
;; Company: Principal

(define-map access-log
  {user: principal, recipient: principal, validator: principal, created-at: uint,}
  {granted: bool, received: bool}
)

(define-public (grant-access (validator principal) (recipient principal) (validator principal)) 
  (begin 
    (asserts! (is-some (map-get? validations {id: tx-sender, validator: validator})) 
      (err u401))
    (map-insert access-log 
      {user: tx-sender, recipient: recipient, created-at: block-height, validator:  validator}
      {granted: false, received: false})
    (ok true)))

;; Always validate that the tx-sender
;; is the (contract owner, the kyc holder)
;; and validate that the request wasn't already granted
;; (define-public (mark-access-granted (user principal) (recipient principal) (created-at uint)) 

;;   (map-set 
;;     {user: tx-sender, recipient: recipient, created-at: block-height}
;;       {granted: true}))

;; Mark access received

;; ownership model 
;; i.e the users blockstack data 
;; name and nid that i verify with and match stx address 
;; it is a map that matches all data with corresponding stx adresses 

(define-read-only (get-access-log (user principal) (recipient principal) (validator principal) (created-at uint)) 
  (ok (map-get? access-log 
    {user: user, recipient: recipient, created-at: created-at})))
;; Always validate that the tx-sender
;; is the (contract owner, the kyc holder)
;; and validate that the request wasn't already granted
;; (define-private (is-kyc-holder) 
;;   (is-eq tx-sender (var-get (get-ownsership {id: tx-sender}))
;; )

;; Acess grant using ownership model
(define-public (mark-access-granted (user principal) (recipient principal) (created-at uint)) 
  (let
    (
      (key {user: user, recipient: recipient, validator: tx-sender, created-at: created-at})
      (access-request
        (unwrap! (map-get? access-log key) 
          (err u404)))
    )
    (asserts! (not (get granted access-request))
      (err u401))
    (ok 
      (map-set access-log key (merge access-request {granted: true}))
      )))

(define-public (mark-access-received (user principal) (validator principal) (created-at uint)) 
  (let
    (
      (access-request
        (unwrap! (map-get? access-log 
          {user: user, recipient: tx-sender, validator: validator, created-at: created-at}) 
          (err u404)))
    )
    ;; Do you need it to be granted before marking it as recieved
    ;; or the other way around?
    (asserts! (not (get granted access-request))
      (err u401))
    (ok 
      (map-set access-log
        {user: user, recipient: tx-sender, created-at: block-height, validator: validator}
        (merge access-request {received: true}))
      )))
;; Mark access recieved
;; each SP mints the valifications nfts 
;; (define-public (register-data-point (owner principal)) 
;;   (begin 
;;     (asserts! (is-eq creator tx-sender) (err ERROR-UNAUTHORIZED))
;;     (var-set is-reciept true)
;;     (nft-mint? data owner contract-address)
  ;; ))