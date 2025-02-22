import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobilino_app/constants/http_request.dart';
import 'package:mobilino_app/constants/urls.dart';
import 'package:mobilino_app/models/depot.dart';
import 'package:mobilino_app/models/etablissement.dart';
import 'package:mobilino_app/models/user.dart';
import 'package:mobilino_app/screens/authentication/login_page.dart';
import 'package:mobilino_app/utils/routers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseProvider extends ChangeNotifier {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  String _token = '';

  String _userId = '';

  String _roleCRM = '';

  String _role = '';

  String _roleId = '';

  String _image = '';

  void saveToken(String token) async {
    SharedPreferences value = await _pref;
    value.setString('token', token);
  }

  void saveUserId(String id) async {
    SharedPreferences value = await _pref;
    value.setString('id', id);
  }

  void saveRoleCRM(String roleCRM) async {
    SharedPreferences value = await _pref;
    value.setString('roleCRM', roleCRM);
  }

  void saveRoleValue(String role) async {
    SharedPreferences value = await _pref;
    value.setString('role', role);
  }

  void saveOneUser(User user) async {
    print('hhh save one: ');
    SharedPreferences value = await _pref;
    if (user.firstName != null) value.setString('firstName', user.firstName!);
    if (user.lastName != null) value.setString('lastName', user.lastName!);
    if (user.email != null) value.setString('email', user.email!);
    if (user.salCode != null) value.setString('salCode', user.salCode!);
    if (user.phone != null) value.setString('phoneNumber', user.phone!);
    if (user.localDepot != null) {
      value.setString('depCode', user.localDepot!.id!);
      if (user.localDepot!.name != null)
        value.setString('depNom', user.localDepot!.name!);
    }
    if (user.equipeId != null)
      value.setString('equipeID', user.equipeId!.toString());
    if (user.company != null)
      value.setString('company', user.company.toString());

    if (user.repCode != null)
      value.setString('repCode', user.repCode.toString());
  }

  void saveSalCode(String roleId) async {
    SharedPreferences value = await _pref;
    value.setString('salCode', roleId);
  }

  void saveDepotAndRep(Depot? dep, String? rep) async {
    SharedPreferences value = await _pref;
    if(rep != null)
    value.setString('repCode', rep);
    if(dep != null){
      value.setString('depCode', dep.id!);
      value.setString('depNom', dep.name!);
    }

  }

  void saveImage(String image) async {
    SharedPreferences value = await _pref;
    value.setString('image', image);
  }

  void saveEtablissements(Etablissement etablissement) async {
    SharedPreferences value = await _pref;
    value.setString('codeEtabliss', etablissement.code!);
    value.setString('nameEtabliss', etablissement.name!);
    value.setString('rsEtabliss', etablissement.rs!);
  }

  Future<String> getToken() async {
    SharedPreferences value = await _pref;
    if (value.containsKey('token')) {
      String data = value.getString('token')!;
      _token = data;
      notifyListeners();
      return data;
    } else {
      _token = '';
      notifyListeners();
      return '';
    }
  }

  Future<String> getUserId() async {
    SharedPreferences value = await _pref;
    if (value.containsKey('id')) {
      String data = value.getString('id')!;
      _userId = data;
      notifyListeners();
      return data;
    } else {
      _userId = '';
      notifyListeners();
      return '';
    }
  }

  Future<String> getRoleCRM() async {
    SharedPreferences value = await _pref;
    if (value.containsKey('roleCRM')) {
      String data = value.getString('roleCRM')!;
      _roleCRM = data;
      notifyListeners();
      return data;
    } else {
      _roleCRM = '';
      notifyListeners();
      return '';
    }
  }

  Future<String> getRoleValue() async {
    SharedPreferences value = await _pref;
    if (value.containsKey('role')) {
      String data = value.getString('role')!;
      _role = data;
      notifyListeners();
      return data;
    } else {
      _role = '';
      notifyListeners();
      return '';
    }
  }

  Future<String> getRoleId() async {
    SharedPreferences value = await _pref;
    if (value.containsKey('roleId')) {
      String data = value.getString('roleId')!;
      _roleId = data;
      notifyListeners();
      return data;
    } else {
      _roleId = '';
      notifyListeners();
      return '';
    }
  }

  Future<String> getImage() async {
    SharedPreferences value = await _pref;
    if (value.containsKey('image')) {
      String data = value.getString('image')!;
      _image = data;
      notifyListeners();
      return data;
    } else {
      _image = '';
      notifyListeners();
      return '';
    }
  }

  Future<User> getUser() async {
    SharedPreferences value = await _pref;
    User user = User();
    if (value.containsKey('image')) {
      String data = value.getString('image')!;
      _image = data;
      user.image = data;
    }
    if (value.containsKey('equipeID')) {
      String data = value.getString('equipeID')!;
      user.equipeId = int.parse(data);
    }
    if (value.containsKey('roleId')) {
      String data = value.getString('roleId')!;
      _roleId = data;
      user.salCode = data;
    }
    if (value.containsKey('role')) {
      String data = value.getString('role')!;
      _role = data;
      user.role = data;
    }
    if (value.containsKey('roleCRM')) {
      String data = value.getString('roleCRM')!;
      _roleCRM = data;
      user.roleCRM = data;
    }
    if (value.containsKey('id')) {
      String data = value.getString('id')!;
      _userId = data;
      user.userId = data;
    }
    if (value.containsKey('token')) {
      String data = value.getString('token')!;
      _token = data;
      user.token = data;
    }
    user.etblssmnt = Etablissement();
    if (value.containsKey('codeEtabliss')) {
      String data = value.getString('codeEtabliss')!;
      _token = data;
      user.etblssmnt!.code = data;
    }
    if (value.containsKey('nameEtabliss')) {
      String data = value.getString('nameEtabliss')!;
      _token = data;
      user.etblssmnt!.name = data;
    }
    if (value.containsKey('rsEtabliss')) {
      String data = value.getString('rsEtabliss')!;
      _token = data;
      user.etblssmnt!.rs = data;
    }
    if (value.containsKey('firstName')) {
      String data = value.getString('firstName')!;
      _token = data;
      user.firstName = data;
      if (value.containsKey('lastName')) {
        String data = value.getString('lastName')!;
        _token = data;
        user.lastName = data;
      }
      if (value.containsKey('email')) {
        String data = value.getString('email')!;
        _token = data;
        user.email = data;
      }
      if (value.containsKey('company')) {
        String data = value.getString('company')!;
        _token = data;
        user.company = data;
      }
      if (value.containsKey('salCode')) {
        String data = value.getString('salCode')!;
        _token = data;
        user.salCode = data;
      }
      if (value.containsKey('repCode')) {
        String data = value.getString('repCode')!;
        _token = data;
        user.repCode = data;
      }
      if (value.containsKey('phone')) {
        String data = value.getString('phone')!;
        _token = data;
        user.phone = data;
      }
      final depot = Depot();
      print('hmmmmmmdepCode ${value.containsKey('depCode')}');
      if (value.containsKey('depCode')) {
        String data = value.getString('depCode')!;
        _token = data;
        depot.id = data;
        if (value.containsKey('depNom')) {
          String data = value.getString('depNom')!;
          _token = data;
          depot.name = data;
          user.localDepot = depot;
        }
      }
    }
    // value.setString('firstName', user.firstName!);
    // value.setString('lastName', user.firstName!);
    // value.setString('email', user.email!);
    // value.setString('salCode', user.salCode!);
    // value.setString('phoneNumber', user.phone!);
    notifyListeners();
    return user;
  }

  void logOut(BuildContext context) async {
    print('fff: ${AppUrl.user.salCode} ${AppUrl.user.etblssmnt!.code}');
    showLoaderDialog(context);
    if(AppUrl.user.etblssmnt!.code == null){
      final value = await _pref;
      value.clear();
      Navigator.pop(context);
      PageNavigator(ctx: context).nextPageOnly(page: const LoginPage());
      return;
    }
    HttpRequestApp()
        .sendItineraryDec(
            'DNX', AppUrl.user.salCode!, AppUrl.user.etblssmnt!.code!)
        .then((value) async {
      final value = await _pref;
      value.clear();
      Navigator.pop(context);
      PageNavigator(ctx: context).nextPageOnly(page: const LoginPage());
    });
  }

  void logOutExp(BuildContext context) async {
    final value = await _pref;
    value.clear();
    Navigator.pop(context);
    PageNavigator(ctx: context).nextPageOnly(page: const LoginPage());
  }
}
