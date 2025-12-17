;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;;
;; dicti0nary-attack - Guix Package Definition
;; Run: guix shell -D -f guix.scm
;; Build: guix build -f guix.scm

(use-modules (guix packages)
             (guix gexp)
             (guix git-download)
             (guix build-system cargo)
             ((guix licenses) #:prefix license:)
             (gnu packages base)
             (gnu packages crates-io)
             (gnu packages rust))

(define-public dicti0nary-attack
  (package
    (name "dicti0nary-attack")
    (version "0.1.0")
    (source (local-file "." "dicti0nary-attack-checkout"
                        #:recursive? #t
                        #:select? (git-predicate ".")))
    (build-system cargo-build-system)
    (arguments
     `(#:cargo-inputs
       (("rust-tokio" ,rust-tokio-1)
        ("rust-serde" ,rust-serde-1)
        ("rust-serde-json" ,rust-serde-json-1)
        ("rust-clap" ,rust-clap-4)
        ("rust-thiserror" ,rust-thiserror-1)
        ("rust-tracing" ,rust-tracing-0.1)
        ("rust-anyhow" ,rust-anyhow-1)
        ("rust-sha2" ,rust-sha2-0.10)
        ("rust-argon2" ,rust-argon2-0.5)
        ("rust-bcrypt" ,rust-bcrypt-0.15)
        ("rust-rand" ,rust-rand-0.8)
        ("rust-rayon" ,rust-rayon-1))
       #:phases
       (modify-phases %standard-phases
         (add-before 'build 'set-env
           (lambda _
             (setenv "RUST_BACKTRACE" "1")
             #t)))))
    (native-inputs
     (list rust-cargo))
    (synopsis "Security research utility for testing non-dictionary passwords")
    (description
     "dicti0nary-attack is a comprehensive security research utility designed
for testing non-dictionary passwords.  It provides multiple password generation
strategies (leetspeak, phonetic, pattern, random, Markov) and multi-algorithm
hash cracking (MD5, SHA256, bcrypt, Argon2).  This tool is intended for
authorized penetration testing, security audits, CTF competitions, and academic
research only.")
    (home-page "https://github.com/hyperpolymath/dicti0nary-attack")
    (license license:agpl3+)))

;; Return package for guix shell
dicti0nary-attack
