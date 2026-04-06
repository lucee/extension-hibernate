<cfscript>
// DML delete with param
ormExecuteQuery( "DELETE FROM HqlEntity WHERE id = :id", { id: 999 } );
// should not throw even when no rows match
// verify existing rows unaffected
result = ormExecuteQuery( "FROM HqlEntity" );
if ( arrayLen( result ) != 5 )
	throw( message="dml delete: expected 5 remaining rows, got #arrayLen( result )#" );
echo( "ok" );
</cfscript>
