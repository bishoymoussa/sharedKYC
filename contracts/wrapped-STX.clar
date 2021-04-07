;; (impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-10-ft-standard.ft-trait)

(define-trait ft-trait
  (
    ;; Transfer from the caller to a new principal
    (transfer (uint principal principal) (response bool uint))

    ;; the human readable name of the token
    (get-name () (response (string-ascii 32) uint))

    ;; the ticker symbol, or empty if none
    (get-symbol () (response (string-ascii 32) uint))

    ;; the number of decimals used, e.g. 6 would mean 1_000_000 represents 1 token
    (get-decimals () (response uint uint))

    ;; the balance of the passed principal
    (get-balance-of (principal) (response uint uint))

    ;; the current total supply (which does not need to be a constant)
    (get-total-supply () (response uint uint))

    ;; an optional URI that represents metadata of this token
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)


(define-trait pass-app-contract (
  (grant-license (uint) (response bool uint))
))


(define-constant contract (as-contract tx-sender))
(define-fungible-token wrapped-stx)

(define-public (wrap (amount uint)) 
  (let (
    (balance (stx-get-balance tx-sender))
    ) 
    (asserts! (>= balance amount) (err u400))
    (asserts! 
      (is-ok (stx-transfer? amount tx-sender contract))
    (err u500))
    (asserts! 
      (is-ok (ft-mint? wrapped-stx amount tx-sender))
    (err u500))
    (ok true)
  ))

(define-public (unwrap (amount uint) (memo (optional (string-ascii 256))))
  (let (
    (balance (ft-get-balance wrapped-stx tx-sender))
    (redeemer tx-sender)
    ) 
    (asserts! (>= balance amount) (err u400))
    (asserts! 
      (is-ok (as-contract (stx-transfer? amount tx-sender redeemer)))
    (err u500))
    (asserts! 
      (is-ok (ft-burn? wrapped-stx amount tx-sender))
    (err u500))
    (print memo)
    (ok true)
  ))


;; the human readable name of the token
(define-read-only (get-name) 
  (ok "Wrapped-STX"))
;; the ticker symbol, or empty if none PASS
(define-read-only (get-symbol) 
  (ok "WSTX"))

;; 10000000 the number of decimals used, e.g. 6 would mean 1_000_000 represents 1 token
(define-read-only (get-decimals) (ok u6))

;; the balance of the passed principal
(define-read-only (get-balance-of (sender principal)) 
  (ok (ft-get-balance wrapped-stx sender)))

;; Decentralized Autonomous Organization
;; DAOs
(wrap u100)
;; (contract-call? 
;;   'STDVYMRN5AYZ68011ZVKGXHSDK6CW740JQDNZD33.ardkon
;;   wrap  u27 )

;; the current total supply (which does not need to be a constant)

(define-public (swap (token-a <ft-trait>)
                      (amount-a uint)
                      (owner-a principal)
                      (token-b <ft-trait>)
                      (amount-b uint)
                      (owner-b principal))
      (begin
          (unwrap! (contract-call? token-a transfer amount-a owner-a owner-b) (err 1))
          (unwrap! (contract-call? token-b transfer amount-b owner-b owner-a) (err 1))
          (ok true)))

(define-public (apply-for-license 
;; a principal 'SP1BBF4MY50BJW4YT1NVQPZMG20S52S2C71TRK5B6.ardkon
                                  (contract-requestor <pass-app-contract>)
                                  (licensing-period uint))
(let ((balance (stx-get-balance tx-sender))) 
  (asserts! (>= balance licensing-period) (err u405))
  (is-ok (stx-transfer? licensing-period tx-sender 'SP1BBF4MY50BJW4YT1NVQPZMG20S52S2C71TRK5B6))
  (contract-call? contract-requestor grant-license licensing-period)))

(define-read-only (get-total-supply) 
  (ok (ft-get-supply wrapped-stx)))

;; an optional URI that represents metadata of this token
(define-read-only (get-token-uri) (ok none))

(define-public (transfer (amount uint) (sender principal) (recipient principal)) 
  (begin 
    (asserts! (is-eq tx-sender sender) (err u401))
    (ft-transfer? wrapped-stx amount sender recipient)
  ))
