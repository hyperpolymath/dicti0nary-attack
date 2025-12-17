;;; STATE.scm - Project Checkpoint
;;; dicti0nary-attack
;;; Format: Guile Scheme S-expressions
;;; Purpose: Preserve AI conversation context across sessions
;;; Reference: https://github.com/hyperpolymath/state.scm

;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell

;;;============================================================================
;;; METADATA
;;;============================================================================

(define metadata
  '((version . "0.1.0")
    (schema-version . "1.0")
    (created . "2025-12-15")
    (updated . "2025-12-17")
    (project . "dicti0nary-attack")
    (repo . "github.com/hyperpolymath/dicti0nary-attack")))

;;;============================================================================
;;; PROJECT CONTEXT
;;;============================================================================

(define project-context
  '((name . "dicti0nary-attack")
    (tagline . "A comprehensive security research utility for testing non-dictionary passwords")
    (version . "0.1.0")
    (license . "AGPL-3.0-or-later")
    (rsr-compliance . "bronze-86%")
    (rsr-target . "silver-90%")

    (tech-stack
     ((primary-language . "Rust")
      (secondary-languages . ("Chapel" "JavaScript"))
      (package-management . "Guix (primary) / Nix (fallback)")
      (ci-cd . "GitHub Actions + GitLab CI + Bitbucket Pipelines")
      (security . "CodeQL + OSSF Scorecard + Security Policy CI")
      (containerization . "Podman")))))

;;;============================================================================
;;; CURRENT POSITION
;;;============================================================================

(define current-position
  '((phase . "v0.1 - Initial Setup and RSR Compliance")
    (overall-completion . 35)

    (components
     ((rust-core
       ((status . "functional")
        (completion . 60)
        (notes . "Core crates (core, generators, crackers) implemented. CLI working.")))

      (chapel-wasm
       ((status . "scaffolded")
        (completion . 40)
        (notes . "Chapel source files exist. WASM compilation configured but needs testing.")))

      (web-interface
       ((status . "functional")
        (completion . 70)
        (notes . "Static HTML/CSS/JS web interface working. JavaScript needs ReScript conversion.")))

      (rsr-compliance
       ((status . "bronze")
        (completion . 86)
        (notes . "SHA-pinned actions, SPDX headers, multi-platform CI, security workflows")))

      (documentation
       ((status . "good")
        (completion . 75)
        (notes . "README, SECURITY, CONTRIBUTING, CoC, CHANGELOG, RSR_COMPLIANCE all present")))

      (testing
       ((status . "minimal")
        (completion . 20)
        (notes . "CI/CD scaffolding exists, test frameworks configured, limited actual tests")))

      (scm-files
       ((status . "complete")
        (completion . 100)
        (notes . "guix.scm, META.scm, ECOSYSTEM.scm, STATE.scm all present and valid")))))

    (working-features
     ("5 password generators (leetspeak, phonetic, pattern, random, Markov)"
      "Multi-algorithm hash cracking (MD5, SHA256, bcrypt, Argon2)"
      "Rust CLI with clap argument parsing"
      "Web interface with tab navigation"
      "RSR-compliant CI/CD pipeline (14 workflows)"
      "Multi-platform mirroring (GitHub, GitLab, Bitbucket)"
      "SHA-pinned GitHub Actions"
      "RFC 9116 security.txt"
      "Podman containerization"))))

;;;============================================================================
;;; ROUTE TO MVP
;;;============================================================================

(define route-to-mvp
  '((target-version . "1.0.0")
    (definition . "Production-ready release with comprehensive tests, documentation, and security audit")

    (milestones
     ((v0.2
       ((name . "Core Stabilization")
        (status . "in-progress")
        (target-completion . 50)
        (items
         ("Complete Rust test suite (>70% coverage)"
          "Fix all clippy warnings"
          "Add property-based tests for generators"
          "Document all public APIs"
          "Convert web/static/js/*.js to ReScript"))))

      (v0.3
       ((name . "Chapel/WASM Integration")
        (status . "pending")
        (target-completion . 65)
        (items
         ("Compile Chapel modules to WASM"
          "Integrate WASM with web interface"
          "Performance benchmarks vs pure JS"
          "Add Chapel unit tests"))))

      (v0.5
       ((name . "Feature Complete")
        (status . "pending")
        (target-completion . 80)
        (items
         ("All 5 generators fully implemented in Rust + Chapel"
          "All hash algorithms working"
          "Test coverage > 80%"
          "API stability guaranteed"
          "RSR Silver compliance (90%+)"))))

      (v0.8
       ((name . "Security Hardening")
        (status . "pending")
        (target-completion . 95)
        (items
         ("External security audit"
          "Fuzzing test suite"
          "Memory safety verification"
          "Input validation hardening"
          "Rate limiting in web interface"))))

      (v1.0
       ((name . "Production Release")
        (status . "pending")
        (target-completion . 100)
        (items
         ("Comprehensive documentation"
          "Performance optimization"
          "Published to crates.io"
          "Docker/Podman images on registry"
          "RSR Gold compliance target"))))))))

;;;============================================================================
;;; BLOCKERS & ISSUES
;;;============================================================================

