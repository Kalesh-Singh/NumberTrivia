import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:numbertriviaapp/core/error/failures.dart';
import 'package:numbertriviaapp/core/use_cases/use_case.dart';
import 'package:numbertriviaapp/core/util/input_converter.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:numbertriviaapp/features/number_trivia/presentaion/bloc/number_trivia_bloc.dart';
import 'package:numbertriviaapp/features/number_trivia/presentaion/bloc/number_trivia_event.dart';
import 'package:numbertriviaapp/features/number_trivia/presentaion/bloc/number_trivia_state.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('should have an initial state of TriviaEmpty', () {
    // assert
    expect(bloc.initialState, equals(TriviaEmpty()));
  });

 group('ConcreteNumberTriviaRequested', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tText = 'Test text';
    final tNumberTrivia = NumberTrivia(number: tNumberParsed, text: tText);

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));

    test('''should call the InputConverter to validate and convert the string 
        to an unsigned integer''', () async {
      // arrange
      setUpMockInputConverterSuccess();

      // act
      bloc.add(ConcreteNumberTriviaRequested(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));

      // assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [TriviaLoadFailure] when the input is invalid', () async {
      // arrange
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));

      // assert later
      final expectedStates = [
        TriviaEmpty(),
        TriviaLoadFailure(message: INVALID_INPUT_FAILURE_MESSAGE)
      ];
      expectLater(
        bloc.asBroadcastStream(),
        emitsInOrder(expectedStates),
      );

      // act
      bloc.add(ConcreteNumberTriviaRequested(tNumberString));
    });

    test('should get data from the getConcreteNumberTrivia usecase', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));

      // act
      bloc.add(ConcreteNumberTriviaRequested(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));

      // assert
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test('''should emit [TriviaLoadInProgress, TriviaLoadSuccess] states
    when data is gotten successfully''', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));

      // assert later
      final expectedStates = [
        TriviaEmpty(),
        TriviaLoadInProgress(),
        TriviaLoadSuccess(trivia: tNumberTrivia),
      ];

      expectLater(
        bloc.asBroadcastStream(),
        emitsInOrder(expectedStates),
      );

      // act
      bloc.add(ConcreteNumberTriviaRequested(tNumberString));
    });

    test('''should emit [TriviaLoadInProgress, TriviaLoadFailure] states
    when getting data fails''', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      // assert later
      final expectedStates = [
        TriviaEmpty(),
        TriviaLoadInProgress(),
        TriviaLoadFailure(message: SERVER_FAILURE_MESSAGE),
      ];

      expectLater(
        bloc.asBroadcastStream(),
        emitsInOrder(expectedStates),
      );

      // act
      bloc.add(ConcreteNumberTriviaRequested(tNumberString));
    });

    test('''should emit [TriviaLoadInProgress, TriviaLoadFailure] with a proper
    failure message for the error when getting data fails''', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));

      // assert later
      final expectedStates = [
        TriviaEmpty(),
        TriviaLoadInProgress(),
        TriviaLoadFailure(message: CACHE_FAILURE_MESSAGE),
      ];

      expectLater(
        bloc.asBroadcastStream(),
        emitsInOrder(expectedStates),
      );

      // act
      bloc.add(ConcreteNumberTriviaRequested(tNumberString));
    });
  });

  group('RandomNumberTriviaRequested', () {
    final tRandomNumber = 1;
    final tText = 'Test text';
    final tNumberTrivia = NumberTrivia(number: tRandomNumber, text: tText);

    test('should get data from the getRandomNumberTrivia usecase', () async {
      // arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));

      // act
      bloc.add(RandomNumberTriviaRequested());
      await untilCalled(mockGetRandomNumberTrivia(any));

      // assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test('''should emit [TriviaLoadInProgress, TriviaLoadSuccess] states
    when data is gotten successfully''', () async {
      // arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));

      // assert later
      final expectedStates = [
        TriviaEmpty(),
        TriviaLoadInProgress(),
        TriviaLoadSuccess(trivia: tNumberTrivia),
      ];

      expectLater(
        bloc.asBroadcastStream(),
        emitsInOrder(expectedStates),
      );

      // act
      bloc.add(RandomNumberTriviaRequested());
    });

    test('''should emit [TriviaLoadInProgress, TriviaLoadFailure] states
    when getting data fails''', () async {
      // arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      // assert later
      final expectedStates = [
        TriviaEmpty(),
        TriviaLoadInProgress(),
        TriviaLoadFailure(message: SERVER_FAILURE_MESSAGE),
      ];

      expectLater(
        bloc.asBroadcastStream(),
        emitsInOrder(expectedStates),
      );

      // act
      bloc.add(RandomNumberTriviaRequested());
    });

    test('''should emit [TriviaLoadInProgress, TriviaLoadFailure] with a proper
    failure message for the error when getting data fails''', () async {
      // arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));

      // assert later
      final expectedStates = [
        TriviaEmpty(),
        TriviaLoadInProgress(),
        TriviaLoadFailure(message: CACHE_FAILURE_MESSAGE),
      ];

      expectLater(
        bloc.asBroadcastStream(),
        emitsInOrder(expectedStates),
      );

      // act
      bloc.add(RandomNumberTriviaRequested());
    });
  });
}
