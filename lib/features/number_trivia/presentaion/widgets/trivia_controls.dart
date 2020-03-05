import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numbertriviaapp/features/number_trivia/presentaion/bloc/number_trivia_bloc.dart';
import 'package:numbertriviaapp/features/number_trivia/presentaion/bloc/number_trivia_event.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key key,
  }) : super(key: key);

  @override
  _TriviaControlsState createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputStr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            inputStr = value;
          },
          onSubmitted: (_) {
            _requestConcreteNumberTrivia();
          },
        ),
        SizedBox(height: 10),
        // Buttons
        Row(
          children: <Widget>[
            Expanded(
                child: RaisedButton(
                  child: Text('Search'),
                  color: Theme.of(context).accentColor,
                  textTheme: ButtonTextTheme.primary,
                  onPressed: _requestConcreteNumberTrivia,
                )),
            SizedBox(width: 10),
            Expanded(
              child: RaisedButton(
                child: Text('Get Random Trivia'),
                textTheme: ButtonTextTheme.primary,
                onPressed: _requestRandomNumberTrivia,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _requestConcreteNumberTrivia() {
    // Clear Text Field
    controller.clear();
    // Hide keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(ConcreteNumberTriviaRequested(inputStr));
  }

  void _requestRandomNumberTrivia() {
    // Clear Text Field
    controller.clear();
    // Hide keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(RandomNumberTriviaRequested());
  }
}
