import 'package:antinvestor_ui_identity/antinvestor_ui_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Fetch = Future<List<int>> Function(int offset, int limit);

class _Numbers extends PagedListNotifier<int> {
  _Numbers(this.fetch);

  final _Fetch fetch;

  @override
  int get pageSize => 3;

  @override
  Future<List<int>> fetchPage(int offset, int limit) => fetch(offset, limit);
}

List<int> _range(int from, int count) => [
  for (var i = 0; i < count; i++) from + i,
];

void main() {
  late ProviderContainer container;

  tearDown(() => container.dispose());

  AsyncNotifierProvider<_Numbers, PagedList<int>> provider(_Fetch fetch) =>
      AsyncNotifierProvider<_Numbers, PagedList<int>>(() => _Numbers(fetch));

  test('a full first page leaves a cursor; a short page clears it', () async {
    container = ProviderContainer();
    final numbers = provider((offset, limit) async {
      return offset == 0 ? _range(0, limit) : _range(offset, 1);
    });

    final first = await container.read(numbers.future);
    expect(first.items, [0, 1, 2]);
    expect(first.hasMore, isTrue);
    expect(first.nextPage, 3);

    await container.read(numbers.notifier).loadMore();
    final second = container.read(numbers).requireValue;
    expect(second.items, [0, 1, 2, 3]);
    expect(second.hasMore, isFalse);
    expect(second.isLoadingMore, isFalse);
  });

  test('loadMore is a no-op once the list is exhausted', () async {
    container = ProviderContainer();
    var calls = 0;
    final numbers = provider((offset, limit) async {
      calls++;
      return _range(0, 2);
    });

    await container.read(numbers.future);
    await container.read(numbers.notifier).loadMore();
    await container.read(numbers.notifier).loadMore();

    expect(calls, 1, reason: 'no further reads after a short page');
  });

  test('a failed append keeps the rows and records the error', () async {
    container = ProviderContainer();
    var calls = 0;
    final numbers = provider((offset, limit) async {
      calls++;
      if (offset == 0) return _range(0, limit);
      if (calls == 2) throw StateError('boom');
      return _range(offset, limit);
    });

    await container.read(numbers.future);
    await container.read(numbers.notifier).loadMore();

    final failed = container.read(numbers).requireValue;
    expect(failed.items, [0, 1, 2], reason: 'loaded rows survive the failure');
    expect(failed.loadMoreError, isA<StateError>());
    expect(failed.isLoadingMore, isFalse);
    expect(failed.hasMore, isTrue, reason: 'the cursor stays so retry works');

    await container.read(numbers.notifier).loadMore();
    final retried = container.read(numbers).requireValue;
    expect(retried.items, [0, 1, 2, 3, 4, 5]);
    expect(retried.loadMoreError, isNull);
  });
}
