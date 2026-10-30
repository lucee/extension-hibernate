<cfscript>
// Dump every public method reflection sees on the object returned by ormGetSession().
// Output is normalised so two runs (H5.6 vs H7.3) can be diffed.
//
// Format per line: methodName(paramTypeSimpleName, ...)
// Sorted alphabetically, deduplicated.

// Force a session to actually exist by touching ORM.
entityNew( "Widget" );
sess = ormGetSession();

cls = sess.getClass();
sigs = {};

methods = cls.getMethods();
for ( m in methods ) {
	declaring = m.getDeclaringClass().getName();
	// Skip Object.class noise — irrelevant to ORM API surface.
	if ( declaring == "java.lang.Object" ) continue;
	name = m.getName();
	params = [];
	for ( p in m.getParameterTypes() ) arrayAppend( params, p.getSimpleName() );
	sig = name & "(" & arrayToList( params, "," ) & ")";
	sigs[ sig ] = true;
}

keys = structKeyArray( sigs );
arraySort( keys, "textnocase" );

systemOutput( "=== ormGetSession() class ===", true );
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
