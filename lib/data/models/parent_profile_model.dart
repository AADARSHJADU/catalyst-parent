/// Model representing the parent profile from the API.
class ParentProfileModel {
  const ParentProfileModel({
    required this.id,
    required this.user,
    this.relationshipId,
    this.languageId,
    this.dateOfBirth,
    this.address1,
    this.city,
    this.state,
    this.zip,
    this.emergencyContact,
    this.preferredContactMethod,
    this.notes,
    this.notifyBookingRequests = true,
    this.notifyScheduleChanges = true,
    this.notifyAttendanceAlerts = false,
    this.notifyStudioUpdates = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.pushNotifications = true,
  });

  final int id;
  final ParentUser user;
  final int? relationshipId;
  final int? languageId;
  final String? dateOfBirth;
  final String? address1;
  final String? city;
  final String? state;
  final String? zip;
  final String? emergencyContact;
  final String? preferredContactMethod;
  final String? notes;
  final bool notifyBookingRequests;
  final bool notifyScheduleChanges;
  final bool notifyAttendanceAlerts;
  final bool notifyStudioUpdates;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;

  factory ParentProfileModel.fromJson(Map<String, dynamic> json) {
    return ParentProfileModel(
      id: json['id'] as int,
      user: ParentUser.fromJson(json['user'] as Map<String, dynamic>),
      relationshipId: json['relationshipId'] as int?,
      languageId: json['languageId'] as int?,
      dateOfBirth: json['dateOfBirth'] as String?,
      address1: json['address1'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zip: json['zip'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      preferredContactMethod: json['preferredContactMethod'] as String?,
      notes: json['notes'] as String?,
      notifyBookingRequests: json['notifyBookingRequests'] as bool? ?? true,
      notifyScheduleChanges: json['notifyScheduleChanges'] as bool? ?? true,
      notifyAttendanceAlerts: json['notifyAttendanceAlerts'] as bool? ?? false,
      notifyStudioUpdates: json['notifyStudioUpdates'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? false,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
    );
  }

  ParentProfileModel copyWith({
    int? id,
    ParentUser? user,
    int? relationshipId,
    int? languageId,
    String? dateOfBirth,
    String? address1,
    String? city,
    String? state,
    String? zip,
    String? emergencyContact,
    String? preferredContactMethod,
    String? notes,
    bool? notifyBookingRequests,
    bool? notifyScheduleChanges,
    bool? notifyAttendanceAlerts,
    bool? notifyStudioUpdates,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
  }) {
    return ParentProfileModel(
      id: id ?? this.id,
      user: user ?? this.user,
      relationshipId: relationshipId ?? this.relationshipId,
      languageId: languageId ?? this.languageId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address1: address1 ?? this.address1,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      preferredContactMethod: preferredContactMethod ?? this.preferredContactMethod,
      notes: notes ?? this.notes,
      notifyBookingRequests: notifyBookingRequests ?? this.notifyBookingRequests,
      notifyScheduleChanges: notifyScheduleChanges ?? this.notifyScheduleChanges,
      notifyAttendanceAlerts: notifyAttendanceAlerts ?? this.notifyAttendanceAlerts,
      notifyStudioUpdates: notifyStudioUpdates ?? this.notifyStudioUpdates,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}

class ParentUser {
  const ParentUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.profilePic,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profilePic;

  String get fullName => '$firstName $lastName';

  factory ParentUser.fromJson(Map<String, dynamic> json) {
    return ParentUser(
      id: json['id'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      profilePic: json['profilePic'] as String?,
    );
  }
}

/// Simple id/name pair for relationships and languages.
class LookupItem {
  const LookupItem({required this.id, required this.name, this.code});

  final int id;
  final String name;
  final String? code;

  factory LookupItem.fromJson(Map<String, dynamic> json) {
    return LookupItem(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
    );
  }
}
