import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

final _navigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class AutoComplete {
  String nome;
  int id;
  AutoComplete({
    this.nome,
    this.id,
  });
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  var lstDb = <AutoComplete>[];
  var lst = <AutoComplete>[];
  var loading = false;


  OverlayEntry entry;
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    for (var i = 0; i < 5; i++) {
      lstDb.add(AutoComplete(nome: "Maria $i", id: i));
    }
    super.initState();
  }

  Future<List<Map>> _onRefresh(String text) async{
    await Future.delayed(Duration(seconds: 1), () {
      lst = lstDb.where((element) => element.nome.toLowerCase()
          .contains(text.toLowerCase())).toList();
      loading = false;
    });
    if(text == null || text == "")
      return null;
    return lst.map((e) => {"text": e.nome, "id": e.id}).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Texto"),
          Text("Texto"),
          Text("Texto"),
          Text("Texto"),
          //_buildInput(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: G2xAutocomplete(
              onSelected: (selected){
                print(selected);
              },
              onRefresh: _onRefresh,
              hintText: "Digite um nome para criar ou para buscar",
            ),
          ),
          Text("Texto1"),
           Text("Texto"),
          Text("Texto"),
          Text("Texto"),
          Text("Texto"),
           Text("Texto"),
          Text("Texto"),
          Text("Texto"),
          Text("Texto"),
           Text("Texto"),
          Text("Texto"),
          Text("Texto"),
          Text("Texto"),
        ],
      ),
    );
  }
}

class G2xAutocomplete extends StatefulWidget {
  final Function(dynamic) onSelected;
  final String fieldTextName;
  final String hintText;
  final Future<List<Map>> Function(String) onRefresh;

  G2xAutocomplete({
    Key key, @required this.onSelected,
    this.fieldTextName = "text",
    this.hintText = "", @required this.onRefresh
  }) : super(key: key);
  @override
  _G2xAutocompleteState createState() => _G2xAutocompleteState();
}

class _G2xAutocompleteState extends State<G2xAutocomplete> with TickerProviderStateMixin {
  OverlayEntry _entry;
  OverlayEntry _entryLoading;
  Timer _timer;
  var _key = GlobalKey();
  var _tc = TextEditingController();
  var _listItens = List<Map>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _removeEntry();
    _entryLoading?.remove();
    _entryLoading = null;
    _timer.cancel();
    _timer = null;
    _key = null;
    _tc.dispose();
    super.dispose();
  }

  _buildOverlayEntryLoading() {
    RenderBox box = _key.currentContext.findRenderObject();
    Offset position = box.localToGlobal(Offset.zero);
    return OverlayEntry(builder: (BuildContext context) {
      return Positioned(
        top: 50 + position.dy,
        left: box.size.width/2-10,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(2),
            color: Colors.white,
            height: 20,
            width: 20,
            child: CircularProgressIndicator()
          )
        ),
      );
    });
  }

   _buildOverlayEntry(Function(dynamic) onChange) {
    var _c = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    var _c1 = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    RenderBox box = _key.currentContext.findRenderObject();
    Offset position = box.localToGlobal(Offset.zero);
    return OverlayEntry(builder: (BuildContext context) {
      _c.forward();
      _c1.forward();
      return Positioned(
        top: 50 + position.dy,
        left: position.dx,
        child: Material(
          child: Container(
            height: 34.0 * _listItens.length,
            width: box.size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate( _listItens.length, (index) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin:  Offset(0, index * -1.0),
                    end: Offset(0, 0),
                  ).animate(
                    _c
                  ),
                  child: FadeTransition(
                    opacity: Tween<double>(
                    begin: -1,
                    end: 1
                  ).animate(_c1),
                    child: GestureDetector(
                      onTap: (){
                        onChange(_listItens[index]);
                        setState(() {});
                      },
                      child: Container(
                        width: box.size.width,
                        color: Colors.grey[200],
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          _listItens[index][widget.fieldTextName]
                        ),
                      ),
                    ),
                  )
                );
              }),
            ),
          ),
        )
      );
    });
  }

  onChangeItem(dynamic item){
    _tc.text = item[widget.fieldTextName];
    widget.onSelected(item);
    _removeEntry();
  }

  _removeEntry(){
    _listItens.clear();
    if(_entry != null){
      _entry.remove();
      _entry = null;
    }
  }

  _startTimeToSearch(Function func){
    _timer?.cancel();
    _timer = Timer(new Duration(milliseconds: 500), () {
      func();
    });
  }

  _buildInput(){
    return TextField(
      key: _key,
      controller: _tc,
      onChanged: (value){
        _listItens.clear();
        _startTimeToSearch(() {
          _onRefresh(value);
        });
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffix: _tc.text == null || _tc.text == "" ? SizedBox() : GestureDetector(
          onTap: (){
            _tc.clear();
            _removeEntry();
            setState(() {});
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.close, size: 15),
          ),
        )
      ),
    );
  }

  var isLoading = false;
  Future<Null> _onRefresh(String text) async {
    if(text == null || text == ""){
      _listItens = [];
      isLoading = false;
      setState(() {});  
      return;
    }
    isLoading = true;
    setState(() {});
    return await widget.onRefresh(text).then((value) {
      _listItens = value ?? [];
      isLoading = false;
      setState(() {});
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(isLoading){
        _entryLoading = _buildOverlayEntryLoading();
        _navigatorKey.currentState.overlay.insert(_entryLoading);
      }
      else{
        _entryLoading?.remove();
        _entryLoading = null;
        if(_listItens.length > 0){
          _entry = _buildOverlayEntry(onChangeItem);
          _navigatorKey.currentState.overlay.insert(_entry);
        }
        else{
          _removeEntry();
        }
      }
    });
    return Material(
      child: _buildInput(),
    );
  }
}