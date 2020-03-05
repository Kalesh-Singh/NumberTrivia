import 'package:equatable/equatable.dart';

abstract class NumberTriviaEvent extends Equatable {
  const NumberTriviaEvent();

  @override
  List<Object> get props => [];
}

class ConcreteNumberTriviaRequested extends NumberTriviaEvent {
  final String numberString;

  ConcreteNumberTriviaRequested(this.numberString);

  @override
  List<Object> get props => [numberString];
}

class RandomNumberTriviaRequested extends NumberTriviaEvent {}
