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
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
)

// Rows Seed returns for the borrower when they open the menu; a menu item
// backed by one is shown only while the row exists.
const (
	RowClient = "seed:client" // a registered client: may set a PIN
	RowLoan   = "seed:loan"   // an active loan: balance and next instalment
	RowBorrow = "seed:borrow" // may borrow now: the amount available
)

// Collection keys of the menu, read back from a completed session.
const (
	KeyPayOption  = "pay_option"  // 1 next instalment, 2 full balance, 3 other
	KeyPayAmount  = "pay_amount"  // the "other" amount, whole currency units
	KeyAmount     = "amount"      // amount to borrow, whole currency units
	KeyPIN        = "pin"         // sealed
	KeyPinStep    = "pin_step"    // 1 send me a code, 2 I have a code
	KeyOTP        = "otp"         // sealed
	KeyNewPIN     = "new_pin"     // sealed
	KeyConfirmPIN = "confirm_pin" // sealed
)

// Pay options, by their position on the Repay screen.
const (
	PayNextInstalment = "1"
	PayFullBalance    = "2"
	PayOther          = "3"
	PinSendCode       = "1"
	PinHaveCode       = "2"
)

// Engine settings and actions used here.
const (
	actionChoices          = "CHOICES"
	actionChoicesValue     = "CHOICES_VALUE"
	actionInput            = "INPUT"
	actionInformation      = "INFORMATION"
	actionInputFromQuery   = "INPUT_FROM_QUERY"
	actionChoiceFromQuery  = "CHOICE_FROM_QUERY"
	validatorChoice        = "CHOICE"
	validatorNumber        = "NUMBER"
	configInitialMenu      = "initial_menu"
	configAuthKey          = "auth_key"
	configSecretBoxKey     = "secret_box_public_key"
	configInputSeparator   = "input_separator"
	configBeginTemplate    = "data_begin_template"
	configContinueTemplate = "data_continue_template"
	configEndTemplate      = "data_end_template"
	configSessionExpiry    = "session_expiry_minutes"
	configMenuVersion      = "seed_menu_version"
	configSessionStartURL  = "session_start_url"
	sessionExpiryMinutes   = "3"
)

// nameDone names the closing screen of a flow.
const nameDone = "Done"

const payRequested = "A payment request is on its way to this phone. " +
	"Approve it with your mobile money PIN."

// Positions on a screen: the engine lists the highest Order first.
const (
	orderMyLoan = 50
	orderRepay  = 40
	orderBorrow = 30
	orderPIN    = 20
	orderHelp   = 10
	orderFirst  = 3
	orderSecond = 2
	orderThird  = 1
)

// node is a menu node and its children.
type node struct {
	Menu     `json:"menu"`
	Children []node `json:"children,omitempty"`
}

// tree is the borrower menu.
func tree() node {
	return node{Menu: Menu{Action: actionChoices, Validator: validatorChoice, Name: "Seed",
		Message: "Seed loans"}, Children: []node{
		{Menu: Menu{Order: orderMyLoan, Action: actionChoiceFromQuery, Extra: RowLoan, Name: "My loan",
			Message: "Loan {loan_ref}\nBalance {balance}\nNext {next_due} due {next_date}"}},
		{Menu: Menu{Order: orderRepay, Action: actionChoiceFromQuery, Validator: validatorChoice, Extra: RowLoan,
			Name: "Repay", Message: "Balance {balance}. Pay:", CollectionKey: KeyPayOption}, Children: []node{
			{Menu: Menu{Order: orderFirst, Action: actionChoicesValue, Name: "Next instalment", Message: payRequested}},
			{Menu: Menu{Order: orderSecond, Action: actionChoicesValue, Name: "Full balance", Message: payRequested}},
			{Menu: Menu{Order: orderThird, Action: actionInput, Validator: validatorNumber, Name: "Other amount",
				Message: "Enter the amount to pay:", CollectionKey: KeyPayAmount}, Children: []node{
				{Menu: Menu{Action: actionChoicesValue, Name: nameDone, Message: payRequested}},
			}},
		}},
		{Menu: Menu{Order: orderBorrow, Action: actionInputFromQuery, Validator: validatorNumber, Extra: RowBorrow,
			Name: "Borrow (up to {limit})", Message: "Enter amount (up to {limit}):", CollectionKey: KeyAmount},
			Children: []node{
				{Menu: Menu{Action: actionInput, Validator: validatorNumber, Name: "PIN",
					Message: "Enter your Seed PIN:", CollectionKey: KeyPIN, IsSecret: true}, Children: []node{
					{Menu: Menu{Action: actionChoicesValue, Name: nameDone,
						Message: "Thank you. We are processing your request and will send you an SMS."}},
				}},
			}},
		{Menu: Menu{Order: orderPIN, Action: actionChoiceFromQuery, Validator: validatorChoice, Extra: RowClient,
			Name: "Set or change PIN", Message: "Seed PIN", CollectionKey: KeyPinStep}, Children: []node{
			{Menu: Menu{Order: orderSecond, Action: actionChoicesValue, Name: "Send me a code",
				Message: "We are sending a code by SMS. Dial again and choose Set or change PIN, then I have a code."}},
			{Menu: Menu{Order: orderThird, Action: actionInput, Validator: validatorNumber, Name: "I have a code",
				Message: "Enter the code we sent you:", CollectionKey: KeyOTP, IsSecret: true}, Children: []node{
				{Menu: Menu{Action: actionInput, Validator: validatorNumber, Name: "New PIN",
					Message: "Choose a 4 to 6 digit PIN:", CollectionKey: KeyNewPIN, IsSecret: true}, Children: []node{
					{Menu: Menu{
						Action:        actionInput,
						Validator:     validatorNumber,
						Name:          "Confirm PIN",
						Message:       "Enter the PIN again:",
						CollectionKey: KeyConfirmPIN,
						IsSecret:      true,
					}, Children: []node{
						{Menu: Menu{Action: actionChoicesValue, Name: nameDone,
							Message: "Thank you. We will send you an SMS once your PIN is set."}},
					}},
				}},
			}},
		}},
		{Menu: Menu{Order: orderHelp, Action: actionInformation, Name: "Help",
			Message: "Seed loans: check your loan, repay from this phone and borrow again. Your agent can help."}},
	}}
}

// Settings configures the gateway service.
type Settings struct {
	ServiceID string
	AuthKey   string
	PublicKey string
	// StateURL is Seed's session-start endpoint, called by the engine.
	StateURL string
}

// Install registers the borrower menu and the gateway settings. It is run
// by the setup Job and is a no-op when the menu has not changed, so menu ids
// stay stable across deploys; a changed menu replaces the old tree.
func Install(ctx context.Context, c *Client, s Settings) error {
	if c == nil {
		return nil
	}
	if s.ServiceID == "" || s.AuthKey == "" || s.PublicKey == "" || s.StateURL == "" {
		return errors.New("ussd: service id, gateway auth key, secret key and state url are required")
	}

	spec := tree()
	version, err := specVersion(spec)
	if err != nil {
		return err
	}
	roots, err := c.RootMenus(ctx)
	if err != nil {
		return err
	}
	rootID := ""
	for _, r := range roots {
		if r.Name == spec.Name && r.Extra == version {
			rootID = r.ID
			continue
		}
		if err = c.DeleteMenu(ctx, r.ID); err != nil {
			return err
		}
	}
	if rootID == "" {
		spec.Extra = version
		if rootID, err = create(ctx, c, "", spec); err != nil {
			return err
		}
	}

	for name, value := range map[string]string{
		configInitialMenu:      rootID,
		configAuthKey:          s.AuthKey,
		configSecretBoxKey:     s.PublicKey,
		configInputSeparator:   "*",
		configBeginTemplate:    "CON %s",
		configContinueTemplate: "CON %s",
		configEndTemplate:      "END %s",
		configSessionExpiry:    sessionExpiryMinutes,
		configMenuVersion:      version,
		configSessionStartURL:  s.StateURL,
	} {
		if err = c.SetConfig(ctx, s.ServiceID, name, value); err != nil {
			return err
		}
	}
	return nil
}

func create(ctx context.Context, c *Client, parentID string, n node) (string, error) {
	m := n.Menu
	m.ParentID = parentID
	id, err := c.CreateMenu(ctx, m)
	if err != nil {
		return "", err
	}
	for _, child := range n.Children {
		if _, err = create(ctx, c, id, child); err != nil {
			return "", err
		}
	}
	return id, nil
}

// specVersion fingerprints the menu, kept on the root's Extra (a choices
// root does not use it), so an unchanged menu is left alone.
func specVersion(n node) (string, error) {
	raw, err := json.Marshal(n)
	if err != nil {
		return "", fmt.Errorf("ussd: fingerprint menu: %w", err)
	}
	sum := sha256.Sum256(raw)
	return "v" + strconv.Itoa(len(raw)) + "-" + hex.EncodeToString(sum[:8]), nil
}
