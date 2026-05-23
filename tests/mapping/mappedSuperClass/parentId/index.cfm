<cfscript>
// mappedSuperClass parent declares the id field; child inherits it.
p = entityNew( "Product" );
p.setId( createUUID() );
p.setName( "Mangoes" );
entitySave( p );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Product", p.getId() );
if ( isNull( loaded ) )
	throw( message="Product not loaded after save" );
if ( loaded.getName() != "Mangoes" )
	throw( message="expected name=Mangoes, got [#loaded.getName()#]" );
if ( loaded.getId() != p.getId() )
	throw( message="id from mappedSuperClass didn't round-trip" );

echo( "ok" );
</cfscript>
