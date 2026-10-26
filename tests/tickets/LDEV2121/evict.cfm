<cfscript>
	include "setup.cfm";
	// populate the second level cache
	entityLoadByPK( "Composite", { k1: 1, k2: "a" } );
	entityLoadByPK( "Composite", { k1: 1, k2: "b" } );
	ormClearSession();

	cache = ormGetSessionFactory().getCache();
	result = {};
	result.beforeA = cache.containsEntity( "Composite", cacheId( 1, "a" ) );
	result.beforeB = cache.containsEntity( "Composite", cacheId( 1, "b" ) );

	ormEvictEntity( "Composite", { k1: 1, k2: "a" } );

	result.afterA = cache.containsEntity( "Composite", cacheId( 1, "a" ) );
	result.afterB = cache.containsEntity( "Composite", cacheId( 1, "b" ) );
	echo( serializeJSON( result ) );

	function cacheId( numeric k1, string k2 ) {
		var id = createObject( "java", "java.util.HashMap" ).init();
		id.put( "k1", javacast( "int", arguments.k1 ) );
		id.put( "k2", arguments.k2 );
		return id;
	}
</cfscript>
