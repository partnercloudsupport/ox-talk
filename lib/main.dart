/*
 * OPEN-XCHANGE legal information
 *
 * All intellectual property rights in the Software are protected by
 * international copyright laws.
 *
 *
 * In some countries OX, OX Open-Xchange and open xchange
 * as well as the corresponding Logos OX Open-Xchange and OX are registered
 * trademarks of the OX Software GmbH group of companies.
 * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 * Instead, you are allowed to use these Logos according to the terms and
 * conditions of the Creative Commons License, Version 2.5, Attribution,
 * Non-commercial, ShareAlike, and the interpretation of the term
 * Non-commercial applicable to the aforementioned license is published
 * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *
 * Please make sure that third-party modules and libraries are used
 * according to their respective licenses.
 *
 * Any modifications to this package must retain all copyright notices
 * of the original copyright holder(s) for the original code used.
 *
 * After any such modifications, the original and derivative code shall remain
 * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 * https://www.open-xchange.com/legal/. The contributing author shall be
 * given Attribution for the derivative code and a license granting use.
 *
 * Copyright (C) 2016-2020 OX Software GmbH
 * Mail: info@open-xchange.com
 *
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 * for more details.
 */

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/material.dart';
import 'package:ox_talk/source/base/bloc_delegate.dart';
import 'package:ox_talk/source/contact/contact_change.dart';
import 'package:ox_talk/source/l10n/localizations.dart';
import 'package:ox_talk/source/login/login.dart';
import 'package:ox_talk/source/main/root.dart';
import 'package:ox_talk/source/main/splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ox_talk/source/profile/edit_user_settings.dart';

void main() {
  BlocSupervisor().delegate = DebugBlocDelegate();
  runApp(new OxTalkApp());
}

class OxTalkApp extends StatelessWidget {

  static const String ROUTES_ROOT = "/";

  static const ROUTES_CONTACT_ADD = '/contactAdd';
  static const ROUTES_EDIT_USER = '/editUser';

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
      ],
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: ROUTES_ROOT,
      routes: {
        ROUTES_ROOT: (context) => _OxTalk(),
        ROUTES_CONTACT_ADD: (context) => ContactChange(add: true,),
      },
    );
  }
}

class _OxTalk extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OxTalkState();
}

class _OxTalkState extends State<_OxTalk> {
  DeltaChatCore _core;
  Context _context;
  bool _coreLoaded = false;
  bool _configured = false;

  @override
  void initState() {
    super.initState();
    _initCoreAndContext();
  }

  @override
  Widget build(BuildContext context) {
    if (!_coreLoaded) {
      return new Splash();
    } else {
      return _buildMainScreen();
    }
  }

  void _initCoreAndContext() async {
    _core = DeltaChatCore();
    await _core.init();
    _context = Context();
    await _isConfigured();
    setState(() {
      _coreLoaded = true;
    });
  }

  Future _isConfigured() async {
    _configured = await _context.isConfigured();
  }

  Widget _buildMainScreen() {
    if (_configured) {
      return new Root();
    } else {
      return new Login(loginSuccess);
    }
  }

  void loginSuccess() async {
    setState(() {
      _configured = true;
    });
  }

}
