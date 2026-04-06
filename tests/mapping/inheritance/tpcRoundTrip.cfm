<cfscript>
// Table-per-concrete-class (union subclass): Circle gets its own table with all columns
circleId = createUUID();
circle = entityNew( "Circle", { id: circleId, color: "red", radius: 5.5 } );
entitySave( circle );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Shape", circleId );
if ( !isObject( loaded ) )
	throw( message="should load shape by PK" );
if ( getMetadata( loaded ).name does not contain "Circle" )
	throw( message="expected Circle type, got #getMetadata( loaded ).name#" );
if ( loaded.getColor() != "red" )
	throw( message="expected red, got #loaded.getColor()#" );
if ( loaded.getRadius() != 5.5 )
	throw( message="expected 5.5, got #loaded.getRadius()#" );

// verify TPC_Circle table has all columns (id, color, radius)
cols = queryExecute( "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TPC_CIRCLE' ORDER BY COLUMN_NAME" );
colList = valueList( cols.COLUMN_NAME ).lCase();
if ( colList does not contain "id" || colList does not contain "color" || colList does not contain "radius" )
	throw( message="TPC_Circle should have id, color, radius columns, got: #colList#" );

echo( "ok" );
</cfscript>
