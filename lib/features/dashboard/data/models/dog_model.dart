class DogModel {
  final String id;
  final String? name;
  final String? microchipId;
  final String ephemeralId;
  final String? tokenNumber;
  final String? barcode;
  final String ownershipStatus;
  final bool isActive;
  final bool isSterilized;
  final String? color;
  final String? dateOfBirth;
  final String? identification;
  final String? latitude;
  final String? longitude;
  final String? imageUrl;
  final String district;
  final String zone;
  final String ward;

  DogModel({
    required this.id,
    this.name,
    this.microchipId,
    required this.ephemeralId,
    this.tokenNumber,
    this.barcode,
    required this.ownershipStatus,
    required this.isActive,
    this.isSterilized = false,
    this.color,
    this.dateOfBirth,
    this.identification,
    this.latitude,
    this.longitude,
    this.imageUrl,
    required this.district,
    required this.zone,
    required this.ward,
  });

  factory DogModel.fromJson(Map<String, dynamic> json) {
    return DogModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      microchipId: json['microchipId'] as String?,
      ephemeralId: json['ephemeralId'] as String,
      tokenNumber: json['tokenNumber'] as String?,
      barcode: json['barcode'] as String?,
      ownershipStatus: json['ownershipStatus'] as String,
      isActive: json['isActive'] as bool? ?? false,
      isSterilized: json['isSterilized'] as bool? ?? false,
      color: json['color'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      identification: json['identification'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      imageUrl: json['imageUrl'] as String?,
      district: json['district'] as String? ?? '',
      zone: json['zone'] as String? ?? '',
      ward: json['ward'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'microchipId': microchipId,
      'ephemeralId': ephemeralId,
      'tokenNumber': tokenNumber,
      'barcode': barcode,
      'ownershipStatus': ownershipStatus,
      'isActive': isActive,
      'isSterilized': isSterilized,
      'color': color,
      'dateOfBirth': dateOfBirth,
      'identification': identification,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'district': district,
      'zone': zone,
      'ward': ward,
    };
  }

  DogModel copyWith({
    String? id,
    String? name,
    String? microchipId,
    String? ephemeralId,
    String? tokenNumber,
    String? barcode,
    String? ownershipStatus,
    bool? isActive,
    bool? isSterilized,
    String? color,
    String? dateOfBirth,
    String? identification,
    String? latitude,
    String? longitude,
    String? imageUrl,
    String? district,
    String? zone,
    String? ward,
  }) {
    return DogModel(
      id: id ?? this.id,
      name: name ?? this.name,
      microchipId: microchipId ?? this.microchipId,
      ephemeralId: ephemeralId ?? this.ephemeralId,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      barcode: barcode ?? this.barcode,
      ownershipStatus: ownershipStatus ?? this.ownershipStatus,
      isActive: isActive ?? this.isActive,
      isSterilized: isSterilized ?? this.isSterilized,
      color: color ?? this.color,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      identification: identification ?? this.identification,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      district: district ?? this.district,
      zone: zone ?? this.zone,
      ward: ward ?? this.ward,
    );
  }
}
