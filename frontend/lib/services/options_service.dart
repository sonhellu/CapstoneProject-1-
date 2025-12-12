import 'api_service.dart';
import 'api_config.dart';

/// Options Service - For registration form dropdowns
class OptionsService {
  /// Get all schools
  static Future<List<Map<String, dynamic>>> getSchools() async {
    try {
      final response = await ApiService.get(
        ApiConfig.schoolsEndpoint,
        useCache: true, // Cache schools as they don't change often
      );
      // Handle both response formats: {schools: [...]} or direct array
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map && response.containsKey('schools')) {
        return List<Map<String, dynamic>>.from(response['schools'] ?? []);
      }
      return [];
    } catch (e) {
      return []; // Return empty list instead of throwing
    }
  }

  /// Get departments for a specific school
  static Future<List<Map<String, dynamic>>> getDepartments(int schoolId) async {
    try {
      final response = await ApiService.get(
        ApiConfig.departmentsEndpoint(schoolId),
        useCache: true,
      );
      // Handle both response formats: {departments: [...]} or direct array
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map && response.containsKey('departments')) {
        return List<Map<String, dynamic>>.from(response['departments'] ?? []);
      }
      return [];
    } catch (e) {
      return []; // Return empty list instead of throwing
    }
  }

  /// Get all languages
  static Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      final response = await ApiService.get(
        ApiConfig.languagesEndpoint,
        useCache: true, // Cache languages as they don't change often
      );
      // Handle both response formats: {languages: [...]} or direct array
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map && response.containsKey('languages')) {
        return List<Map<String, dynamic>>.from(response['languages'] ?? []);
      }
      return [];
    } catch (e) {
      return []; // Return empty list instead of throwing
    }
  }

  /// Get all countries
  static Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final response = await ApiService.get(
        ApiConfig.countriesEndpoint,
        useCache: true, // Cache countries as they don't change often
      );
      // Handle both response formats: {countries: [...]} or direct array
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else if (response is Map && response.containsKey('countries')) {
        return List<Map<String, dynamic>>.from(response['countries'] ?? []);
      }
      return [];
    } catch (e) {
      return []; // Return empty list instead of throwing
    }
  }

  /// Get colleges for a specific school
  static Future<List<Map<String, dynamic>>> getColleges(int schoolId) async {
    try {
      final response = await ApiService.get(
        ApiConfig.collegesEndpoint(schoolId),
        useCache: true,
      );
      return List<Map<String, dynamic>>.from(response['colleges'] ?? []);
    } catch (e) {
      throw Exception('Failed to load colleges: $e');
    }
  }
}

