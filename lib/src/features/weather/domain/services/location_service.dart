import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/log_service.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('位置服务未启用');
    }

    // 检查位置权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('位置权限被拒绝');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('位置权限被永久拒绝');
    }

    // 获取当前位置，增加精度设置和更长的超时时间
    return await Geolocator.getCurrentPosition(
      timeLimit: Duration(seconds: 10),
    );
  }

  // 使用Nominatim API进行反向地理编码，获取城市名称
  Future<String> _getCityName(double lat, double lon) async {
    int retryCount = 0;
    const maxRetries = 2;
    const timeoutSeconds = 10;
    
    while (retryCount <= maxRetries) {
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&accept-language=zh-CN'
        );
        
        // 调试日志：开始获取城市名称
        log.debug('LocationService: 开始获取城市名称，尝试第 ${retryCount + 1} 次, URL: $url');

        final response = await http.get(url, headers: {
          'User-Agent': 'LifeFit/1.0',
        }).timeout(Duration(seconds: timeoutSeconds));
        
        // 调试日志，显示 response 的原始内容
        log.debug('LocationService: 获取城市名称响应: ${response.body}');


        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final address = data['address'] as Map<String, dynamic>;
          
          // 尝试多种地址字段，确保能获取到有意义的位置信息
          if (address.containsKey('city')) {
            return address['city'] as String;
          } else if (address.containsKey('town')) {
            return address['town'] as String;
          } else if (address.containsKey('village')) {
            return address['village'] as String;
          } else if (address.containsKey('county')) {
            return address['county'] as String;
          } else if (address.containsKey('state')) {
            return address['state'] as String;
          } else if (address.containsKey('country')) {
            return address['country'] as String;
          } else {
            // 如果没有找到任何地址字段，显示当前位置
            return '当前位置';
          }
        } else {
          // API请求失败，显示当前位置
          return '当前位置';
        }
      } catch (e) {
        retryCount++;
        if (retryCount <= maxRetries) {
          // 等待后重试
          await Future.delayed(Duration(seconds: 2 * retryCount));
          continue;
        }
        // 网络请求失败，显示当前位置
        return '当前位置';
      }
    }
    // 理论上不会到达这里
    return '当前位置';
  }

  Future<(double, double, String)> getLocationData() async {
    try {
      // 检查位置权限
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // 权限被拒绝，尝试请求权限
        if (permission == LocationPermission.denied) {
          final newPermission = await Geolocator.requestPermission();
          if (newPermission == LocationPermission.denied || newPermission == LocationPermission.deniedForever) {
            // 请求权限失败，抛出异常让上层处理
            throw Exception('位置权限被拒绝');
          }
        } else {
          // 永久拒绝，抛出异常让上层处理
          throw Exception('位置权限被永久拒绝');
        }
      }
      
      // 检查位置服务是否启用
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // 位置服务未启用，抛出异常让上层处理
        throw Exception('位置服务未启用');
      }
      
      // 获取当前位置
      final position = await getCurrentPosition();
      
      // 获取真实城市名称
      final cityName = await _getCityName(position.latitude, position.longitude);
      return (position.latitude, position.longitude, cityName);
    } catch (e) {
      // 重新抛出异常，让上层知道获取位置失败
      rethrow;
    }
  }

  Future<bool> checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
