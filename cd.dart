import 'dart:io';

void main() {
  print('Hello,   fafa World!');
  File myFile = File('assets/page-1.html');
  myFile.copySync("page-1.html");
}
