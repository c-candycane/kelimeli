import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: Colors.white,
            onPrimary: Color.fromRGBO(31, 44, 55, 1),
            secondary: Colors.blue,
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.red,
            background: Color.fromRGBO(31, 44, 55, 1),
            onBackground: Color.fromRGBO(31, 44, 55, 1),
            surface: Colors.white,
            onSurface: Colors.white),

          scaffoldBackgroundColor: Color.fromRGBO(31, 44, 55, 1),
          appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromRGBO(31, 44, 55, 1),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 24)),
          progressIndicatorTheme:
              const ProgressIndicatorThemeData(color: Colors.blue),
          buttonTheme: const ButtonThemeData(buttonColor: Colors.blue),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),

            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          )),
          switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.all<Color>(Colors.blue),
            trackColor: MaterialStateProperty.all<Color>(Colors.white),
            trackOutlineColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.all<Color>(Colors.white),
            checkColor: MaterialStateProperty.all<Color>(Colors.blue),
            overlayColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          dropdownMenuTheme: const DropdownMenuThemeData(
            textStyle: TextStyle(color: Colors.white),
          ),
          primaryColor: Colors.blue,
          primarySwatch: Colors.blue,
          indicatorColor: Colors.blue,
          primaryTextTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
            displayMedium: TextStyle(color: Colors.white),
            labelMedium: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white),
            displaySmall: TextStyle(color: Colors.white),
            labelSmall: TextStyle(color: Colors.white),
            titleSmall: TextStyle(color: Colors.white),
          ),
          listTileTheme: const ListTileThemeData(
            textColor: Colors.white,
          ),
          iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
            iconColor: MaterialStateProperty.all<Color>(Colors.blue),
          )),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,
          )),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
