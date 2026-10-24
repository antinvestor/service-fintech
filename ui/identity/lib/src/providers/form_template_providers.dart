import 'package:antinvestor_api_identity/antinvestor_api_identity.dart';
import 'package:antinvestor_ui_core/api/stream_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'identity_transport_provider.dart';

/// Search form templates.
typedef FormTemplateListParams = ({String query, String organizationId});

final formTemplateListProvider =
    FutureProvider.family<List<FormTemplateObject>, FormTemplateListParams>((
      ref,
      params,
    ) async {
      final client = ref.watch(identityServiceClientProvider);
      final request = FormTemplateSearchRequest(
        query: params.query,
        cursor: PageCursor(limit: 50),
      );

      if (params.organizationId.isNotEmpty) {
        request.organizationId = params.organizationId;
      }

      return collectStream(
        client.formTemplateSearch(request),
        extract: (response) => response.data,
      );
    });

/// Get a single form template by ID.
final formTemplateDetailProvider =
    FutureProvider.family<FormTemplateObject, String>((ref, id) async {
      final client = ref.watch(identityServiceClientProvider);
      final response = await client.formTemplateGet(
        FormTemplateGetRequest(id: id),
      );
      return response.data;
    });

/// Notifier for form template mutations.
class FormTemplateNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  IdentityServiceClient get _client => ref.read(identityServiceClientProvider);

  Future<FormTemplateObject> save(FormTemplateObject template) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.formTemplateSave(
        FormTemplateSaveRequest(data: template),
      );
      ref.invalidate(formTemplateListProvider);
      ref.invalidate(formTemplateDetailProvider(response.data.id));
      state = const AsyncValue.data(null);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<FormTemplateObject> publish(String id) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.formTemplatePublish(
        FormTemplatePublishRequest(id: id),
      );
      ref.invalidate(formTemplateListProvider);
      ref.invalidate(formTemplateDetailProvider(id));
      state = const AsyncValue.data(null);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final formTemplateNotifierProvider =
    NotifierProvider<FormTemplateNotifier, AsyncValue<void>>(
      FormTemplateNotifier.new,
    );

/// Entity types that can have form requirements.
enum FormEntityType { client, agent, investor, group, application }

/// Loads published form templates for a given entity type.
typedef EntityFormTemplateParams = ({
  FormEntityType entityType,
  String organizationId,
});

final entityFormTemplatesProvider =
    FutureProvider.family<List<FormTemplateObject>, EntityFormTemplateParams>((
      ref,
      params,
    ) async {
      final client = ref.watch(identityServiceClientProvider);
      final request = FormTemplateSearchRequest(
        entityType: params.entityType.name,
        status: FormTemplateStatus.FORM_TEMPLATE_STATUS_PUBLISHED,
        cursor: PageCursor(limit: 20),
      );
      if (params.organizationId.isNotEmpty) {
        request.organizationId = params.organizationId;
      }
      return collectStream(
        client.formTemplateSearch(request),
        extract: (response) => response.data,
      );
    });

/// Search form submissions for a given entity.
final formSubmissionListProvider =
    FutureProvider.family<List<FormSubmissionObject>, String>((
      ref,
      entityId,
    ) async {
      final client = ref.watch(identityServiceClientProvider);
      final request = FormSubmissionSearchRequest(
        entityId: entityId,
        cursor: PageCursor(limit: 50),
      );

      return collectStream(
        client.formSubmissionSearch(request),
        extract: (response) => response.data,
      );
    });

/// Notifier for form submission mutations.
class FormSubmissionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  IdentityServiceClient get _client => ref.read(identityServiceClientProvider);

  Future<FormSubmissionObject> save(FormSubmissionObject submission) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.formSubmissionSave(
        FormSubmissionSaveRequest(data: submission),
      );
      final entityId = response.data.entityId;
      if (entityId.isNotEmpty) {
        ref.invalidate(formSubmissionListProvider(entityId));
      }
      state = const AsyncValue.data(null);
      return response.data;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final formSubmissionNotifierProvider =
    NotifierProvider<FormSubmissionNotifier, AsyncValue<void>>(
      FormSubmissionNotifier.new,
    );
