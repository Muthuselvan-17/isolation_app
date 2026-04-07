class DeathReportModel {
  final int daysQuarantined;
  final String dateOfDeath;
  final String pmDetails;
  final String lfaTestKitNo;
  final String result; // Positive / Negative
  final bool sampleCollected;
  final String sampleSentTo;

  DeathReportModel({
    required this.daysQuarantined,
    required this.dateOfDeath,
    required this.pmDetails,
    required this.lfaTestKitNo,
    required this.result,
    required this.sampleCollected,
    required this.sampleSentTo,
  });

  factory DeathReportModel.fromJson(Map<String, dynamic> json) {
    return DeathReportModel(
      daysQuarantined: json['daysQuarantined'] as int,
      dateOfDeath: json['dateOfDeath'] as String,
      pmDetails: json['pmDetails'] as String,
      lfaTestKitNo: json['lfaTestKitNo'] as String,
      result: json['result'] as String,
      sampleCollected: json['sampleCollected'] as bool,
      sampleSentTo: json['sampleSentTo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daysQuarantined': daysQuarantined,
      'dateOfDeath': dateOfDeath,
      'pmDetails': pmDetails,
      'lfaTestKitNo': lfaTestKitNo,
      'result': result,
      'sampleCollected': sampleCollected,
      'sampleSentTo': sampleSentTo,
    };
  }
}
