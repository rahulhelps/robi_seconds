import 'package:equatable/equatable.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class ConnectivityStatusChanged extends ConnectivityEvent {
  final bool isConnected;

  const ConnectivityStatusChanged({required this.isConnected});

  @override
  List<Object> get props => [isConnected];
}
