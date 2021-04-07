;; Company Registry NFT token
(define-non-fungible-token company-ticket-id (buff 50))

;; KYC Chain
;; Contract parties
(define-constant service-provider-reuqester 'SP5T0BR3GXMYWR3AH8A7AM70V6QY0BFDD0XWH3H6)
(define-constant service-provider-requestee 'SP5T0BR3GXMYWR3AH8A7AM70V6QY0BFDD0XWH3H6)


;; constants
(define-constant not-registered 1)
(define-constant kyc-matching-failed 2)

;; Chain of trust constants
(define-data-var is-kyc-verfied bool false)
(define-data-var is-kyc-valid bool true)

;; KYC Validity
(define-private (is-contract-in-effect) 
  (and 
  (var-get is-kyc-verfied)
  (var-get is-kyc-valid)))


