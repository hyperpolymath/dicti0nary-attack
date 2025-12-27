// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Security Research Team
// DOM bindings for dicti0nary-attack web interface

module Element = {
  type t

  @send external querySelector: (t, string) => Nullable.t<t> = "querySelector"
  @send external querySelectorAll: (t, string) => array<t> = "querySelectorAll"
  @send external getAttribute: (t, string) => Nullable.t<string> = "getAttribute"
  @send external setAttribute: (t, string, string) => unit = "setAttribute"
  @send external addEventListener: (t, string, unit => unit) => unit = "addEventListener"
  @send external classList: t => {"add": string => unit, "remove": string => unit} = "classList"
  @set external hidden: (t, bool) => unit = "hidden"
  @set external textContent: (t, string) => unit = "textContent"
  @set external innerHTML: (t, string) => unit = "innerHTML"
  @set external disabled: (t, bool) => unit = "disabled"
  @get external value: t => string = "value"
}

module Document = {
  @val external getElementById: string => Nullable.t<Element.t> = "document.getElementById"
  @val external querySelector: string => Nullable.t<Element.t> = "document.querySelector"
  @val external querySelectorAll: string => array<Element.t> = "document.querySelectorAll"
  @val external createElement: string => Element.t = "document.createElement"
  @val external body: Element.t = "document.body"
  @val external head: Element.t = "document.head"
  @val external readyState: string = "document.readyState"
  @val external addEventListener: (string, unit => unit) => unit = "document.addEventListener"
}

module Window = {
  @val external addEventListener: (string, unit => unit) => unit = "window.addEventListener"
  @val external dispatchEvent: 'a => unit = "window.dispatchEvent"
}

module Console = {
  @val external log: 'a => unit = "console.log"
  @val external warn: 'a => unit = "console.warn"
  @val external error: 'a => unit = "console.error"
}

module Navigator = {
  module Clipboard = {
    @val external writeText: string => Js.Promise.t<unit> = "navigator.clipboard.writeText"
  }
}

module Performance = {
  @val external now: unit => float = "performance.now"
}

module Math = {
  @val external floor: float => int = "Math.floor"
  @val external random: unit => float = "Math.random"
  @val external abs: int => int = "Math.abs"
}
