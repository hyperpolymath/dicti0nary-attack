// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Security Research Team
// Notification system for user feedback

open Dom

type notificationType =
  | Success
  | Error
  | Warning
  | Info

let notificationColor = (t: notificationType): string =>
  switch t {
  | Success => "var(--color-success)"
  | Error => "var(--color-error)"
  | Warning => "var(--color-warning)"
  | Info => "var(--color-info)"
  }

let show = (message: string, notifType: notificationType): unit => {
  let color = notificationColor(notifType)

  let notification = Document.createElement("div")
  Element.textContent(notification, message)

  // Set inline styles
  let _ = %raw(`
    (function(el, color) {
      el.style.cssText = 'position: fixed; bottom: 2rem; right: 2rem; background: ' + color +
        '; color: var(--color-bg-primary); padding: 1rem 1.5rem; border-radius: 8px;' +
        ' box-shadow: var(--shadow-lg); font-weight: 600; z-index: 10000;' +
        ' animation: slideIn 0.3s ease;';
    })
  `)(notification, color)

  let _ = %raw(`document.body.appendChild`)(notification)

  // Remove after 3 seconds
  let _ = %raw(`
    setTimeout(function() {
      notification.style.animation = 'slideOut 0.3s ease';
      setTimeout(function() { notification.remove(); }, 300);
    }, 3000)
  `)

  ()
}
