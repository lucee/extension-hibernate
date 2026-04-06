<cfscript>
// DML update with typed params — exercises executeUpdate() path
affected = ormExecuteQuery( "UPDATE HqlEntity SET name = :name WHERE id = :id", { name: "updated", id: 1 } );
ormFlush();
ormClearSession();
entity = entityLoadByPK( "HqlEntity", 1 );
if ( entity.getName() != "updated" )
	throw( message="dml update: expected updated, got #entity.getName()#" );
echo( "ok" );
</cfscript>
