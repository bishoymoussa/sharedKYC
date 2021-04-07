(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-10-ft-standard.ft-trait)

;; NFT => Non-fungible tokens, nifty
;; unique
;; example picture of an egg #1 => N
;; uuid guid
(define-non-fungible-token kitchen-item
  {image: (string-utf8 256), index: uint})

(nft-mint? kitchen-item 
{
  image: u"https://upload.wikimedia.org/wikipedia/en/5/58/Instagram_egg.jpg",
  index: u1
} 
  'SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB)


(nft-burn? kitchen-item 
{
  image: u"https://upload.wikimedia.org/wikipedia/en/5/58/Instagram_egg.jpg",
  index: u1
} 'SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB)

(nft-transfer? kitchen-item 
{
  image: u"https://upload.wikimedia.org/wikipedia/en/5/58/Instagram_egg.jpg",
  index: u1
} 
  'SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB 'SP000000000000000000002Q6VF78)

(nft-get-owner? kitchen-item 
{
  image: u"https://upload.wikimedia.org/wikipedia/en/5/58/Instagram_egg.jpg",
  index: u1
})


;; FT => Fungible token
(define-fungible-token access-token u500)
(define-fungible-token access-token-vip u12)

;; 1 SimonDollar === 1 SimonDollar

(define-public (give-access (amount uint) (recipient principal)) 
;; be sure to not let everyone into this function
;; is-creator
  (ft-mint? access-token amount recipient))

(define-public (use-access) 
  (ft-burn? access-token u1 tx-sender))

(ft-get-balance access-token tx-sender)
(ft-get-supply access-token)

;; (ft-transfer? access-tokens u2 sender recipient)


;; (stx-transfer? amount tx-sender recipient)

(define-fungible-token nothing)

;; the human readable name of the token
(define-read-only (get-name) 
  (ok "Nothing"))
;; the ticker symbol, or empty if none PASS
(define-read-only (get-symbol) 
  (ok "MNO"))

;; 10000000 the number of decimals used, e.g. 6 would mean 1_000_000 represents 1 token
(define-read-only (get-decimals) (ok u6))

;; the balance of the passed principal
(define-read-only (get-balance-of (sender principal)) 
  (ok (ft-get-balance nothing sender)))

;; the current total supply (which does not need to be a constant)

(define-read-only (get-total-supply) 
  (ok (ft-get-supply nothing)))

;; an optional URI that represents metadata of this token
(define-read-only (get-token-uri) (ok none))

(define-public (transfer (amount uint) (sender principal) (recipient principal)) 
  (begin 
    (asserts! (is-eq tx-sender sender) (err u401))
    (ft-transfer? nothing amount sender recipient)
  ))