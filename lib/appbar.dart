import 'package:flutter/material.dart';
import 'package:guitest/main.dart';
import 'package:guitest/theme.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 40,
      actions: [
        for(String route in routes.keys)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(pageBuilder: ((context, animation, secondaryAnimation) {
                  return routes[route]!(context);
                }),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero)
              );
            },
            child: Padding(
              padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
              child: Text(routeNames[route]!, style: ThemeManager.textStyle,),
            ),
          ),
        const Spacer()
      ],
    );
  }
}