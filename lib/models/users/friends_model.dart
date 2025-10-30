import 'dart:io';

class FriendsModel {
  String? name;
  String? birthday;
  String? phone;
  List<File>? _imagesOfGallery = [
    File(
      '/data/user/0/com.budlee.app.budlee_app/cache/c7bd4d45-5089-465b-ab64-a1d36815adc0/1000485663.jpg',
    ),
    File(
      '/data/user/0/com.budlee.app.budlee_app/cache/bd0fe56f-00e6-4f14-b5bb-8382e25169d6/1000465734.png',
    ),
  ];
  String? bio;
  String? image; // Assumed to be a URL/path string
  String? coverImage; // Assumed to be a URL/path string
  String? uId;
  File? profileImageFile;
  File? coverImageFile;

  FriendsModel({
    this.name,
    this.birthday,
    this.phone,
    this.bio,
    this.image,
    List<File>? imagesOfGallery, // Constructor parameter
    this.coverImage,
    this.uId,
    this.profileImageFile,
    this.coverImageFile,
  }) {
    // If imagesOfGallery is provided in constructor, use it via the setter
    if (imagesOfGallery != null) {
      this.imagesOfGallery = imagesOfGallery;
    }
    // Otherwise, it keeps the default _imagesOfGallery initialization
  }

  List<File>? get imagesOfGallery => _imagesOfGallery;

  set imagesOfGallery(dynamic value) {
    if (value == null) {
      _imagesOfGallery = null;
    } else if (value is List<File>) {
      _imagesOfGallery = value;
    } else if (value is List<String>) {
      _imagesOfGallery = value.map((path) => File(path)).toList();
    } else if (value is List) {
      // Attempt to convert if it's List<dynamic> containing strings or files
      if (value.every((e) => e is String)) {
        _imagesOfGallery = value
            .cast<String>()
            .map((path) => File(path))
            .toList();
      } else if (value.every((e) => e is File)) {
        _imagesOfGallery = value.cast<File>().toList();
      } else {
        // Fallback: try to convert strings, filter others
        _imagesOfGallery = value
            .whereType<String>()
            .map((path) => File(path))
            .toList();
        print(
          'UserModel: imagesOfGallery assigned a List with mixed/unexpected types. Only strings were converted.',
        );
      }
    } else {
      print(
        'UserModel: Unexpected type for imagesOfGallery: ${value.runtimeType}. Setting to null.',
      );
      _imagesOfGallery = null;
    }
  }

  FriendsModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    birthday = json['birthday'];
    image = json['avatar'];
    // Use the setter to assign and potentially convert gallery data
    imagesOfGallery = json['gallery'];
    coverImage = json['coverImage'];
    bio = json['bio'];
    phone = json['phone'];
    uId = json['uId'];

    if (json.containsKey('gallery')) {
      // Use the setter to assign and potentially convert gallery data
      this.imagesOfGallery = json['gallery'];
    }
    // If 'gallery' key is missing, _imagesOfGallery retains its default value.

    if (json.containsKey('profileImageFile')) {
      final dynamic profileImageData = json['profileImageFile'];
      if (profileImageData is String) {
        profileImageFile = File(profileImageData);
      } else if (profileImageData == null) {
        profileImageFile = null;
      }
    }

    if (json.containsKey('coverImageFile')) {
      final dynamic coverImageData = json['coverImageFile'];
      if (coverImageData is String) {
        coverImageFile = File(coverImageData);
      } else if (coverImageData == null) {
        coverImageFile = null;
      }
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthday': birthday,
      'bio': bio,
      'avatar': image,
      // Use the getter for imagesOfGallery
      'gallery': imagesOfGallery?.map((file) => file.path).toList().toString(),
      'profileImageFile': profileImageFile?.path,
      'coverImageFile': coverImageFile?.path,
      'coverImage': coverImage,
      'phone': phone,
      'uId': uId,
    };
  }
}
