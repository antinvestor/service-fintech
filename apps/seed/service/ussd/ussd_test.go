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
	"context"
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"golang.org/x/crypto/nacl/box"
)

func newTestOpener(t *testing.T) *Opener {
	t.Helper()
	_, private, err := box.GenerateKey(rand.Reader)
	require.NoError(t, err)
	o, err := NewOpener(base64.StdEncoding.EncodeToString(private[:]))
	require.NoError(t, err)
	return o
}

// sealFor seals as the USSD engine does, with the opener's public key.
func sealFor(t *testing.T, o *Opener, value string) string {
	t.Helper()
	sealed, err := box.SealAnonymous(nil, []byte(value), &o.public, rand.Reader)
	require.NoError(t, err)
	return sealedPrefix + base64.StdEncoding.EncodeToString(sealed)
}

func TestOpenerOpensOnlyWhatWasSealedForIt(t *testing.T) {
	seed := newTestOpener(t)
	other := newTestOpener(t)

	got, err := seed.Open(sealFor(t, seed, "4321"))
	require.NoError(t, err)
	assert.Equal(t, "4321", got)

	_, err = seed.Open(sealFor(t, other, "4321"))
	require.ErrorIs(t, err, ErrSealedForSomeoneElse)

	_, err = seed.Open("4321")
	require.ErrorIs(t, err, ErrNotSealed, "a PIN in the clear is refused, never trusted")
}

func TestPINHashing(t *testing.T) {
	hash, err := HashPIN("4321")
	require.NoError(t, err)
	assert.NotContains(t, hash, "4321")
	assert.True(t, CheckPIN(hash, "4321"))
	assert.False(t, CheckPIN(hash, "1234"))
	assert.False(t, CheckPIN("", "4321"))

	again, err := HashPIN("4321")
	require.NoError(t, err)
	assert.NotEqual(t, hash, again, "each hash is salted")

	for pin, want := range map[string]bool{"4321": true, "123456": true, "123": false, "1234567": false, "12a4": false} {
		assert.Equal(t, want, ValidPIN(pin), pin)
	}
}

// fakeEngine is the USSD management API, in memory.
type fakeEngine struct {
	mu      sync.Mutex
	menus   map[string]Menu
	config  map[string]string
	created int
	deleted int
}

func (e *fakeEngine) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	e.mu.Lock()
	defer e.mu.Unlock()
	switch {
	case r.Method == http.MethodGet && r.URL.Path == "/api/v1/menus":
		var roots []Menu
		for _, m := range e.menus {
			if m.ParentID == "" {
				roots = append(roots, m)
			}
		}
		_ = json.NewEncoder(w).Encode(roots)
	case r.Method == http.MethodPost && r.URL.Path == "/api/v1/menus":
		var m Menu
		_ = json.NewDecoder(r.Body).Decode(&m)
		e.created++
		m.ID = "m" + strings.Repeat("x", e.created)
		e.menus[m.ID] = m
		_ = json.NewEncoder(w).Encode(map[string]string{"ID": m.ID})
	case r.Method == http.MethodDelete && strings.HasPrefix(r.URL.Path, "/api/v1/menus/"):
		e.deleted++
		delete(e.menus, strings.TrimPrefix(r.URL.Path, "/api/v1/menus/"))
		w.WriteHeader(http.StatusNoContent)
	case r.Method == http.MethodPut && strings.HasSuffix(r.URL.Path, "/config"):
		var kv map[string]string
		_ = json.NewDecoder(r.Body).Decode(&kv)
		e.config[kv["name"]] = kv["value"]
		_ = json.NewEncoder(w).Encode(kv)
	default:
		http.Error(w, "unexpected", http.StatusTeapot)
	}
}

func TestInstallRegistersTheMenuOnceAndConfiguresTheGateway(t *testing.T) {
	engine := &fakeEngine{menus: map[string]Menu{}, config: map[string]string{}}
	srv := httptest.NewServer(engine)
	defer srv.Close()
	client := NewClient(srv.URL, srv.Client())
	settings := Settings{
		ServiceID: "seed",
		AuthKey:   "gw-secret",
		PublicKey: "pub",
		StateURL:  "https://api.stawi.org/seed/state",
	}

	require.NoError(t, Install(context.Background(), client, settings))
	created := engine.created
	require.Positive(t, created)
	assert.Equal(t, "gw-secret", engine.config[configAuthKey])
	assert.Equal(t, "pub", engine.config[configSecretBoxKey])
	assert.Equal(t, "*", engine.config[configInputSeparator])
	assert.Equal(t, "END %s", engine.config[configEndTemplate])
	assert.Equal(t, settings.StateURL, engine.config[configSessionStartURL])
	root := engine.config[configInitialMenu]
	require.NotEmpty(t, root)

	// Every PIN or code prompt is sealed by the engine.
	secrets := 0
	for _, m := range engine.menus {
		switch m.CollectionKey {
		case KeyPIN, KeyOTP, KeyCurrentPIN, KeyNewPIN, KeyConfirmPIN:
			assert.True(t, m.IsSecret, m.CollectionKey)
			secrets++
		}
	}
	// Borrow PIN; set, change and reset each take a code and the new PIN
	// twice; change also takes the current PIN.
	assert.Equal(t, 11, secrets)

	// An unchanged menu is left alone, so its ids stay stable.
	require.NoError(t, Install(context.Background(), client, settings))
	assert.Equal(t, created, engine.created)
	assert.Zero(t, engine.deleted)
	assert.Equal(t, root, engine.config[configInitialMenu])

	// A stale tree (another version) is replaced.
	engine.menus["old"] = Menu{ID: "old", Name: "Seed", Extra: "v0-stale"}
	require.NoError(t, Install(context.Background(), client, settings))
	assert.Equal(t, 1, engine.deleted)
	_, stale := engine.menus["old"]
	assert.False(t, stale)
}

func TestInstallRefusesAnIncompleteConfiguration(t *testing.T) {
	engine := &fakeEngine{menus: map[string]Menu{}, config: map[string]string{}}
	srv := httptest.NewServer(engine)
	defer srv.Close()
	err := Install(context.Background(), NewClient(srv.URL, srv.Client()),
		Settings{ServiceID: "seed", PublicKey: "pub", StateURL: "https://x"})
	require.Error(t, err, "no gateway auth key")
	assert.Zero(t, engine.created)
}
