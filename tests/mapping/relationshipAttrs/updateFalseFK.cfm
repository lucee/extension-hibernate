<cfscript>
// update=false on many-to-one FK — category can be set on insert but not changed
catA = entityNew( "RACategory", { id: createUUID(), name: "Cat A" } );
catB = entityNew( "RACategory", { id: createUUID(), name: "Cat B" } );
entitySave( catA );
entitySave( catB );

itemId = createUUID();
item = entityNew( "RAItem", { id: itemId, name: "Locked Item", category: catA } );
entitySave( item );
ormFlush();
ormClearSession();

// verify initial category
loaded = entityLoadByPK( "RAItem", itemId );
if ( loaded.getCategory().getName() != "Cat A" )
	throw( message="expected Cat A, got #loaded.getCategory().getName()#" );

// try to change category — with update=false, the FK column should not be updated
loaded.setCategory( entityLoadByPK( "RACategory", catB.getId() ) );
ormFlush();
ormClearSession();

// reload and check — should still be Cat A because update=false
reloaded = entityLoadByPK( "RAItem", itemId );
if ( reloaded.getCategory().getName() != "Cat A" )
	throw( message="update=false should prevent FK change. expected Cat A, got #reloaded.getCategory().getName()#" );

echo( "ok" );
</cfscript>
