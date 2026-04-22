import 'package:hive/hive.dart';

class ProfileModel extends HiveObject {
  String name;
  String email;
  String phone;
  String? imagePath;

  ProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    this.imagePath,
  });
}

class ProfileModelAdapter extends TypeAdapter<ProfileModel> {
  @override
  final int typeId = 1;

  @override
  ProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    return ProfileModel(
      name: fields[0],
      email: fields[1],
      phone: fields[2],
      imagePath: fields[3],
    );
  }

  @override
  void write(BinaryWriter writer, ProfileModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.imagePath);
  }
}