;; SPDX-License-Identifier: AGPL-3.0-or-later
;; SPDX-FileCopyrightText: 2025 Jonathan D.A. Jewell
;; ECOSYSTEM.scm — dicti0nary-attack

(ecosystem
  (version "1.0.0")
  (name "dicti0nary-attack")
  (type "project")
  (purpose "> A comprehensive security research utility for testing non-dictionary passwords")

  (position-in-ecosystem
    "Part of hyperpolymath ecosystem. Follows RSR guidelines.")

  (related-projects
    (project (name "rhodium-standard-repositories")
             (url "https://github.com/hyperpolymath/rhodium-standard-repositories")
             (relationship "standard")))

  (what-this-is "> A comprehensive security research utility for testing non-dictionary passwords")
  (what-this-is-not "- NOT exempt from RSR compliance"))
