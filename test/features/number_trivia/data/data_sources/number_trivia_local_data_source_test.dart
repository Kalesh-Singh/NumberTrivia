import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';
import 'package:numbertriviaapp/core/error/exceptions.dart';
import 'package:numbertriviaapp/features/number_trivia/data/data_sources/number_trivia_local_data_source.dart';
import 'package:numbertriviaapp/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test(
        'should return NumberTriviaModel from SharedPreferences when there is one in the cache',
        () async {
      // arrange
      when(mockSharedPreferences.getString(any))
          .thenReturn(fixture('trivia_cached.json'));

      // act
      final result = await dataSource.getLastNumberTrivia();

      // assert
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a CacheException when there is not a cached value',
        () async {
      // arrange
      when(mockSharedPreferences.getString(any)).thenReturn(null);

      // act
      final call = dataSource.getLastNumberTrivia;

      // assert
      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumber = 1;
    final tText = 'Test Text';
    final tNumberTriviaModel = NumberTriviaModel(number: tNumber, text: tText);

    test('should call SharedPreferences to cache the data', () async {
      // act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);

      // assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}

//test('', () async {
//// arrange
//
//
//// act
//
//
//// assert
//
//});
