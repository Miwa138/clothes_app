import 'dart:convert';
import 'package:clothes_app/admin/admin_upload_items.dart';
import 'package:clothes_app/api_connection/api_connection.dart';
import 'package:clothes_app/users/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../admin_upload_mysql.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  var formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  loginAdminNow() async {
    try {
      var res = await http.post(Uri.parse(API.adminlogin), body: {
        'admin_email': emailController.text.trim(),
        'admin_password': passwordController.text.trim()
      });
      if (res.statusCode == 200) {
        var resBodyOfLogin = jsonDecode(res.body);
        if (resBodyOfLogin['success'] == true) {
          Fluttertoast.showToast(msg: "Привет!");
           Get.to(AddProductScreen());

        } else {
          Fluttertoast.showToast(msg: 'Неверный Логин или Пароль');
        }
      } else if (res.statusCode == 503) {
        Fluttertoast.showToast(
            msg: 'Сервер временно недоступен, попробуйте позже');
      } else {
        Fluttertoast.showToast(msg: 'Неверный Логин или Пароль');
      }
    } catch (errorMsg) {
      print("Error ::" + errorMsg.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: LayoutBuilder(
        builder: (context, cons) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: cons.maxHeight),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Вход в систему",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              TextFormField(
                                controller: emailController,
                                validator: (val) =>
                                    val == "" ? "Введите email" : null,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Colors.black,
                                  ),
                                  fillColor: Colors.grey,
                                  hintText: "email...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: passwordController,
                                validator: (val) => val == "" ? "Пароль" : null,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.key,
                                    color: Colors.black,
                                  ),
                                  fillColor: Colors.grey,
                                  hintText: "Пароль...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Container(
                                width: 120,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black,
                                  ),
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      loginAdminNow();
                                    }
                                  },
                                  child: const Text("Войти"),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              // TextButton(
                              //     onPressed: () {
                              //       Get.to(SignUpScreen());
                              //     },
                              //     child: const Text("Создать учётную запись")),
                              const SizedBox(
                                height: 15,
                              ),
                              TextButton(
                                  onPressed: () {
                                    Get.to(const LoginScreen());
                                  },
                                  child: const Text("I am not an Admin")),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
