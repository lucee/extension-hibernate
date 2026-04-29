<cfscript>
// Locks down the H5.6 contract that session.getEntityName( transient ) throws
// org.hibernate.TransientObjectException — NOT IllegalArgumentException.
// ColdBox's ObjectPopulator.getTargetName depends on this exact exception
// type to short-circuit transient detection:
//
//   try {
//     return ormGetSession().getEntityName( arguments.target );
//   } catch ( org.hibernate.TransientObjectException e ) {
//     // fall through to getMetadata( target ).name
//   }
//
// (cborm test-harness/coldbox/system/core/dynamic/ObjectPopulator.cfc#L655)
//
// On H5 the throw site is EntityIdentifierMapping.java#L116 — message format
// "object references an unsaved transient instance of '<entity>'". TYPE:
// org.hibernate.TransientObjectException.
//
// On H7 the same call throws java.lang.IllegalArgumentException ("Given
// entity is not associated with the persistence context") from
// SessionImpl.getEntityEntry → SessionImpl.getEntityName(Object) at
// SessionImpl.java#L1798. The typed catch above no longer matches, the
// exception propagates, and ColdBox surfaces it as "Error populating bean".
//
// Same test must pass on both branches once the extension-side compat session
// wrapper catches IAE from getEntityName and rethrows as
// TransientObjectException to preserve the H5 cborm/ColdBox/basecfc contract.
e = entityNew( "SmokeEntity" );
e.setId( createUUID() );
e.setName( "Transient" );

ormSess = ormGetSession();
threwTransient = false;
otherErr = "";
try {
	ormSess.getEntityName( e );
} catch ( org.hibernate.TransientObjectException toe ) {
	threwTransient = true;
} catch ( any other ) {
	otherErr = "type=[#other.type#] message=[#other.message#]";
}

if ( !threwTransient )
	throw( message="getEntityName(transient): expected org.hibernate.TransientObjectException, got [#otherErr#]" );

echo( "ok" );
</cfscript>
