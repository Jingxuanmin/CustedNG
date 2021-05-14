import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:custed2/core/route.dart';
import 'package:custed2/data/providers/user_provider.dart';
import 'package:custed2/data/store/user_data_store.dart';
import 'package:custed2/locator.dart';
import 'package:custed2/core/utils.dart';
import 'package:custed2/ui/webview/plugin_debug.dart';
import 'package:custed2/ui/webview/plugin_login.dart';
import 'package:custed2/ui/webview/plugin_mysso.dart';
import 'package:custed2/ui/webview/webview2.dart';
import 'package:custed2/ui/webview/webview2_controller.dart';
import 'package:flutter/material.dart';

class WebviewLogin extends StatefulWidget {
  WebviewLogin({
    this.noLogin = false,
    this.clearCookies = false,
  });

  static Future<bool> begin(
    BuildContext context, {
    noLogin = false,
    clearCookies = false,
  }) async {
    final result = await AppRoute(
      title: '登录(560+)',
      page: WebviewLogin(noLogin: noLogin, clearCookies: clearCookies),
    ).go(context);
    return result == true;
  }

  final bool noLogin;
  final bool clearCookies;

  @override
  _WebviewLoginState createState() => _WebviewLoginState();
}

class _WebviewLoginState extends State<WebviewLogin> {
  String username;
  String password;

  var loginDone = false;

  @override
  Widget build(BuildContext context) {
    return Webview2(
      onCreated: onCreated,
      onLoadAborted: onLoadAborted,
      invalidUrlRegex: r'custp\/index',
      plugins: [
        PluginForMysso(),
        PluginForLogin(onLoginData),
        PluginForDebug(),
      ],
    );
  }

  void onCreated(Webview2Controller controller) async {
    if (widget.clearCookies) {
      await controller.clearCookies();
    }

    Timer(Duration(milliseconds: 500), () async {
      await controller.loadUrl(
        'https://mysso.cust.edu.cn/cas/login?service=https://portal.cust.edu.cn/custp/shiro-cas',
      );
    });
  }

  void onLoadAborted(Webview2Controller controller, String url) async {
    if (loginDone) {
      return;
    }

    if (url.contains('portal.cust.edu.cn')) {
      loginDone = true;
      await loginSuccessCallback(controller);
    }
  }

  void onLoginData(String username, String password) {
    this.username = username;
    this.password = password;
  }

  Future<void> loginSuccessCallback(Webview2Controller controller) async {
    const mysso = 'https://mysso.cust.edu.cn/cas/login';
    final cookies = await controller.getCookies(mysso);

    final cookieJar = locator<PersistCookieJar>();
    await cookieJar.saveFromResponse(Uri.parse(mysso), cookies);

    final userData = await locator.getAsync<UserDataStore>();
    userData.username.put(this.username);
    userData.password.put(this.password);

    await controller.close();
    Navigator.of(context).pop(true);

    if (widget.noLogin) {
      return;
    }

    try {
      final user = locator<UserProvider>();
      await user.login();
      showSnackBar(context, '登录成功');
    } catch (e) {
      showSnackBar(context, '登录出错啦 等下再试吧');
      rethrow;
    }
  }
}
