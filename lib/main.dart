import 'package:clothes_app/users/fragments/dashboard_of_fragments.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'generated/codegen_loader.g.dart';
import 'users/authentication/login_screen.dart';
import 'users/user_preferences/user_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
      EasyLocalization(
    assetLoader: CodegenLoader(),
    supportedLocales: [
      Locale('en'),
      Locale('ru')
    ],
    path: 'assets/lang',
    fallbackLocale: Locale('en'),
    child: MyApp(),
  ));
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get();
  }

  get()async{
    var permissionStatus = await Permission.storage.status;

    switch (permissionStatus) {
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
        await Permission.storage.request();
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
       home:

      FutureBuilder(
        future: RememberUserPrefs.readUserUser(),
        builder: (context, dataSnapShot)
        {
          if(dataSnapShot.data == null)
          {
            return LoginScreen();
          }
          else
          {
            return DashboardOfFragments();
          }
        },
      ),
    );
  }
}

