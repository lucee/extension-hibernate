<cfscript>
// ormGetSession
session = ormGetSession();
if ( isNull( session ) || isSimpleValue( session ) ) throw( message="ormGetSession should return session object" );

// ormGetSessionFactory
factory = ormGetSessionFactory();
if ( !isObject( factory ) ) throw( message="ormGetSessionFactory should return object" );

// save something, then clear
auto = entityNew( "Auto", { make: "Toyota", id: createUUID() } );
entitySave( auto );
ormFlush();

// ormClearSession
ormClearSession();

// ormEvictEntity
ormEvictEntity( "Auto" );

// ormEvictQueries
ormEvictQueries();

echo( "ok" );
</cfscript>
