;; Advanced Digital Identity Verification System

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-found (err u102))
(define-constant err-already-verified (err u103))
(define-constant err-not-verified (err u104))
(define-constant err-invalid-attestation (err u105))
(define-constant err-invalid-credentials (err u106))
(define-constant err-expired (err u107))
(define-constant err-insufficient-reputation (err u108))
(define-constant err-blacklisted (err u109))

;; Use a simple variable for block height since Clarinet version doesn't support block-height or get-block-info?
(define-data-var current-block-height uint u0)

;; Helper function to get and increment the simulated block height
(define-public (get-height)
  (ok (var-get current-block-height)))

;; Helper function to simulate block advancement
(define-public (advance-block)
  (ok (var-set current-block-height (+ (var-get current-block-height) u1))))

;; Data Maps
(define-map identities
  { address: principal }
  { name: (string-utf8 50),
    email: (string-utf8 50),
    verified: bool,
    timestamp: uint,
    reputation: uint,
    revoked: bool,
    verification-level: uint,
    last-active: uint,
    recovery-address: (optional principal) })

(define-map identity-attributes
  { address: principal, key: (string-utf8 50) }
  { value: (string-utf8 100) })

(define-map attestations
  { attester: principal, subject: principal }
  { timestamp: uint, 
    valid: bool,
    expiration: uint,
    confidence-score: uint })

(define-map verification-methods
  { address: principal }
  { kyc-verified: bool,
    two-factor-enabled: bool,
    biometric-verified: bool })

(define-map trusted-validators
  { address: principal }
  { trust-score: uint,
    valid-until: uint,
    verified-count: uint })

(define-map blacklisted-addresses
  { address: principal }
  { reason: (string-utf8 100),
    timestamp: uint })

(define-map recovery-requests
  { address: principal }
  { new-address: principal,
    timestamp: uint,
    approvals: uint })

;; Basic Identity Functions
(define-public (register-identity (name (string-utf8 50)) (email (string-utf8 50)))
  (let ((caller tx-sender))
    (match (map-get? identities { address: caller })
           existing-identity
           err-already-registered
           (begin
             (map-set identities
               { address: caller }
               { name: name, 
                 email: email, 
                 verified: false, 
                 timestamp: (var-get current-block-height),
                 reputation: u0,
                 revoked: false,
                 verification-level: u0,
                 last-active: (var-get current-block-height),
                 recovery-address: none })
             (ok true)))))

(define-public (verify-identity (address principal))
  (if (is-eq tx-sender contract-owner)
      (match (map-get? identities { address: address })
             identity
             (if (get verified identity)
                 err-already-verified
                 (begin
                   (map-set identities
                     { address: address }
                     (merge identity { verified: true }))
                   (ok true)))
             err-not-found)
      err-not-owner))

(define-read-only (is-verified (address principal))
  (match (map-get? identities { address: address })
         identity
         (and (get verified identity) (not (get revoked identity)))
         false))

(define-public (enable-two-factor)
  (let ((caller tx-sender))
    (match (map-get? verification-methods { address: caller })
           method
           (begin
             (map-set verification-methods
               { address: caller }
               (merge method { two-factor-enabled: true }))
             (ok true))
           (begin
             (map-set verification-methods
               { address: caller }
               { kyc-verified: false,
                 two-factor-enabled: true,
                 biometric-verified: false })
             (ok true)))))

(define-public (initiate-recovery (new-address principal))
  (match (map-get? identities { address: tx-sender })
         identity
         (begin
           (map-set recovery-requests
             { address: tx-sender }
             { new-address: new-address,
               timestamp: (var-get current-block-height),
               approvals: u0 })
           (ok true))
         err-not-found))

(define-public (complete-recovery (old-address principal))
  (match (map-get? recovery-requests { address: old-address })
         request
         (if (>= (get approvals request) u3)
             (match (map-get? identities { address: old-address })
                    identity
                    (begin
                      (map-delete identities { address: old-address })
                      (map-set identities
                        { address: (get new-address request) }
                        identity)
                      (map-delete recovery-requests { address: old-address })
                      (ok true))
                    err-not-found)
             err-insufficient-reputation)
         err-not-found))

(define-public (update-activity)
  (match (map-get? identities { address: tx-sender })
         identity
         (begin
           (map-set identities
             { address: tx-sender }
             (merge identity { last-active: (var-get current-block-height) }))
           (ok true))
         err-not-found))

(define-public (upgrade-verification-level (address principal))
  (if (is-eq tx-sender contract-owner)
      (match (map-get? identities { address: address })
             identity
             (let ((current-level (get verification-level identity)))
               (if (< current-level u3)
                   (begin
                     (map-set identities
                       { address: address }
                       (merge identity { verification-level: (+ current-level u1) }))
                     (ok true))
                   (ok true)))
             err-not-found)
      err-not-owner))

(define-read-only (get-validator-stats (address principal))
  (map-get? trusted-validators { address: address }))

(define-read-only (is-attestation-expired (attester principal) (subject principal))
  (match (map-get? attestations { attester: attester, subject: subject })
         attestation
         (>= (var-get current-block-height) (get expiration attestation))
         true))

(define-read-only (get-verification-level (address principal))
  (match (map-get? identities { address: address })
         identity
         (get verification-level identity)
         u0))

(define-public (register-validator)
  (if (is-verified tx-sender)
      (begin
        (map-set trusted-validators
          { address: tx-sender }
          { trust-score: u1,
            valid-until: (+ (var-get current-block-height) u52560),
            verified-count: u0 })
        (ok true))
      err-not-verified))

(define-public (blacklist-address (address principal) (reason (string-utf8 100)))
  (if (is-eq tx-sender contract-owner)
      (begin
        (map-set blacklisted-addresses
          { address: address }
          { reason: reason,
            timestamp: (var-get current-block-height) })
        (ok true))
      err-not-owner))

(define-read-only (is-blacklisted (address principal))
  (is-some (map-get? blacklisted-addresses { address: address })))

(define-public (approve-recovery (address principal))
  (let ((validator-info (map-get? trusted-validators { address: tx-sender }))
        (recovery-info (map-get? recovery-requests { address: address })))
    (if (and (is-some validator-info) 
             (is-some recovery-info))
        (let ((request (unwrap! recovery-info err-not-found)))
          (begin
            (map-set recovery-requests
              { address: address }
              (merge request { approvals: (+ (get approvals request) u1) }))
            (ok true)))
        err-not-verified)))