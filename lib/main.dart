import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  httpClientDemo() async {

    try {
      var httpClient = HttpClient();
      httpClient.idleTimeout = Duration(seconds: 5);
      var uri = Uri.parse("https://flutter.dev");
      var request = await httpClient.getUrl(uri);
      request.headers.add("user-agent", "Custom-UA");
      var response = await request.close();

      print('Respone code: ${response.statusCode}');
      print(await response.transform(utf8.decoder).join());
    }
    catch(e) {
      print('Error:$e');
    }

  }

  httpDemo() async{
    try {
      var client = http.Client();
      var uri = Uri.parse("https://flutter.dev");
      http.Response response = await client.get(uri, headers : {"user-agent" : "Custom-UA"});
      print('Respone code: ${response.statusCode}');
      print(response.body);
    }
    catch(e) {
      print('Error:$e');
    }

  }

  dioDemo() async{
    try {
      Dio dio = new Dio();
      var response = await dio.get("https://flutter.dev", options:Options(headers: {"user-agent" : "Custom-UA"}));
      print(response.data.toString());
    }
    catch(e) {
      print('Error:$e');
    }
  }

  dioParallDemo() async {
    try {
      Dio dio = new Dio();
      List<Response> responseX= await Future.wait([dio.get("https://flutter.dev"),dio.get("https://pub.dev/packages/dio")]);

      //打印请求1响应结果
      print("Response1: ${responseX[0].toString()}");
      //打印请求2响应结果
      print("Response2: ${responseX[1].toString()}");
    }
    catch(e) {
      print('Error:$e');
    }
  }

  dioInterceptorReject() async {
    Dio dio = new Dio();
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler){
          handler.reject(DioError(requestOptions: options, message: "Error：拦截的原因"));
        }
    ));

    try {
      var response = await dio.get("https://flutter.dev");
      print(response.data.toString());

    }catch(e) {
      print('Error:$e');
    }

  }

  dioIntercepterCache() async {
    Dio dio = new Dio();
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler){
          return handler.resolve(Response(data: "返回缓存数据", requestOptions: options));
        }
    ));



    try {
      var response = await dio.get("https://flutter.dev");
      print(response.data.toString());

    }catch(e) {
      print('Error:$e');
    }

  }

  dioIntercepterCustomHeader() async {
    Dio dio = new Dio();
    dio.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler){
          options.headers["user-agent"] = "Custom-UA";
          handler.next(options);
        }
    ));

    try {
      var response = await dio.get("https://flutter.dev");
      print(response.requestOptions.headers);
      print(response.data.toString());

    }catch(e) {
      print('Error:$e');
    }
  }

  // String jsonString = '''
  //   {
  //     "id":"123",
  //     "name":"张三",
  //     "score" : 95,
  //     "teacher":
  //        {
  //          "name": "李四",
  //          "age" : 40
  //        }
  //   }
  //   ''';

  String jsonString = '''
  {
    "id":"123",
    "name":"张三",
    "score" : 95,
    "teachers": [
       {
         "name": "李四",
         "age" : 40
       },
       {
         "name": "王五",
         "age" : 45
       }
    ]
  }
  ''';

  static Student parseStudent(String content) {
    final jsonResponse = json.decode(content);
    Student student = Student.fromJson(jsonResponse);
    return student;
  }

  Future<Student> loadStudent() {
    return compute(parseStudent,jsonString);
  }

  jsonParseDemo() {
      loadStudent().then((s) {
        print("\n${s.toString()}");
      });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          children: <Widget>[
            ElevatedButton(
              child: Text('HttpClient demo'),
              onPressed: ()=>httpClientDemo(),
            ),
            ElevatedButton(
              child: Text('http demo'),
              onPressed: ()=>httpDemo(),
            ),
            ElevatedButton(
              child: Text('Dio demo'),
              onPressed: ()=>dioDemo(),
            ),
            ElevatedButton(
              child: Text('Dio 并发demo'),
              onPressed: ()=>dioParallDemo(),
            ),
            ElevatedButton(
              child: Text('Dio 拦截'),
              onPressed: ()=>dioInterceptorReject(),
            ),
            ElevatedButton(
              child: Text('Dio 缓存'),
              onPressed: ()=>dioIntercepterCache(),
            ),
            ElevatedButton(
              child: Text('Dio 自定义header'),
              onPressed: ()=>dioIntercepterCustomHeader(),
            ),
            ElevatedButton(
              child: Text('JSON解析demo'),
              onPressed: ()=>jsonParseDemo(),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}




class Student{
  String id;
  String name;
  int score;
  List<Teacher> teachers;

  Student({this.id, this.name, this.score,this.teachers});

  factory Student.fromJson(Map<String, dynamic> parsedJson)  {
    return Student(
        id: parsedJson['id'],
        name: parsedJson['name'],
        score: parsedJson['score'],
        teachers:(parsedJson['teachers'].map<Teacher>((e) => Teacher.fromJson(e))).toList()
    );
  }

  @override
  String toString() {
    String conttent = '''    
name: ${name}
score:${score}
teachers:"[${teachers.map((e) => e.name).reduce((value, element) => value += ", ${element}")}]"
    ''';
    return conttent;
  }
}


class Teacher {
  String name;
  int age;
  Teacher({this.name,this.age});

  factory Teacher.fromJson(Map<String, dynamic> parsedJson){
    return Teacher(
        name : parsedJson['name'],
        age : parsedJson ['age']
    );
  }
}

