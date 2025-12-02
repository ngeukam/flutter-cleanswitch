import 'package:intl/intl.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final String? notes;
  final DateTime dueDate;
  final double? duration;
  final String status;
  final String priority;
  final String? propertyName;
  final double? latitude;
  final double? longitude;
  final List<TaskGalleryImage> images;
  final List<AssignedUser>? assignedTo;
  final List<Apartment>? apartmentsAssigned;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.duration,
    required this.status,
    required this.priority,
    this.propertyName,
    this.notes,
    this.latitude,
    this.longitude,
    required this.images,
    this.assignedTo,
    this.apartmentsAssigned,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      notes: json['notes']?.toString(),
      dueDate: DateTime.parse(json['due_date']),
      duration: json['duration'] != null
          ? double.tryParse(json['duration'].toString())
          : null,
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      propertyName: json['property_assigned_name']?.toString(),
      latitude: json['property_info'] != null
          ? double.tryParse(json['property_info']['latitude'].toString())
          : null,
      longitude: json['property_info'] != null
          ? double.tryParse(json['property_info']['longitude'].toString())
          : null,
      images: (json['gallery_images'] as List?)
          ?.map((img) => TaskGalleryImage.fromJson(img))
          .toList() ?? [],
      assignedTo: (json['users_info'] as List?)
          ?.map((user) => AssignedUser.fromJson(user))
          .toList(),
      apartmentsAssigned: (json['apartments_info'] as List?)
          ?.map((apt) => Apartment.fromJson(apt))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'notes': notes,
      'due_date': dueDate.toIso8601String(),
      'duration': duration,
      'status': status,
      'priority': priority,
      'latitude': latitude,
      'longitude': longitude,
      'gallery_images': images.map((img) => img.toJson()).toList(),
      'apartments_assigned': apartmentsAssigned?.map((apt) => apt.toJson()).toList(),
    };
  }

  String get formattedDueDate {
    return DateFormat('MMM dd, yyyy – hh:mm a').format(dueDate);
  }

  String get apartmentNames {
    if (apartmentsAssigned == null || apartmentsAssigned!.isEmpty) {
      return 'No apartments assigned';
    }
    return apartmentsAssigned!.map((apt) => apt.displayName).join(', ');
  }
}

class AssignedUser {
  final String id;
  final String username;
  final String firstName;
  final String lastName;

  AssignedUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) {
    return AssignedUser(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
    );
  }
}

class TaskGalleryImage {
  final String image;
  final int order;

  TaskGalleryImage({required this.image, required this.order});

  factory TaskGalleryImage.fromJson(Map<String, dynamic> json) {
    return TaskGalleryImage(
      image: json['image'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'order': order,
    };
  }
}

class Apartment {
  final int id;
  final int? number;
  final String? name;
  final int? propertyAssigned;
  final int? capacity;
  final int? numberOfBeds;
  final String apartmentType;
  final bool inService;
  final bool cleaned;

  Apartment({
    required this.id,
    required this.number,
    this.name,
    this.propertyAssigned,
    this.capacity,
    this.numberOfBeds,
    required this.apartmentType,
    required this.inService,
    required this.cleaned,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['id'] as int,
      number: json['number'] != null ? int.tryParse(json['number'].toString()) : null,
      name: json['name']?.toString(),
      propertyAssigned: json['property_assigned'] as int?,
      capacity: json['capacity'] != null ? json['capacity'] as int? : null,
      numberOfBeds: json['numberOfBeds'] != null ? json['numberOfBeds'] as int? : null,
      apartmentType: json['apartmentType'] ?? 'normal',
      inService: json['inService'] ?? false,
      cleaned: json['cleaned'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'property_assigned': propertyAssigned,
      'capacity': capacity,
      'numberOfBeds': numberOfBeds,
      'apartmentType': apartmentType,
      'inService': inService,
      'cleaned': cleaned
    };
  }

  String get displayName {
    if (name != null && name!.isNotEmpty) {
      return '$number - $name';
    }
    return 'Apartment $number';
  }

  String get typeDisplayName {
    switch (apartmentType) {
      case 'king':
        return 'King';
      case 'luxury':
        return 'Luxury';
      case 'normal':
        return 'Normal';
      case 'economic':
        return 'Economic';
      default:
        return apartmentType;
    }
  }

  String get statusText {
    if (!inService) return 'Out of Service';
    return cleaned ? 'Clean' : 'Needs Cleaning';
  }

  @override
  String toString() {
    return displayName;
  }
}