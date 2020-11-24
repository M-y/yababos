import 'package:equatable/equatable.dart';
import 'package:yababos/models/setting.dart';

abstract class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object> get props => [];
}

class SettingsLoading extends SettingState {}

class SettingChanged extends SettingState {
  final Setting setting;

  const SettingChanged(this.setting);

  @override
  List<Object> get props => [setting];
}

class SettingLoaded extends SettingState {
  final Setting setting;

  const SettingLoaded(this.setting);

  @override
  List<Object> get props => [setting];
}
