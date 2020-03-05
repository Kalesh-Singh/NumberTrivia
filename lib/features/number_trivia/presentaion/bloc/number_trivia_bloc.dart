import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:numbertriviaapp/core/error/failures.dart';
import 'package:numbertriviaapp/core/use_cases/use_case.dart';
import 'package:numbertriviaapp/core/util/input_converter.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:numbertriviaapp/features/number_trivia/presentaion/bloc/number_trivia_event.dart';
import 'package:numbertriviaapp/features/number_trivia/presentaion/bloc/number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    @required this.inputConverter,
    @required this.getConcreteNumberTrivia,
    @required this.getRandomNumberTrivia,
  })  : assert(getConcreteNumberTrivia != null),
        assert(getRandomNumberTrivia != null),
        assert(inputConverter != null);

  @override
  NumberTriviaState get initialState => TriviaEmpty();

  @override
  Stream<NumberTriviaState> mapEventToState(
    NumberTriviaEvent event,
  ) async* {
    if (event is ConcreteNumberTriviaRequested) {
      final inputEither =
          inputConverter.stringToUnsignedInteger(event.numberString);

      yield* inputEither.fold(
        (failure) async* {
          yield TriviaLoadFailure(message: INVALID_INPUT_FAILURE_MESSAGE);
        },
        (integer) async* {
          yield TriviaLoadInProgress();
          final failureOrTrivia =
              await getConcreteNumberTrivia(Params(number: integer));
          yield* _eitherLoadedOrFailureState(failureOrTrivia);
        },
      );
    } else if (event is RandomNumberTriviaRequested) {
      yield TriviaLoadInProgress();
      final failureOrTrivia = await getRandomNumberTrivia(NoParams());
      yield* _eitherLoadedOrFailureState(failureOrTrivia);
    }
  }

  Stream<NumberTriviaState> _eitherLoadedOrFailureState(
    Either<Failure, NumberTrivia> failureOrTrivia,
  ) async* {
    yield failureOrTrivia.fold(
      (failure) => TriviaLoadFailure(message: _mapFailureToMessage(failure)),
      (trivia) => TriviaLoadSuccess(trivia: trivia),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
