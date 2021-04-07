;; POC for Shared KYC Smart Contract Service

(define-data-var NumberOfValidatedServiceProviders uint u0)

;; example user Me Bishoy As Service Provider
(define-constant BishoyAddress 'SP5T0BR3GXMYWR3AH8A7AM70V6QY0BFDD0XWH3H6)

(define-constant ERROR-UNAUTHORIZED u401)

;; Map to store validated Service Providers
(define-map validation-service-providers
  {id: principal}
  {active: bool, name: (string-ascii 256)}
)

(map-insert validation-service-providers 
  {id: 'SP5T0BR3GXMYWR3AH8A7AM70V6QY0BFDD0XWH3H6} {active: true, name: "CIB"}
  {id: 'SP5T0BR3GXMYWR3AH8A7AM70V6QY0BFDD0XWH3H6} {active: true, name: "NBE"}
  {id: 'SP5T0BR3GXMYWR3AH8A7AM70V6QY0BFDD0XWH3H6} {active: true, name: "VODAFONE"})

;; consider the validation map
;; has id and hash
(define-map validations {id: uint} {hash: (buff 256)})

;; check if validator
(define-private (is-a-validator) 
  (is-some (map-get? validation-service-providers {id: tx-sender})))

;; add hash
;; add id using the princaple
(define-public (add-hash (id uint) (hash (buff 256)))
  (begin 
    (asserts! (is-a-validator) 
      (err ERROR-UNAUTHORIZED))
    (map-insert validations {id: id} {hash: hash})
    (ok true)
  ))

;; formalizing access control 
;; as if I am creating (Tinder) Matcher
;; map access grants --> func. (requester_princple(service provider), service_provider)
;; loop chain --> (source of truth) single source of truth
;; all on chain to assure trust between parties
;; trust is on code
;; don't put sensitive data of chain since it's pub. 
;; ;; Add token as validation ? Maybe
;; (define-non-fungible-token KYC-item
;;   {data: (string-utf8 256), index: uint})


;; ;; the data would be stored somehow

;; (nft-mint? KYC-item
;; {
;;   data: u"https://tinyurl.com/e5brt4kd",
;;   index: u1
;; } 
;;   'SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB)