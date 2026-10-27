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

package business

import (
	"context"
	"sort"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	identityv1 "buf.build/gen/go/antinvestor/identity/protocolbuffers/go/identity/v1"
	"github.com/pitabwire/frame/v3/data"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

func (e *authorizationEnv) createGroup(name string, groupType int32, state commonv1.STATE) *models.ClientGroup {
	e.t.Helper()
	group := &models.ClientGroup{
		Name:       name,
		GroupType:  groupType,
		State:      int32(state),
		Properties: data.JSONMap{},
	}
	group.GenID(e.ctx)
	if err := e.groupRepo.Create(e.ctx, group); err != nil {
		e.t.Fatalf("create group: %v", err)
	}
	return group
}

func (e *authorizationEnv) searchGroupNames(req *identityv1.ClientGroupSearchRequest) ([]string, error) {
	var names []string
	err := e.groupBusiness.Search(e.ctx, ClientGroupFilterFromAPI(req), req.GetCursor(),
		func(_ context.Context, batch []*models.ClientGroup) error {
			for _, g := range batch {
				names = append(names, g.Name)
			}
			return nil
		})
	sort.Strings(names)
	return names, err
}

// A search returns only the groups in the states and of the types asked for,
// so a caller after its running groups does not page the whole tenant.
func (s *authorizationSuite) TestClientGroupSearchHonoursStateAndTypeFilters() {
	env := s.newEnv()
	env.createGroup("active-grameen", 2, commonv1.STATE_ACTIVE)
	env.createGroup("active-chama", 5, commonv1.STATE_ACTIVE)
	env.createGroup("active-other", 9, commonv1.STATE_ACTIVE)
	env.createGroup("inactive-grameen", 2, commonv1.STATE_INACTIVE)
	env.createGroup("deleted-chama", 5, commonv1.STATE_DELETED)
	env.createGroup("created-grameen", 2, commonv1.STATE_CREATED)

	names, err := env.searchGroupNames(&identityv1.ClientGroupSearchRequest{State: commonv1.STATE_ACTIVE})
	s.Require().NoError(err)
	s.Equal([]string{"active-chama", "active-grameen", "active-other"}, names)

	names, err = env.searchGroupNames(&identityv1.ClientGroupSearchRequest{
		States:     []commonv1.STATE{commonv1.STATE_ACTIVE},
		GroupTypes: []int32{2, 5, 6},
	})
	s.Require().NoError(err)
	s.Equal([]string{"active-chama", "active-grameen"}, names)

	names, err = env.searchGroupNames(&identityv1.ClientGroupSearchRequest{
		States: []commonv1.STATE{commonv1.STATE_INACTIVE, commonv1.STATE_DELETED},
	})
	s.Require().NoError(err)
	s.Equal([]string{"deleted-chama", "inactive-grameen"}, names)

	// CREATED is the zero state, reachable only through the list.
	names, err = env.searchGroupNames(&identityv1.ClientGroupSearchRequest{
		States: []commonv1.STATE{commonv1.STATE_CREATED},
	})
	s.Require().NoError(err)
	s.Equal([]string{"created-grameen"}, names)

	names, err = env.searchGroupNames(&identityv1.ClientGroupSearchRequest{GroupType: 5})
	s.Require().NoError(err)
	s.Equal([]string{"active-chama", "deleted-chama"}, names)

	names, err = env.searchGroupNames(&identityv1.ClientGroupSearchRequest{})
	s.Require().NoError(err)
	s.Len(names, 6, "no filter matches every group")
}
