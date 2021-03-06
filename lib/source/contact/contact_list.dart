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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ox_talk/main.dart';
import 'package:ox_talk/source/base/base_root_child.dart';
import 'package:ox_talk/source/contact/contact_import_bloc.dart';
import 'package:ox_talk/source/contact/contact_import_event.dart';
import 'package:ox_talk/source/contact/contact_import_state.dart';
import 'package:ox_talk/source/contact/contact_item.dart';
import 'package:ox_talk/source/contact/contact_list_bloc.dart';
import 'package:ox_talk/source/contact/contact_list_event.dart';
import 'package:ox_talk/source/contact/contact_list_state.dart';
import 'package:ox_talk/source/l10n/localizations.dart';
import 'package:ox_talk/source/ui/default_colors.dart';
import 'package:ox_talk/source/ui/dialog_util.dart';
import 'package:ox_talk/source/ui/dimensions.dart';
import 'package:rxdart/rxdart.dart';

class ContactListView extends BaseRootChild {
  @override
  _ContactListState createState() {
    final state = _ContactListState();
    addActions([state.getImportAction()]);
    return state;
  }

  @override
  Color getColor() {
    return DefaultColors.contactColor;
  }

  @override
  FloatingActionButton getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: new Icon(Icons.person_add),
      onPressed: () {
        _showAddContactView(context);
      },
    );
  }

  @override
  String getTitle(BuildContext context) {
    return AppLocalizations.of(context).contactsTitle;
  }

  @override
  String getNavigationText(BuildContext context) {
    return AppLocalizations.of(context).contactsTitle;
  }

  @override
  IconData getNavigationIcon() {
    return Icons.contacts;
  }

  _showAddContactView(BuildContext context) {
    Navigator.pushNamed(context, OxTalkApp.ROUTES_CONTACT_ADD);
  }
}

class _ContactListState extends State<ContactListView> {
  ContactListBloc _contactListBloc = ContactListBloc();
  ContactImportBloc _contactImportBloc = ContactImportBloc();

  @override
  void initState() {
    super.initState();
    _contactListBloc.dispatch(RequestContacts());
    setupContactImport();
  }

  setupContactImport() async {
    if (await _contactImportBloc.isInitialContactsOpening()) {
      _contactImportBloc.dispatch(MarkContactsAsInitiallyLoaded());
      _showImportDialog(true, context);
    }
    final contactImportObservable = new Observable<ContactImportState>(_contactImportBloc.state);
    contactImportObservable.listen((state) => handleContactImport(state));
  }

  handleContactImport(ContactImportState state) {
    if (state is ContactsImportSuccess) {
      String contactImportSuccess = "${state.changedCount} system contacts imported";
      _showToast(contactImportSuccess);
    } else if (state is ContactsImportFailure) {
      String contactImportFailure = "Import failed, missing permissions";
      _showToast(contactImportFailure);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _contactListBloc,
      builder: (context, state) {
        if (state is ContactListStateSuccess) {
          return buildListViewItems(state.contactIds, state.contactLastUpdateValues);
        } else if (state is! ContactListStateFailure) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Center(
            child: Text("Loading error"),
          );
        }
      },
    );
  }

  Widget getImportAction() {
    return IconButton(
      icon: Icon(Icons.import_contacts),
      onPressed: () => _showImportDialog(false, context),
    );
  }

  void _showImportDialog(bool initialImport, BuildContext context) {
    var importTitle = "Import system contacts";
    var importText = "Would you like to import your system contacts?";
    var content = initialImport
        ? "$importText This action can be also done later via the import button in the top action bar."
        : "$importText Re-importing your contacts will not create duplicates.";
    var importPositive = "Import";
    DialogUtil.showConfirmationDialog(
      context: context,
      title: importTitle,
      content: content,
      positiveButton: importPositive,
      positiveAction: () {
        _contactImportBloc.dispatch(PerformImport());
      },
    );
  }

  Widget buildListViewItems(List<int> contactIds, List<int> contactLastUpdateValues) {
    return ListView.builder(
        padding: EdgeInsets.all(Dimensions.listItemPadding),
        itemCount: contactIds.length,
        itemBuilder: (BuildContext context, int index) {
          var contactId = contactIds[index];
          var key = "$contactId-${contactLastUpdateValues[index]}";
          return ContactItem(contactId, key);
        });
  }

  _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIos: 4,
    );
  }
}
