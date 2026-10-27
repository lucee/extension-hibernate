<cfscript>
// Verify ORMGetSession() returns Hibernate's Session. The runtime class is a
// proxy (jdk.proxy*.$ProxyN) once the H7-compat shim is wrapping the real
// session, so check via the declared interfaces instead of the class name —
// same approach as the factory check below.
ormSess = ORMGetSession();
sessInterfaces = arrayMap( ormSess.getClass().getInterfaces(), function( iface ) { return iface.getName(); } );
if ( !arrayContainsNoCase( sessInterfaces, "org.hibernate.Session" )
	&& !arrayContainsNoCase( sessInterfaces, "org.hibernate.engine.spi.SessionImplementor" ) )
	throw( message="expected ormSess to implement org.hibernate.Session(Implementor), got interfaces #serializeJSON( sessInterfaces )#" );

// Verify ormSess.isOpen()
if ( !ormSess.isOpen() )
	throw( message="ormSess should be open" );

// Verify ORMGetSessionFactory returns Hibernate's SessionFactory. The runtime
// class is a proxy (jdk.proxy*.$ProxyN) once the H7-compat shim is wrapping the
// real factory, so check via the declared interfaces instead of the class name.
factory = ORMGetSessionFactory();
factoryInterfaces = arrayMap( factory.getClass().getInterfaces(), function( iface ) { return iface.getName(); } );
if ( !arrayContainsNoCase( factoryInterfaces, "org.hibernate.SessionFactory" )
	&& !arrayContainsNoCase( factoryInterfaces, "org.hibernate.engine.spi.SessionFactoryImplementor" ) )
	throw( message="expected factory to implement org.hibernate.SessionFactory(Implementor), got interfaces #serializeJSON( factoryInterfaces )#" );

// Hibernate 7 removed SessionFactory.getClassMetadata(name); replacement is the
// MappingMetamodel via the SessionFactoryImplementor cast.
descriptor = factory.getMappingMetamodel().findEntityDescriptor( "SmokeEntity" );
if ( isNull( descriptor ) )
	throw( message="findEntityDescriptor should return metadata for SmokeEntity" );

// Verify we can get property names from the entity descriptor
propNames = descriptor.getPropertyNames();
if ( !isArray( propNames ) || arrayLen( propNames ) == 0 )
	throw( message="expected property names array" );

echo( "ok" );
</cfscript>
