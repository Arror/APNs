import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Master extends StatefulWidget {

  @override
  _MasterState createState() => _MasterState();
}

enum Certificate {
  p8,
  cer,
  p12
}

class _MasterState extends State<Master> with SingleTickerProviderStateMixin {

  TabController _controller;

  @override
  void initState() {
    super.initState();
    this._controller = TabController(
      length: Certificate.values.length,
      vsync: this
    );
  }

  @override
  void dispose() {
    this._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('APNs Provider'),
        bottom: TabBar(
          tabs: Certificate.values.map((Certificate cert) {
            switch (cert) {
              case Certificate.p8:
                return Tab(text: '.p8');
              case Certificate.cer:
                return Tab(text: '.cer');
              case Certificate.p12:
                return Tab(text: '.p12');
            }
          }).toList(),
          controller: this._controller,
          labelStyle: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: TabBarView(
        controller: this._controller,
        children: Certificate.values.map((Certificate cert) {
          switch (cert) {
            case Certificate.p8:
              return Center(
                child: Text('P8')
              );
            case Certificate.cer:
              return Center(
                child: Text('Cer')
              );
            case Certificate.p12:
              return Center(
                child: Text('P12')
              );
          }
        }).toList()
      )
    );
  }
}