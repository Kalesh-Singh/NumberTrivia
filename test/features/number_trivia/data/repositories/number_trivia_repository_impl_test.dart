import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numbertriviaapp/core/error/exceptions.dart';
import 'package:numbertriviaapp/core/error/failures.dart';
import 'package:numbertriviaapp/core/network/network_info.dart';
import 'package:numbertriviaapp/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:numbertriviaapp/features/number_trivia/data/data_sources/number_trivia_remote_data_source.dart';
import 'package:numbertriviaapp/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:numbertriviaapp/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runOnlineTests(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runOfflineTests(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final int tNumber = 1;
    final String tText = 'Test Text';
    final NumberTriviaModel tNumberTriviaModel =
    NumberTriviaModel(number: tNumber, text: tText);
    // Cast the Model to the Entity
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // act
      repository.getConcreteNumberTrivia(tNumber);

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runOnlineTests(() {
      test(
          'should return remote data when the call to remote data source is successful',
              () async {
            // arrange
            when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                .thenAnswer((_) async => tNumberTriviaModel);

            // act
            final result = await repository.getConcreteNumberTrivia(tNumber);

            // assert
            verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            expect(result, equals(Right(tNumberTrivia)));
          });

      test(
          'should cache the data locally when the call to remote data source is successful',
              () async {
            // arrange
            when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                .thenAnswer((_) async => tNumberTriviaModel);

            // act
            await repository.getConcreteNumberTrivia(tNumber);

            // assert
            verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
          });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
              () async {
            // arrange
            when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                .thenThrow(ServerException());

            // act
            final result = await repository.getConcreteNumberTrivia(tNumber);

            // assert
            verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            verifyZeroInteractions(mockLocalDataSource);
            expect(result, equals(Left(ServerFailure())));
          });
    });

    runOfflineTests(() {
      test(
          'should return last locally cached data when there is cached data present',
              () async {
            // arrange
            when(mockLocalDataSource.getLastNumberTrivia())
                .thenAnswer((_) async => tNumberTriviaModel);

            // act
            final result = await repository.getConcreteNumberTrivia(tNumber);

            // assert
            verifyZeroInteractions(mockRemoteDataSource);
            verify(mockLocalDataSource.getLastNumberTrivia());
            expect(result, equals(Right(tNumberTrivia)));
          });

      test('should return CacheFailure when there is no cached data present',
              () async {
            // arrange
            when(mockLocalDataSource.getLastNumberTrivia())
                .thenThrow(CacheException());

            // act
            final result = await repository.getConcreteNumberTrivia(tNumber);

            // assert
            verifyZeroInteractions(mockRemoteDataSource);
            verify(mockLocalDataSource.getLastNumberTrivia());
            expect(result, equals(Left(CacheFailure())));
          });
    });
  });

  group('getRandomNumberTrivia', () {
    final int tRandomNumber = 1;
    final String tText = 'Test Text';
    final NumberTriviaModel tNumberTriviaModel =
        NumberTriviaModel(number: tRandomNumber, text: tText);
    // Cast the Model to the Entity
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // act
      repository.getRandomNumberTrivia();

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runOnlineTests(() {
      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        // arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        final result = await repository.getRandomNumberTrivia();

        // assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test(
          'should cache the data locally when the call to remote data source is successful',
          () async {
        // arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        await repository.getRandomNumberTrivia();

        // assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());

        // act
        final result = await repository.getRandomNumberTrivia();

        // assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runOfflineTests(() {
      test(
          'should return last locally cached data when there is cached data present',
          () async {
        // arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        final result = await repository.getRandomNumberTrivia();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return CacheFailure when there is no cached data present',
          () async {
        // arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        // act
        final result = await repository.getRandomNumberTrivia();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
