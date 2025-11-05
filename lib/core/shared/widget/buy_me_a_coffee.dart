import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import './settings_item.dart';

// ignore: must_be_immutable
class BuyMeACoffee extends SettingsItem {
  BuyMeACoffee({
    super.key,
    super.icon = Icons.euro_rounded,
    super.title = "",
    super.trailing = const Icon(Icons.arrow_right_rounded),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Uri url = Uri.parse("https://buymeacoffee.com/namania");
        if (!await launchUrl(url, mode: LaunchMode.externalApplication) && kDebugMode) {
          print("Can't open url");
        }
      },
      child: Card(
        color: Color.fromARGB(255, 255, 221, 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Image.asset("assets/images/bmac.webp", scale: 5,),
              Text("Buy me a coffee", style: TextTheme.of(context).titleLarge!.apply(
                color: Colors.black87,
                fontFamily: "Cookie",
              ),),
            ],
          )
        ),
      ),
    );
  }
}
