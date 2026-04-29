<cfscript>
// Locks down the H5.6 EntityPersister int-index property name lookup that
// real-world CFML code (cborm BaseORMService.getDirtyPropertyNames,
// basecfc, ColdMVC) depends on. The cborm flow is:
//
//   var modified = persister.findModified( dbState, currentState, entity, session ); // int[]
//   return arrayMap( modified, function( i ){ return persister.getSubclassPropertyName( i ); } );
//
// On 5.6 getSubclassPropertyName(int) is a real method on
// SingleTableEntityPersister. On 7.0+ that int overload is gone — only the
// String overload survives. Same test must pass on both branches once the
// extension-side persister shim re-exposes the int form.
sf = ORMGetSessionFactory();
md = sf.getClassMetadata( "SmokeEntity" );
if ( isNull( md ) )
	throw( message="getClassMetadata: returned null for SmokeEntity" );

// getPropertyNames returns the entity's own (non-id) properties.
propNames = md.getPropertyNames();
if ( !isArray( propNames ) || arrayLen( propNames ) == 0 )
	throw( message="getPropertyNames: expected non-empty array, got [#serializeJSON( propNames )#]" );

// Walk every index Hibernate exposes via getSubclassPropertyName(int).
// For a flat entity (no inheritance) the subclass property table mirrors
// getPropertyNames(). The probe asserts both: (a) the int overload exists
// and dispatches; (b) every index resolves to a non-empty String.
for ( i = 0; i < arrayLen( propNames ); i++ ) {
	name = md.getSubclassPropertyName( javaCast( "int", i ) );
	if ( isNull( name ) || !isSimpleValue( name ) || len( name ) == 0 )
		throw( message="getSubclassPropertyName(#i#): expected non-empty String, got [#serializeJSON( name )#]" );
	// CFML 1-indexed vs Java 0-indexed — propNames[ i+1 ] is the same slot.
	if ( name != propNames[ i + 1 ] )
		throw( message="getSubclassPropertyName(#i#): expected [#propNames[ i + 1 ]#], got [#name#]" );
}

echo( "ok" );
</cfscript>
