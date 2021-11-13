import 'package:csv/csv.dart';

class CsvRepository {
  String listToCsv(List<List<dynamic>> rows) {
    return const ListToCsvConverter().convert(rows);
  }

  List<List<dynamic>> csvToList(String csv) {
    return const CsvToListConverter().convert(csv);
  }
}
