// Minimal pure-Dart .xlsx writer. An .xlsx is a ZIP of a few XML parts; we write
// the ZIP by hand with STORED (uncompressed) entries — no `archive`/`excel`
// package, no compression needed, and Excel/Sheets open it natively.
//
// Scope: text + number cells, one or more sheets, no styling/shared-strings.
// That's all a readable export needs. Add styles.xml if formatted cells matter.
import 'dart:convert';
import 'dart:typed_data';

class XlsxSheet {
  final String name;
  // Rows of cells; each cell is a String (text), num (numeric), Money (currency),
  // or null (blank). Row 0 is styled as a bold header.
  final List<List<Object?>> rows;
  XlsxSheet(this.name, this.rows);
}

// Wrap a numeric cell in Money to render it with the "#,##0 TMT" number format.
class Money {
  final num value;
  const Money(this.value);
}

Uint8List buildXlsx(List<XlsxSheet> sheets) {
  final parts = <MapEntry<String, List<int>>>[
    MapEntry('[Content_Types].xml', utf8.encode(_contentTypes(sheets.length))),
    MapEntry('_rels/.rels', utf8.encode(_rootRels)),
    MapEntry('xl/workbook.xml', utf8.encode(_workbook(sheets))),
    MapEntry('xl/_rels/workbook.xml.rels', utf8.encode(_workbookRels(sheets.length))),
    MapEntry('xl/styles.xml', utf8.encode(_styles)),
    for (var i = 0; i < sheets.length; i++)
      MapEntry('xl/worksheets/sheet${i + 1}.xml', utf8.encode(_sheetXml(sheets[i]))),
  ];
  return _zip(parts);
}

// ---- XML parts ----

const _rootRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
    '</Relationships>';

// Style bank: cellXfs index 0 = default, 1 = bold (header), 2 = "#,##0 TMT".
// numFmtId 164 is the first free id for custom formats. Two fills (none +
// gray125) and the Normal cellStyle are what Excel expects even when unused.
const _styles = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
    '<numFmts count="1"><numFmt numFmtId="164" formatCode="#,##0&quot; TMT&quot;"/></numFmts>'
    '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font>'
    '<font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'
    '<fills count="2"><fill><patternFill patternType="none"/></fill>'
    '<fill><patternFill patternType="gray125"/></fill></fills>'
    '<borders count="1"><border/></borders>'
    '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
    '<cellXfs count="3">'
    '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
    '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
    '<xf numFmtId="164" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>'
    '</cellXfs>'
    '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
    '</styleSheet>';

String _contentTypes(int n) {
  final sb = StringBuffer(
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
      '<Default Extension="xml" ContentType="application/xml"/>'
      '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
      '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>');
  for (var i = 1; i <= n; i++) {
    sb.write('<Override PartName="/xl/worksheets/sheet$i.xml" '
        'ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>');
  }
  sb.write('</Types>');
  return sb.toString();
}

String _workbook(List<XlsxSheet> sheets) {
  final sb = StringBuffer(
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets>');
  for (var i = 0; i < sheets.length; i++) {
    sb.write('<sheet name="${_esc(sheets[i].name)}" sheetId="${i + 1}" r:id="rId${i + 1}"/>');
  }
  sb.write('</sheets></workbook>');
  return sb.toString();
}

String _workbookRels(int n) {
  final sb = StringBuffer(
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">');
  for (var i = 1; i <= n; i++) {
    sb.write('<Relationship Id="rId$i" '
        'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" '
        'Target="worksheets/sheet$i.xml"/>');
  }
  sb.write('<Relationship Id="rId${n + 1}" '
      'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" '
      'Target="styles.xml"/>');
  sb.write('</Relationships>');
  return sb.toString();
}

String _sheetXml(XlsxSheet sheet) {
  final sb = StringBuffer(
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>');
  for (var r = 0; r < sheet.rows.length; r++) {
    final row = sheet.rows[r];
    sb.write('<row r="${r + 1}">');
    for (var col = 0; col < row.length; col++) {
      sb.write(_cell('${_colName(col)}${r + 1}', row[col], header: r == 0));
    }
    sb.write('</row>');
  }
  sb.write('</sheetData></worksheet>');
  return sb.toString();
}

// Style index: header row -> 1 (bold), Money -> 2 ("#,##0 TMT"), else 0.
String _cell(String ref, Object? v, {bool header = false}) {
  final style = header ? 1 : (v is Money ? 2 : 0);
  final s = style != 0 ? ' s="$style"' : '';
  if (v == null || (v is String && v.isEmpty)) {
    return header ? '<c r="$ref"$s/>' : '';
  }
  if (v is Money) return '<c r="$ref"$s><v>${v.value}</v></c>';
  if (v is num) return '<c r="$ref"$s><v>$v</v></c>';
  return '<c r="$ref" t="inlineStr"$s><is><t xml:space="preserve">${_esc(v.toString())}</t></is></c>';
}

// 0-based column index -> spreadsheet column letters (0->A, 25->Z, 26->AA).
String _colName(int i) {
  var n = i;
  var s = '';
  do {
    s = String.fromCharCode(65 + n % 26) + s;
    n = n ~/ 26 - 1;
  } while (n >= 0);
  return s;
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

// ---- ZIP container (STORED entries) ----

Uint8List _zip(List<MapEntry<String, List<int>>> parts) {
  final out = <int>[];
  final central = <int>[];
  var offset = 0;
  for (final part in parts) {
    final name = utf8.encode(part.key);
    final data = part.value;
    final crc = _crc32(data);
    final local = <int>[];
    _u32(local, 0x04034b50);
    _u16(local, 20); // version needed
    _u16(local, 0); // flags
    _u16(local, 0); // method: 0 = stored
    _u16(local, 0); // mod time
    _u16(local, 0); // mod date
    _u32(local, crc);
    _u32(local, data.length);
    _u32(local, data.length);
    _u16(local, name.length);
    _u16(local, 0); // extra len
    local.addAll(name);
    local.addAll(data);

    _u32(central, 0x02014b50);
    _u16(central, 20); // version made by
    _u16(central, 20); // version needed
    _u16(central, 0); // flags
    _u16(central, 0); // method
    _u16(central, 0); // time
    _u16(central, 0); // date
    _u32(central, crc);
    _u32(central, data.length);
    _u32(central, data.length);
    _u16(central, name.length);
    _u16(central, 0); // extra
    _u16(central, 0); // comment
    _u16(central, 0); // disk start
    _u16(central, 0); // internal attrs
    _u32(central, 0); // external attrs
    _u32(central, offset);
    central.addAll(name);

    out.addAll(local);
    offset += local.length;
  }
  final centralOffset = offset;
  out.addAll(central);
  _u32(out, 0x06054b50); // EOCD
  _u16(out, 0); // disk
  _u16(out, 0); // central dir disk
  _u16(out, parts.length);
  _u16(out, parts.length);
  _u32(out, central.length);
  _u32(out, centralOffset);
  _u16(out, 0); // comment len
  return Uint8List.fromList(out);
}

void _u16(List<int> b, int v) {
  b.add(v & 0xff);
  b.add((v >> 8) & 0xff);
}

void _u32(List<int> b, int v) {
  b.add(v & 0xff);
  b.add((v >> 8) & 0xff);
  b.add((v >> 16) & 0xff);
  b.add((v >> 24) & 0xff);
}

int crc32(List<int> data) => _crc32(data); // exposed for the self-check

int _crc32(List<int> data) {
  var crc = 0xffffffff;
  for (final byte in data) {
    crc ^= byte;
    for (var k = 0; k < 8; k++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return crc ^ 0xffffffff;
}
