<cfscript>
id = createUUID();
item = entityNew( "OrderItem", { id: id, quantity: 3, price: 9.99 } );
entitySave( item );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "OrderItem", id );
total = loaded.getTotal();
// use tolerance for floating-point comparison (big_decimal * integer)
if ( abs( total - 29.97 ) > 0.001 )
	throw( message="expected total ~29.97, got #total#" );

// verify no 'total' column in DB
cols = queryExecute(
	"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'F_ORDERITEM' AND COLUMN_NAME = 'TOTAL'"
);
if ( cols.recordCount != 0 )
	throw( message="formula property should NOT create a DB column" );

echo( "ok" );
</cfscript>
