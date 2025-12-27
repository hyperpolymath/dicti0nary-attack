// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2025 Security Research Team
// Password generators - ReScript fallback implementations
// Primary generators are Chapel/WASM; these are JavaScript fallbacks

open Dom

type generatorType =
  | Leetspeak
  | Phonetic
  | Pattern
  | Random
  | Markov

let generatorTypeFromString = (s: string): option<generatorType> =>
  switch s {
  | "leetspeak" => Some(Leetspeak)
  | "phonetic" => Some(Phonetic)
  | "pattern" => Some(Pattern)
  | "random" => Some(Random)
  | "markov" => Some(Markov)
  | _ => None
  }

let generatorTypeToString = (g: generatorType): string =>
  switch g {
  | Leetspeak => "leetspeak"
  | Phonetic => "phonetic"
  | Pattern => "pattern"
  | Random => "random"
  | Markov => "markov"
  }

// Random helper
let randomInt = (max: int): int => Math.floor(Math.random() *. Int.toFloat(max))

let randomChar = (chars: string): string => {
  let idx = randomInt(String.length(chars))
  String.charAt(chars, idx)
}

// Leetspeak generator
let leetMap: Dict.t<string> = Dict.fromArray([
  ("a", "4"),
  ("e", "3"),
  ("i", "1"),
  ("o", "0"),
  ("s", "5"),
  ("t", "7"),
])

let words = ["password", "admin", "login", "secure", "access", "system"]

let generateLeetspeak = (minLen: int, maxLen: int): string => {
  let word = words->Array.getUnsafe(randomInt(Array.length(words)))
  let chars = String.split(word, "")

  let result = chars->Array.map(c => {
    if Math.random() > 0.5 {
      switch Dict.get(leetMap, c) {
      | Some(replacement) => replacement
      | None => c
      }
    } else {
      c
    }
  })->Array.join("")

  // Add numbers to reach minimum length
  let resultRef = ref(result)
  while String.length(resultRef.contents) < minLen {
    resultRef := resultRef.contents ++ Int.toString(randomInt(10))
  }

  String.slice(resultRef.contents, ~start=0, ~end=maxLen)
}

// Phonetic generator
let phonetic = ["for", "to", "you", "see", "why", "are", "bee", "sea"]
let phoneticNums = ["4", "2", "u", "c", "y", "r", "b", "c"]

let generatePhonetic = (minLen: int, maxLen: int): string => {
  let result = ref("")
  let iterations = (maxLen + 2) / 3

  for _ in 0 to iterations - 1 {
    if String.length(result.contents) < maxLen {
      let idx = randomInt(Array.length(phonetic))
      if Math.random() > 0.5 {
        result := result.contents ++ phonetic->Array.getUnsafe(idx)
      } else {
        result := result.contents ++ phoneticNums->Array.getUnsafe(idx)
      }
    }
  }

  let len = String.length(result.contents)
  String.slice(result.contents, ~start=0, ~end=Int.min(Int.max(minLen, len), maxLen))
}

// Pattern generator
let patterns = [
  "qwerty",
  "asdfgh",
  "zxcvbn",
  "123456",
  "qazwsx",
  "qwertyuiop",
  "asdfghjkl",
  "1qaz2wsx",
  "zaq12wsx",
]

let reverseString = (s: string): string =>
  String.split(s, "")->Array.reverse->Array.join("")

let generatePattern = (minLen: int, maxLen: int): string => {
  let pattern = patterns->Array.getUnsafe(randomInt(Array.length(patterns)))

  let result = if Math.random() > 0.5 {
    reverseString(pattern)
  } else {
    pattern
  }

  let result = result ++ Int.toString(randomInt(1000))
  let len = String.length(result)
  String.slice(result, ~start=0, ~end=Int.min(Int.max(minLen, len), maxLen))
}

// Random generator
let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

let generateRandom = (minLen: int, maxLen: int): string => {
  let length = minLen + randomInt(maxLen - minLen + 1)
  let result = ref("")

  for _ in 0 to length - 1 {
    result := result.contents ++ randomChar(chars)
  }

  result.contents
}

// Markov generator (simple bigram-based)
let bigrams = ["th", "he", "in", "er", "an", "re", "on", "at", "en", "ed"]

let generateMarkov = (minLen: int, maxLen: int): string => {
  let length = minLen + randomInt(maxLen - minLen + 1)
  let result = ref("")

  while String.length(result.contents) < length {
    result := result.contents ++ bigrams->Array.getUnsafe(randomInt(Array.length(bigrams)))
  }

  String.slice(result.contents, ~start=0, ~end=length)
}

// Main generator function
let generate = (genType: generatorType, count: int, minLen: int, maxLen: int): array<string> => {
  Array.make(~length=count, ())->Array.map(_ =>
    switch genType {
    | Leetspeak => generateLeetspeak(minLen, maxLen)
    | Phonetic => generatePhonetic(minLen, maxLen)
    | Pattern => generatePattern(minLen, maxLen)
    | Random => generateRandom(minLen, maxLen)
    | Markov => generateMarkov(minLen, maxLen)
    }
  )
}
