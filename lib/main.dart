import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:music_app_v3/screens/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:path_provider/path_provider.dart';
import './services/music_service.dart';


Future<void> initHive() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.initFlutter();
  // await Hive.openBox('shuffle');
  // await Hive.openBox('playingAlbum');
  // await Hive.openBox('loop');
  // await Hive.openBox('currentIndex');
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initHive();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MusicService(),
          ),
        ],
        child: MyApp(),
      ),
    );
  } catch (e) {
    print("error occurd in main: $e");
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        accentColor: Colors.orange,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.orange,
        ),
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          textStyle: TextStyle(
              color: Colors.black,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 14.5),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.orange,
          labelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelColor: Colors.black,
          indicator: BoxDecoration(color: Colors.transparent),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: Colors.black,
            fontFamily: 'Montserrat',
          ),
          bodyText2: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.normal,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
          subtitle2: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.normal,
            letterSpacing: 0.3,
          ),
          headline5: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            fontSize: 22,
          ),
          headline6: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
            fontSize: 16,
          ),
          button: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Montserrat',
          ),
        ),
        sliderTheme: SliderThemeData(
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 25),
          // trackShape: RectangularSliderTrackShape(),
          trackHeight: 1.5,

          activeTrackColor: Colors.orange,
          thumbColor: Colors.orange,
          overlayColor: Color.fromRGBO(255, 165, 0, 0.16),
          inactiveTrackColor: Color.fromRGBO(255, 165, 0, 0.46),
        ),
        primarySwatch: Colors.orange,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AudioServiceWidget(
        child: MyHomePage(),
      ),
    );
  }
}
