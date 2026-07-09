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

package repository

import (
	"context"

	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/datastore/pool"
	"github.com/pitabwire/frame/v2/workerpool"

	"github.com/antinvestor/service-fintech/apps/identity/service/models"
)

// ClientDataEntryRepository manages persistence for client KYC data entries.
type ClientDataEntryRepository interface {
	datastore.BaseRepository[*models.ClientDataEntry]
	GetByClientAndKey(ctx context.Context, clientID, fieldKey string) (*models.ClientDataEntry, error)
	GetByClientID(
		ctx context.Context,
		clientID string,
		verificationStatus int32,
		offset, limit int,
	) ([]*models.ClientDataEntry, error)
}

type clientDataEntryRepository struct {
	datastore.BaseRepository[*models.ClientDataEntry]
}

func NewClientDataEntryRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) ClientDataEntryRepository {
	return &clientDataEntryRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ClientDataEntry](
			ctx, dbPool, workMan, func() *models.ClientDataEntry { return &models.ClientDataEntry{} },
		),
	}
}

func (repo *clientDataEntryRepository) GetByClientAndKey(
	ctx context.Context,
	clientID, fieldKey string,
) (*models.ClientDataEntry, error) {
	entry := models.ClientDataEntry{}
	err := repo.Pool().DB(ctx, true).
		First(&entry, "client_id = ? AND field_key = ?", clientID, fieldKey).Error
	if err != nil {
		return nil, err
	}
	return &entry, nil
}

func (repo *clientDataEntryRepository) GetByClientID(
	ctx context.Context,
	clientID string,
	verificationStatus int32,
	offset, limit int,
) ([]*models.ClientDataEntry, error) {
	var entries []*models.ClientDataEntry
	q := repo.Pool().DB(ctx, true).Where("client_id = ?", clientID)
	if verificationStatus > 0 {
		q = q.Where("verification_status = ?", verificationStatus)
	}
	err := q.Offset(offset).Limit(limit).Find(&entries).Error
	if err != nil {
		return nil, err
	}
	return entries, nil
}

// ClientDataEntryHistoryRepository manages persistence for data entry revision history.
type ClientDataEntryHistoryRepository interface {
	datastore.BaseRepository[*models.ClientDataEntryHistory]
	GetByEntryID(ctx context.Context, entryID string) ([]*models.ClientDataEntryHistory, error)
}

type clientDataEntryHistoryRepository struct {
	datastore.BaseRepository[*models.ClientDataEntryHistory]
}

func NewClientDataEntryHistoryRepository(
	ctx context.Context,
	dbPool pool.Pool,
	workMan workerpool.Manager,
) ClientDataEntryHistoryRepository {
	return &clientDataEntryHistoryRepository{
		BaseRepository: datastore.NewBaseRepository[*models.ClientDataEntryHistory](
			ctx, dbPool, workMan, func() *models.ClientDataEntryHistory { return &models.ClientDataEntryHistory{} },
		),
	}
}

func (repo *clientDataEntryHistoryRepository) GetByEntryID(
	ctx context.Context,
	entryID string,
) ([]*models.ClientDataEntryHistory, error) {
	var history []*models.ClientDataEntryHistory
	err := repo.Pool().DB(ctx, true).
		Where("entry_id = ?", entryID).
		Order("revision ASC").
		Find(&history).Error
	if err != nil {
		return nil, err
	}
	return history, nil
}
