// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jmas_desktop/service/auth_service.dart';

class RoleController {
  final AuthService _authService = AuthService();

  //ListRole
  Future<List<Role>> listRole() async {
    try {
      final response = await http.get(
        Uri.parse('${_authService.apiNubeURL}/Roles'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((role) => Role.fromMap(role)).toList();
      } else {
        print(
            'Error al obtener roles | Ife | Controller: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error al listar roles | Ife | Controller: $e');
      return [];
    }
  }

  //EditRole
  Future<bool> editRole(Role role) async {
    try {
      final response = await http.put(
        Uri.parse('${_authService.apiURL}/Roles/${role.idRole}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: role.toJson(),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print(
            'Error editRole | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error editRole | Try | Controller: $e');
      return false;
    }
  }

  //Add
  Future<bool> addRol(Role role) async {
    try {
      final response = await http.post(
        Uri.parse('${_authService.apiURL}/Roles'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: role.toJson(),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print(
            'Error addRol | Ife | Controller: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error addRole | Try | Controller: $e');
      return false;
    }
  }
}

class Role {
  int? idRole;
  String? roleNombre;
  String? roleDescr;
  bool? canView;
  bool? canAdd;
  bool? canEdit;
  bool? canDelete;
  bool? canManageUsers;
  bool? canManageRoles;
  bool? canEvaluar;
  bool? canCContables;
  bool? canManageJuntas;
  bool? canManageProveedores;
  bool? canManageContratistas;
  bool? canManageCalles;
  bool? canManageColonias;
  bool? canManageAlmacenes;
  Role({
    this.idRole,
    this.roleNombre,
    this.roleDescr,
    this.canView,
    this.canAdd,
    this.canEdit,
    this.canDelete,
    this.canManageUsers,
    this.canManageRoles,
    this.canEvaluar,
    this.canCContables,
    this.canManageJuntas,
    this.canManageProveedores,
    this.canManageContratistas,
    this.canManageCalles,
    this.canManageColonias,
    this.canManageAlmacenes,
  });

  Role copyWith({
    int? idRole,
    String? roleNombre,
    String? roleDescr,
    bool? canView,
    bool? canAdd,
    bool? canEdit,
    bool? canDelete,
    bool? canManageUsers,
    bool? canManageRoles,
    bool? canEvaluar,
    bool? canCContables,
    bool? canManageJuntas,
    bool? canManageProveedores,
    bool? canManageContratistas,
    bool? canManageCalles,
    bool? canManageColonias,
    bool? canManageAlmacenes,
  }) {
    return Role(
      idRole: idRole ?? this.idRole,
      roleNombre: roleNombre ?? this.roleNombre,
      roleDescr: roleDescr ?? this.roleDescr,
      canView: canView ?? this.canView,
      canAdd: canAdd ?? this.canAdd,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canManageRoles: canManageRoles ?? this.canManageRoles,
      canEvaluar: canEvaluar ?? this.canEvaluar,
      canCContables: canCContables ?? this.canCContables,
      canManageJuntas: canManageJuntas ?? this.canManageJuntas,
      canManageProveedores: canManageProveedores ?? this.canManageProveedores,
      canManageContratistas:
          canManageContratistas ?? this.canManageContratistas,
      canManageCalles: canManageCalles ?? this.canManageCalles,
      canManageColonias: canManageColonias ?? this.canManageColonias,
      canManageAlmacenes: canManageAlmacenes ?? this.canManageAlmacenes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idRole': idRole,
      'roleNombre': roleNombre,
      'roleDescr': roleDescr,
      'canView': canView,
      'canAdd': canAdd,
      'canEdit': canEdit,
      'canDelete': canDelete,
      'canManageUsers': canManageUsers,
      'canManageRoles': canManageRoles,
      'canEvaluar': canEvaluar,
      'canCContables': canCContables,
      'canManageJuntas': canManageJuntas,
      'canManageProveedores': canManageProveedores,
      'canManageContratistas': canManageContratistas,
      'canManageCalles': canManageCalles,
      'canManageColonias': canManageColonias,
      'canManageAlmacenes': canManageAlmacenes,
    };
  }

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      idRole: map['idRole'] != null ? map['idRole'] as int : null,
      roleNombre:
          map['roleNombre'] != null ? map['roleNombre'] as String : null,
      roleDescr: map['roleDescr'] != null ? map['roleDescr'] as String : null,
      canView: map['canView'] != null ? map['canView'] as bool : null,
      canAdd: map['canAdd'] != null ? map['canAdd'] as bool : null,
      canEdit: map['canEdit'] != null ? map['canEdit'] as bool : null,
      canDelete: map['canDelete'] != null ? map['canDelete'] as bool : null,
      canManageUsers:
          map['canManageUsers'] != null ? map['canManageUsers'] as bool : null,
      canManageRoles:
          map['canManageRoles'] != null ? map['canManageRoles'] as bool : null,
      canEvaluar: map['canEvaluar'] != null ? map['canEvaluar'] as bool : null,
      canCContables:
          map['canCContables'] != null ? map['canCContables'] as bool : null,
      canManageJuntas: map['canManageJuntas'] != null
          ? map['canManageJuntas'] as bool
          : null,
      canManageProveedores: map['canManageProveedores'] != null
          ? map['canManageProveedores'] as bool
          : null,
      canManageContratistas: map['canManageContratistas'] != null
          ? map['canManageContratistas'] as bool
          : null,
      canManageCalles: map['canManageCalles'] != null
          ? map['canManageCalles'] as bool
          : null,
      canManageColonias: map['canManageColonias'] != null
          ? map['canManageColonias'] as bool
          : null,
      canManageAlmacenes: map['canManageAlmacenes'] != null
          ? map['canManageAlmacenes'] as bool
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Role.fromJson(String source) =>
      Role.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Role(idRole: $idRole, roleNombre: $roleNombre, roleDescr: $roleDescr, canView: $canView, canAdd: $canAdd, canEdit: $canEdit, canDelete: $canDelete, canManageUsers: $canManageUsers, canManageRoles: $canManageRoles, canEvaluar: $canEvaluar, canCContables: $canCContables, canManageJuntas: $canManageJuntas, canManageProveedores: $canManageProveedores, canManageContratistas: $canManageContratistas, canManageCalles: $canManageCalles, canManageColonias: $canManageColonias, canManageAlmacenes: $canManageAlmacenes)';
  }

  @override
  bool operator ==(covariant Role other) {
    if (identical(this, other)) return true;

    return other.idRole == idRole &&
        other.roleNombre == roleNombre &&
        other.roleDescr == roleDescr &&
        other.canView == canView &&
        other.canAdd == canAdd &&
        other.canEdit == canEdit &&
        other.canDelete == canDelete &&
        other.canManageUsers == canManageUsers &&
        other.canManageRoles == canManageRoles &&
        other.canEvaluar == canEvaluar &&
        other.canCContables == canCContables &&
        other.canManageJuntas == canManageJuntas &&
        other.canManageProveedores == canManageProveedores &&
        other.canManageContratistas == canManageContratistas &&
        other.canManageCalles == canManageCalles &&
        other.canManageColonias == canManageColonias &&
        other.canManageAlmacenes == canManageAlmacenes;
  }

  @override
  int get hashCode {
    return idRole.hashCode ^
        roleNombre.hashCode ^
        roleDescr.hashCode ^
        canView.hashCode ^
        canAdd.hashCode ^
        canEdit.hashCode ^
        canDelete.hashCode ^
        canManageUsers.hashCode ^
        canManageRoles.hashCode ^
        canEvaluar.hashCode ^
        canCContables.hashCode ^
        canManageJuntas.hashCode ^
        canManageProveedores.hashCode ^
        canManageContratistas.hashCode ^
        canManageCalles.hashCode ^
        canManageColonias.hashCode ^
        canManageAlmacenes.hashCode;
  }
}
