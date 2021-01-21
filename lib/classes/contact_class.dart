import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String uidColumn = "idColumn";
final String nameColumn = "nameColumn";
final String telefoneColumn = "telefoneColumn";
final String emailColumn = "emailColumn";
final String imgColumn = "imgColumn";

class ContactClass {
  static final ContactClass _instance = ContactClass.internal();
  factory ContactClass() => _instance;
  ContactClass.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts2.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($uidColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
          "$telefoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [
          uidColumn,
          nameColumn,
          telefoneColumn,
          emailColumn,
          imgColumn
        ],
        where: "$uidColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0)
      return Contact.fromMap(maps.first);
    else
      return null;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$uidColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contato) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contato.toMap(),
        where: "$uidColumn = ?", whereArgs: [contato.id]);
  }

  Future<List> getAllContact() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) $contactTable"));
  }

  Future<void> closeBd() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id;
  String name, email, telefone, img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[uidColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    telefone = map[telefoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      telefoneColumn: telefone,
      imgColumn: img
    };
    if (id != null) map[uidColumn] = id;
    return map;
  }

  @override
  String toString() {
    return "Contact( id: $id, nome: $name, email: $email, telefone: $telefone, img: $img)";
  }
}
