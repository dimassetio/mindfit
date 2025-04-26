import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:health_tracker/shared/services/user_provider.dart';
import 'package:health_tracker/ui/screens/auth/welcome_screen.dart';
import 'package:health_tracker/ui/widgets/indicator_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/shared/styles/themes.dart';
import 'package:health_tracker/ui/widgets/navigation_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('splash');
  var initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
    debugPrint('notification payload: $payload');
  });

  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light));
  // await UserPreferences.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Mindfit';

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (BuildContext context, Orientation orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: ((context) => ThemeNotifier())),
            ChangeNotifierProvider(create: ((_) => UserProvider()))
          ],
          child: Consumer<ThemeNotifier>(
            builder: (context, value, child) {
              return MaterialApp(
                title: title,
                debugShowCheckedModeBanner: false,
                theme:
                    value.darkTheme ? MyThemes.darkTheme : MyThemes.lightTheme,
                home: FirebaseAuth.instance.currentUser != null
                    ? FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .get(),
                        builder: (context, firestoreSnapshot) {
                          if (firestoreSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const MyCircularIndicator();
                          }

                          if (firestoreSnapshot.hasData &&
                              firestoreSnapshot.data!.exists) {
                            // If the document exists, navigate to the Navigation screen
                            return const Navigation();
                          } else {
                            // If the document does not exist (new user), navigate to WelcomeScreen
                            return const WelcomeScreen();
                          }
                        },
                      )
                    : const WelcomeScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
