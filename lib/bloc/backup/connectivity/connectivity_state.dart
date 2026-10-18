import 'package:equatable/equatable.dart';

final class ConnectivityState extends Equatable {
  const ConnectivityState({this.isOnline = true});

  final bool isOnline;

  @override
  List<Object?> get props => [isOnline];
}
