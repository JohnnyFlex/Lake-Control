import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const COLOR_BLACK = Color.fromRGBO(48, 47, 48, 1.0);
const COLOR_GREY = Color.fromRGBO(141, 141, 141, 1.0);
const COLOR_RED = Color.fromRGBO(240,72,94,1.0);
const COLOR_BLUE = Color.fromRGBO(138,222,253,1.0);
const COLOR_GREEN = Color.fromRGBO(114, 217, 180, 1.0);
const COLOR_SWITCH = Color.fromRGBO(252, 134, 71, 1.0);

const TextTheme TEXT_THEME_DEFAULT = TextTheme(
  headline1: TextStyle(
    color: COLOR_BLACK, fontWeight: FontWeight.w700, fontSize: 35),
  headline2: TextStyle(
    color: COLOR_BLACK, fontWeight: FontWeight.w500, fontSize: 16),
  headline3: TextStyle(
      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 34),
  headline4: TextStyle(
      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
  bodyText1: TextStyle(
    color: COLOR_BLACK, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
  bodyText2: TextStyle(
      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
  subtitle1: TextStyle(
      color: COLOR_GREY, fontSize: 12, fontWeight: FontWeight.w400, height: 1.5),
  );