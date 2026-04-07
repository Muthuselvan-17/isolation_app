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
  final String? symptoms;
  final int? roomNumber;
  final String? isolatedvaccinationDate;
  final String? sterilizationDate;
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
    this.symptoms,
    this.roomNumber,
    this.isolatedvaccinationDate,
    this.sterilizationDate,
    this.latitude,
    this.longitude,
    this.imageUrl,
    required this.district,
    required this.zone,
    required this.ward,
  });

  factory DogModel.fromJson(Map<String, dynamic> json) {
    return DogModel(
      id: (json['id'] ?? json['_id'] ?? '') as String,
      name: json['name']?.toString(),
      microchipId: json['microchipId']?.toString(),
      ephemeralId: (json['ephemeralId'] ?? '') as String,
      tokenNumber: json['tokenNumber']?.toString(),
      barcode: json['barcode']?.toString(),
      ownershipStatus: (json['ownershipStatus'] ?? 'unknown') as String,
      isActive: json['isActive'] as bool? ?? false,
      isSterilized: json['isSterilized'] as bool? ?? false,
      color: json['color']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      identification: json['identification']?.toString(),
      symptoms: json['symptoms']?.toString(),
      roomNumber: json['roomNumber'] as int?,
      isolatedvaccinationDate: json['isolatedvaccinationDate']?.toString(),
      sterilizationDate: json['sterilizationDate']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      imageUrl: (json['imageUrl'] ?? json['imageURL'])?.toString(),
      district: (json['district'] ?? '') as String,
      zone: (json['zone'] ?? '') as String,
      ward: (json['ward'] ?? '') as String,
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
      'symptoms': symptoms,
      'roomNumber': roomNumber,
      'isolatedvaccinationDate': isolatedvaccinationDate,
      'sterilizationDate': sterilizationDate,
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
    String? symptoms,
    int? roomNumber,
    String? isolatedvaccinationDate,
    String? sterilizationDate,
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
      symptoms: symptoms ?? this.symptoms,
      roomNumber: roomNumber ?? this.roomNumber,
      isolatedvaccinationDate: isolatedvaccinationDate ?? this.isolatedvaccinationDate,
      sterilizationDate: sterilizationDate ?? this.sterilizationDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      district: district ?? this.district,
      zone: zone ?? this.zone,
      ward: ward ?? this.ward,
    );
  }
}
