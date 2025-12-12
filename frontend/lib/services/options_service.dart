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
      return List<Map<String, dynamic>>.from(response['schools'] ?? []);
    } catch (e) {
      throw Exception('Failed to load schools: $e');
    }
  }

  /// Get departments for a specific school
  static Future<List<Map<String, dynamic>>> getDepartments(int schoolId) async {
    try {
      final response = await ApiService.get(
        ApiConfig.departmentsEndpoint(schoolId),
        useCache: true,
      );
      return List<Map<String, dynamic>>.from(response['departments'] ?? []);
    } catch (e) {
      throw Exception('Failed to load departments: $e');
    }
  }

  /// Get all languages
  static Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      final response = await ApiService.get(
        ApiConfig.languagesEndpoint,
        useCache: true, // Cache languages as they don't change often
      );
      return List<Map<String, dynamic>>.from(response['languages'] ?? []);
    } catch (e) {
      throw Exception('Failed to load languages: $e');
    }
  }

  /// Get all countries
  static Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final response = await ApiService.get(
        ApiConfig.countriesEndpoint,
        useCache: true, // Cache countries as they don't change often
      );
      return List<Map<String, dynamic>>.from(response['countries'] ?? []);
    } catch (e) {
      throw Exception('Failed to load countries: $e');
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

