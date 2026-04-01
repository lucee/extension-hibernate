component {

	public string function getTableName( required string tableName ) {
		return "tbl_" & lCase( arguments.tableName );
	}

	public string function getColumnName( required string columnName ) {
		return "col_" & lCase( arguments.columnName );
	}

}
