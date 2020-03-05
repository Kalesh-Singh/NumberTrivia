import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:numbertriviaapp/core/use_cases/use_case.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  GetRandomNumberTrivia usecase;
  MockNumberTriviaRepository mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepository);
  });

  final tRandomNumber = 1;
  final tRandomNumberTrivia = NumberTrivia(number: tRandomNumber, text: 'Test text');

  test('should get trivia from the repository', () async {
    // arrange
    when(mockNumberTriviaRepository.getRandomNumberTrivia())
        .thenAnswer((_) async => Right(tRandomNumberTrivia));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Right(tRandomNumberTrivia));
    verify(mockNumberTriviaRepository.getRandomNumberTrivia());
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
