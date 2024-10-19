+++
title = "Crypto"

[extra]

level = 1

intro = "Cryptography is a corner stone of a trusted web. Without it many services could not be offered  reliably. Rust has strong cryptography libraries. Many of these are managed by [Rust Crypto](https://github.com/RustCrypto), an organization that maintains cryptography algorithms written in pure Rust."

suites = [
  "openssl",
  "orion",
  "gpgme",
  "ring"
]

rng = [
  "rand",
  "uuid"
]

tls = [
  "rustls",
  "tokio-openssl",
  "tokio-rustls",
  "openssl",
  "webpki",
]

hashing = [
  "bcrypt",
  "blake2",
  "djangohashers",
  "hmac",
  "fnv",
  "twox-hash",
  "md-5",
  "sha2",
  "pwhash"
]

algorithms = [
  "aes-gcm",
  "bulletproofs",
  "chacha20poly1305",
  "curve25519-dalek",
  "ed25519-dalek",
  "secp256k1",
  "subtle",
  "twox-hash",
  "x25519-dalek"
]

newstag = "crypto"
+++

<div>

<h2>Suites {{ level(level=1) }}</h2>

{{ packages(packages='suites') }}

<h2>Random Number Generators  {{ level(level=0) }}</h2>

{{ packages(packages='rng') }}

<h2>Hashing  {{ level(level=1) }}</h2>

{{ packages(packages='hashing') }}

<h2>Algorithms  {{ level(level=1) }}</h2>

{{ packages(packages='algorithms') }}

<h2>TLS  {{ level(level=1) }}</h2>

{{ packages(packages='tls') }}
