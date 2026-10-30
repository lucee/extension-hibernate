<cfscript>
// Same as index.cfm but for ormGetSessionFactory(). Forces ORM init by touching
// an entity, then dumps the SF reflection surface for diffing across versions.

entityNew( "Widget" );
sf = ormGetSessionFactory();

cls = sf.getClass();
sigs = {};

methods = cls.getMethods();
for ( m in methods ) {
	if ( m.getDeclaringClass().getName() == "java.lang.Object" ) continue;
	name = m.getName();
	params = [];
	for ( p in m.getParameterTypes() ) arrayAppend( params, p.getSimpleName() );
	sigs[ name & "(" & arrayToList( params, "," ) & ")" ] = true;
}

keys = structKeyArray( sigs );
arraySort( keys, "textnocase" );

systemOutput( "=== ormGetSessionFactory() class ===", true );
systemOutput( cls.getName(), true );

systemOutput( "", true );
systemOutput( "=== Implemented interfaces ===", true );
ifaces = [];
for ( i in cls.getInterfaces() ) arrayAppend( ifaces, i.getName() );
arraySort( ifaces, "textnocase" );
for ( i in ifaces ) systemOutput( i, true );

systemOutput( "", true );
systemOutput( "=== Methods (#arrayLen( keys )#) ===", true );
for ( k in keys ) systemOutput( k, true );
</cfscript>
