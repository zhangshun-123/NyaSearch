///|
enum Prework {
  Util(p~ : Array[Int64])
  Nil
}

///|
pub(all) struct StringHash {
  n : Int
  mod : Int64
  base : Int64
  hash : Array[Int64]
  prework : Prework
}

///|
let empty_hash : StringHash = StringHash::{
  n: 0,
  mod: 998244353,
  base: 131,
  hash: Array::make(0, 0),
  prework: Prework::Nil,
}

///|
pub fn StringHash::new(
  mod~ : Int64 = 998244353,
  base~ : Int64 = 131,
  s : String
) -> StringHash {
  let n = s.length()
  if n == 0 {
    return empty_hash
  }
  let p = Array::make(n + 1, 0L)
  let h = Array::make(n + 1, 0L)
  p[0] = 1
  h[0] = 1
  for i = 1; i <= n; i = i + 1 {
    p[i] = p[i - 1] * base % mod
    h[i] = (h[i - 1] * base + (s[i - 1] - 'a' + 1).to_int64()) % mod
  }
  StringHash::{ n, mod, base, hash: h, prework: Util(p~) }
}

///|
pub fn StringHash::get_hash(
  self : StringHash,
  left : Int,
  right : Int
) -> Int64 {
  let p = match self.prework {
    Util(p~) => p
    Nil => []
  }
  (
    self.hash[right + 1] -
    self.hash[left] * p[right - left + 1] % self.mod +
    self.mod
  ) %
  self.mod
}

///|
fn rabin_karp(text : String, pattern : String) -> Int {
  let n = text.length()
  let m = pattern.length()
  let text_hash = StringHash::new(text)
  let pattern_hash = StringHash::new(pattern)
  let pattern_hash_value = pattern_hash.get_hash(0, m - 1)
  for i = 0; i < n - m + 1; i = i + 1 {
    let window_hash = text_hash.get_hash(i, i + m - 1)
    if window_hash == pattern_hash_value {
      let mut is_match = true
      for j in 0..<m {
        if text[i + j] != pattern[j] {
          is_match = false
          break
        }
      }
      if is_match {
        return i
      }
    }
  }
  -1
}

///|
test "boyer_moore/basic" {
  inspect!(rabin_karp("hello world", "world"), content="6")
  inspect!(rabin_karp("AABAACAADAABAAABAA", "AABA"), content="0")
  inspect!(rabin_karp("THIS IS A TEST TEXT", "TEST"), content="10")
}

///|
test "boyer_moore/pattern_not_found" {
  inspect!(rabin_karp("hello world", "moon"), content="-1")
  inspect!(rabin_karp("AABAACAADAABAAABAA", "ZZZ"), content="-1")
}