class MyResponse {
  int statusCode = 0;
  var content;
  var auxContent = {};

  MyResponse.fromContent(this.statusCode, this.content);

  // Constructor dummy
  MyResponse();

  @override
  String toString() {
    return 'MyResponse{statusCode: $statusCode, content: $content, auxContent: $auxContent}';
  }
}
