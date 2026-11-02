import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Broadcasts "something was written to the database".
///
/// Tables reference each other (articles → categories, lists → cards,
/// prices → articles), so a write in one feature can change what another
/// one displays. Every [RepositoryCubit] reloads on each notification, which
/// is cheap for a local database and keeps the cubits independent.
class DataChanges {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}

/// A cubit whose state is a snapshot of the database.
abstract class RepositoryCubit<T> extends Cubit<T> {
  final DataChanges _changes;
  late final StreamSubscription<void> _subscription;

  RepositoryCubit(super.initialState, this._changes) {
    _subscription = _changes.stream.listen((_) => refresh());
  }

  /// Reads the state from the database.
  Future<T> load();

  Future<void> refresh() async {
    final value = await load();
    if (!isClosed) emit(value);
  }

  /// Runs a write and tells every cubit to reload.
  Future<void> mutate(Future<void> Function() write) async {
    await write();
    _changes.notify();
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
