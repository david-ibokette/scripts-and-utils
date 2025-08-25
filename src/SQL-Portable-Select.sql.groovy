/*
 * Available context bindings:
 *   COLUMNS     List<DataColumn>
 *   ROWS        Iterable<DataRow>
 *   OUT         { append() }
 *   FORMATTER   { format(row, col); formatValue(Object, col); getTypeName(Object, col); isStringLiteral(Object, col); }
 *   TRANSPOSED  Boolean
 * plus ALL_COLUMNS, TABLE, DIALECT
 *
 * where:
 *   DataRow     { rowNumber(); first(); last(); data(): List<Object>; value(column): Object }
 *   DataColumn  { columnNumber(), name() }
 */

SEP = ", "
QUOTE     = "\'"
STRING_PREFIX = DIALECT.getDbms().isMicrosoft() ? "N" : ""
NEWLINE   = System.getProperty("line.separator")

KEYWORDS_LOWERCASE = com.intellij.database.util.DbSqlUtil.areKeywordsLowerCase(PROJECT)
KW_NULL = KEYWORDS_LOWERCASE ? "null" : "NULL"
KW_SELECT = KEYWORDS_LOWERCASE ? "select " : "SELECT "
KW_FROM = KEYWORDS_LOWERCASE ? "  FROM(VALUES " : "  from(values "

begin = true

def record(columns, dataRow) {

    if (begin) {
        OUT.append(KW_SELECT)
        columns.eachWithIndex { column, idx ->
            OUT.append(column.name()).append(idx != columns.size() - 1 ? SEP : "")
        }
        OUT.append(NEWLINE)
        OUT.append(KW_FROM)
        OUT.append(NEWLINE)
    }
    else {
        OUT.append(",").append(NEWLINE)
    }
    OUT.append("        (")

    columns.eachWithIndex { column, idx ->
        def value = dataRow.value(column)
        def stringValue = value == null ? KW_NULL : FORMATTER.formatValue(value, column)
        def isStringLiteral = value != null && FORMATTER.isStringLiteral(value, column)
        if (isStringLiteral && DIALECT.getDbms().isMysql()) stringValue = stringValue.replace("\\", "\\\\")
        OUT.append(isStringLiteral ? (STRING_PREFIX + QUOTE) : "")
          .append(stringValue ? stringValue.replace(QUOTE, QUOTE + QUOTE) : stringValue)
          .append(isStringLiteral ? QUOTE : "")
          .append(idx != columns.size() - 1 ? SEP : "")
    }
    OUT.append(")")
}

def end(columns) {
    OUT.append(NEWLINE)
    OUT.append(") AS t(")
    columns.eachWithIndex { column1, idx1 ->
        OUT.append(column1.name()).append(idx1 != columns.size() - 1 ? SEP : "")
    }
    OUT.append(")")
}

ROWS.each { row -> record(COLUMNS, row) }
end(COLUMNS)
OUT.append(";")
