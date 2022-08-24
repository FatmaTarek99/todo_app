import 'package:flutter/material.dart';

import 'layout/home_layout.dart';

main ()
{
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
     return MaterialApp(
       debugShowCheckedModeBanner: false,
       home: HomeLayout(),
     );
  }
}