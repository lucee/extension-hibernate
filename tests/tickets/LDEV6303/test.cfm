<cfscript>
	ormReload();
	queryExecute( "insert into ldev6303_expr_default ( id, literal, expr, exprNumber ) values ( 1, null, null, null )" );
	queryExecute( "insert into ldev6303_expr_default ( id, literal, expr, exprNumber ) values ( 2, 'a', 'b', 7 )" );
	ormClearSession();

	nullRow = entityLoadByPK( "ExprDefault", 1 );
	valueRow = entityLoadByPK( "ExprDefault", 2 );
	echo( serializeJSON( {
		"nullLiteral": nullRow.getLiteral() ?: "<null>",
		"nullExpr": nullRow.getExpr() ?: "<null>",
		"nullExprNumber": nullRow.getExprNumber() ?: "<null>",
		"valueLiteral": valueRow.getLiteral() ?: "<null>",
		"valueExpr": valueRow.getExpr() ?: "<null>",
		"valueExprNumber": valueRow.getExprNumber() ?: "<null>"
	} ) );
</cfscript>
