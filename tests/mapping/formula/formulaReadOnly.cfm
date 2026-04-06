<cfscript>
// Verify formula property is read-only — setting it shouldn't persist
id = createUUID();
item = entityNew( "OrderItem", { id: id, quantity: 2, price: 10.00 } );
entitySave( item );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "OrderItem", id );
// total should be 20.00 from formula
origTotal = loaded.getTotal();

// try to override the computed value
loaded.setTotal( 999 );
ormFlush();
ormClearSession();

reloaded = entityLoadByPK( "OrderItem", id );
// total should still be computed from quantity * price, not 999
if ( reloaded.getTotal() != origTotal )
	throw( message="formula should be read-only: expected #origTotal#, got #reloaded.getTotal()#" );

echo( "ok" );
</cfscript>
