import 'package:deskit/edit_widget_page.dart';
import 'package:deskit/model/widget_type_info.dart';
import 'package:flutter/material.dart';

class AddWidgetPage extends StatelessWidget {
  static const routeName = '/addWidget';

  @override
  Widget build(BuildContext context) {
    final types = WidgetTypeInfo.values;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select widget type'),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(itemBuilder: (context, index) {
        if (index >= types.length) {
          return null;
        }
        final type = types[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: ListTile(
            leading: Icon(type.icon),
            title: Text(
              type.name,
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(type.description),
            ),
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                EditWidgetPage.routeName,
                arguments: EditWidgetPageArguments(
                  type.createDefaultConfig(),
                  isNew: true,
                ),
              );
              Navigator.pop(context, result);
            },
          ),
        );
      }),
    );
  }
}
