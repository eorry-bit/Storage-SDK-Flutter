part of leancloud_storage;

class LCHttpClient {
  String appKey;

  Dio _dio;
  
  LCHttpClient(String appId, this.appKey, String server, String version) {
    BaseOptions options = new BaseOptions(
      baseUrl: '$server/$version/', 
      headers: {
        'X-LC-Id': appId,
        'Content-Type': ContentType.parse('application/json')
      });
    _dio = new Dio(options);
    _dio.interceptors.add(new LogInterceptor(requestBody: true, responseBody: true));
  }

  Future get(String path, { Map<String, dynamic> headers, Map<String, dynamic> queryParams }) async {
    Options options = _toOptions(headers);
    Response response = await _dio.get(path, options: options, queryParameters: queryParams);
    _filterError(response);
    return response.data;
  }

  Future post(String path, { Map<String, dynamic> headers, dynamic data, Map<String, dynamic> queryParams }) async {
    Options options = _toOptions(headers);
    Response response = await _dio.post(path, options: options, data: data, queryParameters: queryParams);
    _filterError(response);
    return response.data;
  }

  Future put(String path, { Map<String, dynamic> headers, dynamic data, Map<String, dynamic> queryParams }) async {
    Options options = _toOptions(headers);
    Response response = await _dio.put(path, options: options, data: data, queryParameters: queryParams);
    _filterError(response);
    return response.data;
  }

  Future delete(String path, { Map<String, dynamic> headers, dynamic data, Map<String, dynamic> queryParams }) async {
    Options options = _toOptions(headers);
    Response response = await _dio.delete(path, options: options, data: data, queryParameters: queryParams);
    _filterError(response);
    return response.data;
  }

  Options _toOptions(Map<String, dynamic> headers) {    
    if (headers == null) {
      headers = new Map<String, dynamic>();
    }
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    Uint8List data = Utf8Encoder().convert('$timestamp$appKey');
    Digest digest = md5.convert(data);
    String sign = hex.encode(digest.bytes);
    headers['X-LC-Sign'] = '$sign,$timestamp';
    return new Options(headers: headers);
  }

  void _filterError(Response response) {
    int code = response.statusCode ~/ 100;
    if (code == 2) {
      return;
    }
    if (code == 4) {
      int code = response.data['code'];
      String message = response.data['error'];
      throw new LCError(code, message);
    }
    throw new LCError(response.statusCode, response.statusMessage);
  }
}
