import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SettingRouterCubit extends HydratedCubit<AvailableRoute> {
  SettingRouterCubit() : super(AvailableRoute.root);

  Brightness get systemBrightness =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  void toggleRoute() {
    switch (state) {
      case AvailableRoute.root:
        emit(AvailableRoute.article);
      case AvailableRoute.article:
        emit(AvailableRoute.card);
      case AvailableRoute.card:
        emit(AvailableRoute.root);
    }
  }

  String getRoute() {
    switch (state) {
      case AvailableRoute.root:
        return "/";
      case AvailableRoute.article:
        return "/articles";
      case AvailableRoute.card:
        return "/cards";
    }
  }

  void selectRoute(AvailableRoute route) {
    emit(route);
  }

  @override
  AvailableRoute? fromJson(Map<String, dynamic> json) {
    return AvailableRoute.values[json['setting_router'] as int];
  }

  @override
  Map<String, dynamic>? toJson(AvailableRoute state) {
    return {'setting_router': state.index};
  }
}

enum AvailableRoute {
  root,
  article,
  card
}
