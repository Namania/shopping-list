/// "hello world" → "Hello world"
String capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
