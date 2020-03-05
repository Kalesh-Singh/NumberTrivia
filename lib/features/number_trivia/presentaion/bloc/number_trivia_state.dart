import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/entities/number_trivia.dart';

abstract class NumberTriviaState extends Equatable {
  const NumberTriviaState();

  @override
  List<Object> get props => [];
}

class TriviaEmpty extends NumberTriviaState {}

class TriviaLoadInProgress extends NumberTriviaState {}

class TriviaLoadSuccess extends NumberTriviaState {
  final NumberTrivia trivia;

  TriviaLoadSuccess({@required this.trivia});

  @override
  List<Object> get props => [trivia];
}

class TriviaLoadFailure extends NumberTriviaState {
  final String message;

  TriviaLoadFailure({@required this.message});

  @override
  List<Object> get props => [message];
}
