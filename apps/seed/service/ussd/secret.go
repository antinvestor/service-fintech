// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package ussd

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"errors"
	"fmt"
	"strings"

	"golang.org/x/crypto/argon2"
	"golang.org/x/crypto/curve25519"
	"golang.org/x/crypto/nacl/box"
)

// sealedPrefix marks a value the USSD engine sealed for Seed.
const sealedPrefix = "sealed:"

var (
	// ErrNotSealed is returned for a secret input that arrived in the clear;
	// it is refused rather than trusted.
	ErrNotSealed = errors.New("ussd: secret input is not sealed")
	// ErrSealedForSomeoneElse is returned when the value does not open with
	// Seed's key.
	ErrSealedForSomeoneElse = errors.New("ussd: secret input does not open with seed's key")
)

// Opener opens secrets the engine sealed with Seed's public key.
type Opener struct {
	public  [32]byte
	private [32]byte
}

// NewOpener loads Seed's X25519 private key (base64). The public half is
// derived, and is what Seed registers with the engine.
func NewOpener(privateKeyB64 string) (*Opener, error) {
	raw, err := base64.StdEncoding.DecodeString(strings.TrimSpace(privateKeyB64))
	if err != nil || len(raw) != curve25519.ScalarSize {
		return nil, fmt.Errorf("ussd: secret key is not a base64 X25519 private key: %w", err)
	}
	o := &Opener{}
	copy(o.private[:], raw)
	pub, err := curve25519.X25519(o.private[:], curve25519.Basepoint)
	if err != nil {
		return nil, fmt.Errorf("ussd: derive public key: %w", err)
	}
	copy(o.public[:], pub)
	return o, nil
}

// PublicKey is the base64 public key the engine seals with.
func (o *Opener) PublicKey() string { return base64.StdEncoding.EncodeToString(o.public[:]) }

// Open returns the clear value of a sealed input.
func (o *Opener) Open(value string) (string, error) {
	if !strings.HasPrefix(value, sealedPrefix) {
		return "", ErrNotSealed
	}
	raw, err := base64.StdEncoding.DecodeString(strings.TrimPrefix(value, sealedPrefix))
	if err != nil {
		return "", ErrSealedForSomeoneElse
	}
	opened, ok := box.OpenAnonymous(nil, raw, &o.public, &o.private)
	if !ok {
		return "", ErrSealedForSomeoneElse
	}
	return string(opened), nil
}

// argon2id parameters (RFC 9106 second recommended option, lowered memory:
// a 4-6 digit PIN is guarded by the attempt limit, not the hash alone).
const (
	argonTime    = 3
	argonMemory  = 64 * 1024
	argonThreads = 2
	argonKeyLen  = 32
	argonSaltLen = 16
	hashScheme   = "argon2id"
)

// HashPIN returns "argon2id$<salt>$<hash>".
func HashPIN(pin string) (string, error) {
	salt := make([]byte, argonSaltLen)
	if _, err := rand.Read(salt); err != nil {
		return "", fmt.Errorf("ussd: pin salt: %w", err)
	}
	key := argon2.IDKey([]byte(pin), salt, argonTime, argonMemory, argonThreads, argonKeyLen)
	return hashScheme + "$" + base64.RawStdEncoding.EncodeToString(salt) + "$" +
		base64.RawStdEncoding.EncodeToString(key), nil
}

// CheckPIN reports whether pin matches a HashPIN result.
func CheckPIN(stored, pin string) bool {
	parts := strings.Split(stored, "$")
	if len(parts) != 3 || parts[0] != hashScheme {
		return false
	}
	salt, err := base64.RawStdEncoding.DecodeString(parts[1])
	if err != nil {
		return false
	}
	want, err := base64.RawStdEncoding.DecodeString(parts[2])
	if err != nil || len(want) != argonKeyLen {
		return false
	}
	got := argon2.IDKey([]byte(pin), salt, argonTime, argonMemory, argonThreads, argonKeyLen)
	return subtle.ConstantTimeCompare(got, want) == 1
}

// ValidPIN accepts four to six digits.
func ValidPIN(pin string) bool {
	if len(pin) < 4 || len(pin) > 6 {
		return false
	}
	for _, r := range pin {
		if r < '0' || r > '9' {
			return false
		}
	}
	return true
}