(define blockers-and-issues
  '((critical
     ())  ;; No critical blockers

    (high-priority
     ((rescript-conversion
       ((description . "JavaScript files must be converted to ReScript per project policy")
        (files . ("web/static/js/app.js" "web/static/js/wasm-loader.js"))
        (impact . "CI policy blocks new JS; legacy files need migration")
        (needed . "ReScript build setup, file conversion, delete originals")))))

    (medium-priority
     ((test-coverage
       ((description . "Limited test coverage in Rust crates")
        (impact . "Risk of regressions, harder to refactor")
        (needed . "Unit tests, integration tests, property tests")))

      (chapel-testing
       ((description . "Chapel WASM compilation untested in CI")
        (impact . "May not work in production")
        (needed . "Add Chapel build/test to CI workflow")))

      (nix-fallback
       ((description . "No flake.nix for Nix fallback")
        (impact . "Only Guix users can use reproducible builds")
        (needed . "Add flake.nix with same dependencies as guix.scm")))))

    (low-priority
     ((spdx-headers
       ((description . "Some source files missing SPDX headers")
        (impact . "License compliance, RSR Silver requirement")
        (needed . "Add headers to all .rs, .chpl, .js files")))

      (github-templates
       ((description . "Missing issue and PR templates")
        (impact . "Community contribution friction")
        (needed . "Add .github/ISSUE_TEMPLATE/ and PULL_REQUEST_TEMPLATE.md")))))))

;;;============================================================================
;;; CRITICAL NEXT ACTIONS
;;;============================================================================

(define critical-next-actions
  '((immediate
     (("Convert app.js and wasm-loader.js to ReScript" . critical)
      ("Add Rust unit tests for generators crate" . high)
      ("Add Rust unit tests for crackers crate" . high)
      ("Verify Cargo builds successfully" . high)))

    (this-week
     (("Set up ReScript build toolchain" . high)
      ("Add flake.nix for Nix fallback" . medium)
      ("Add property-based tests with proptest" . medium)
      ("Document generator algorithms" . medium)))

    (this-month
     (("Reach v0.2 milestone (50% completion)" . high)
      ("Achieve RSR Silver compliance (90%)" . high)
      ("Test Chapel WASM compilation" . medium)
      ("Add fuzzing tests" . medium)))

    (this-quarter
     (("Complete v0.5 feature-complete release" . high)
      ("External security review" . high)
      ("Performance optimization pass" . medium)))))

;;;============================================================================
;;; SECURITY STATUS
;;;============================================================================

(define security-status
  '((implemented
     ("RFC 9116 security.txt"
      "Coordinated vulnerability disclosure process"
      "CVSS 3.1 severity scoring"
      "SHA-pinned GitHub Actions"
      "CodeQL weekly scanning"
      "Secret detection in CI"
      "HTTP URL blocking in CI"
      "Weak crypto detection (MD5/SHA1 warning)"
      "Safe harbor for researchers"))

    (pending
     ("External security audit"
      "Fuzzing test suite"
      "Memory safety formal verification"
      "Rate limiting in web UI"
      "Input sanitization audit"))

    (known-limitations
     ("MD5/SHA1 supported for legacy compatibility (documented in CRYPTO_NOTICE.md)"
      "Web UI should only run on localhost or behind auth"))))

;;;============================================================================
;;; SESSION HISTORY
;;;============================================================================

(define session-history
  '((snapshots
     ((date . "2025-12-15")
      (session . "initial-state-creation")
      (accomplishments
       ("Added META.scm, ECOSYSTEM.scm, STATE.scm"
        "Established RSR compliance"
        "Created initial project checkpoint"))
      (notes . "First STATE.scm checkpoint created via automated script"))

     ((date . "2025-12-17")
      (session . "scm-security-review")
      (accomplishments
       ("Fixed guix.scm: Added proper synopsis, description, cargo dependencies"
        "Fixed Cargo.toml: Updated bcrypt from 0.15 to 0.17"
        "Fixed security.txt: Corrected URL casing (Hyperpolymath -> hyperpolymath)"
        "Updated STATE.scm with comprehensive roadmap"
        "Identified ReScript conversion as high-priority blocker"
        "Documented security status and known limitations"))
      (notes . "SCM and security review session, updated roadmap to reflect actual state")))))

;;;============================================================================
;;; HELPER FUNCTIONS (for Guile evaluation)
;;;============================================================================

(define (get-completion-percentage component)
  "Get completion percentage for a component"
  (let ((comp (assoc component (cdr (assoc 'components current-position)))))
    (if comp
        (cdr (assoc 'completion (cdr comp)))
        #f)))

(define (get-blockers priority)
  "Get blockers by priority level"
  (cdr (assoc priority blockers-and-issues)))

(define (get-milestone version)
  "Get milestone details by version"
  (assoc version (cdr (assoc 'milestones route-to-mvp))))

;;;============================================================================
;;; EXPORT SUMMARY
;;;============================================================================

(define state-summary
  '((project . "dicti0nary-attack")
    (version . "0.1.0")
    (overall-completion . 35)
    (rsr-compliance . "bronze-86%")
    (next-milestone . "v0.2 - Core Stabilization")
    (critical-blockers . 0)
    (high-priority-issues . 1)
    (medium-priority-issues . 3)
    (updated . "2025-12-17")))

;;; End of STATE.scm
