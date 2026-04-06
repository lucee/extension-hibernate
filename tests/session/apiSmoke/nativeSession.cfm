<cfscript>
// Verify ORMGetSession() returns native org.hibernate.Session (not a wrapper like ACF)
ormSess = ORMGetSession();
className = ormSess.getClass().getName();
if ( className does not contain "hibernate" )
	throw( message="expected hibernate ormSess class, got #className#" );

// Verify ormSess.isOpen()
if ( !ormSess.isOpen() )
	throw( message="ormSess should be open" );

// Verify ORMGetSessionFactory returns native factory
factory = ORMGetSessionFactory();
factoryClass = factory.getClass().getName();
if ( factoryClass does not contain "hibernate" )
	throw( message="expected hibernate factory class, got #factoryClass#" );

// Verify getClassMetadata works
md = factory.getClassMetadata( "SmokeEntity" );
if ( isNull( md ) )
	throw( message="getClassMetadata should return metadata for SmokeEntity" );

// Verify we can get property names from metadata
propNames = md.getPropertyNames();
if ( !isArray( propNames ) || arrayLen( propNames ) == 0 )
	throw( message="expected property names array" );

echo( "ok" );
</cfscript>
