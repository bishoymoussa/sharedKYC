(define-non-fungible-token participation (string-ascii 256))

(define-constant participants
  (list 
    {
      name:"Vladimir Novachki aka Vlad, Stornest",
      address: 'SP2T0QC6JP2DS0N3YQYNW8V9BZNTHJCW3A56ZB5KK,
    }
    {
      name:"Simon Semaan aka planet9, ardkon.com",
      address: 'SP1BBF4MY50BJW4YT1NVQPZMG20S52S2C71TRK5B6,
    }
    {
      name:"Roland Naddour aka TMDR11",
      address: 'STDVYMRN5AYZ68011ZVKGXHSDK6CW740JQDNZD33,
    }
    {
      name:"Ibrahim Shedid strong, bypa-ss.com",
      address: 'SP5T0BR3GXMYWR3AH8A7AM70V6QY0BFDD0XWH3H6,
    }
    {
      name:"Mario Nassef, tandasmart.com",
      address: 'SP5T0BR3GXMYWR3AH8A7AM70V6QY0BFDD0XWH3H6,
    }
    {
      name:"Hany Boraie, PassApp",
      address: 'SP5T0BR3GXMYWR3AH8A7AM70V6QY0BFDD0XWH3H6,
    }
    {
      name:"Bishoy Moussa, valify.me",
      address: 'SP5T0BR3GXMYWR3AH8A7AM70V6QY0BFDD0XWH3H6,
    }
  ))




(map say-name participants)





(define-private (say-name (name (string-ascii 256))) 
  (begin 
    (print name)
    (nft-mint? participation name tx-sender)))
