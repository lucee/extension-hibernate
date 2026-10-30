<cfscript>
// Probe resolving the open question in h73-session-shim-spec.md: does Lucee's
// reflection-based CFC method dispatch silently pick H7's `get(...,Object)`
// overload when CFML calls `session.get(name, id)`?
//
// H5 had `get(Class,Serializable)` / `get(String,Serializable)`. H7 swapped those
// for `Object` overloads. Method name is identical; arg type widened. If Lucee
// dispatch resolves by name+arity, no shim needed for the 6 get(...) overloads.
//
// Outcome (verified 2026-04-29):
//   - get(String entityName, Object id): works. Lucee dispatch picks H7's
//     get(String,Object) silently. NO SHIM NEEDED.
//   - get(Class entityClass, Object id): throws UnknownEntityTypeException with
//     'lucee.runtime.Component'. This is a CFML dynamic-map-mode quirk, not an
//     H5→H7 shim concern. ep.getMappedClass() returns the generic Component base
//     class which Hibernate doesn't know as an entity. Same behaviour on H5.
//     Out of scope for the shim.

w = entityNew( "Widget", { name: "probe" } );
entitySave( w );
ormFlush();
id = w.getId();

sess = ormGetSession();

// 1) get(String entityName, Object id) — expect Lucee dispatch to find it.
loaded = sess.get( "Widget", id );
if ( isNull( loaded ) )
	throw( message="get(String,Object): returned null for known id [#id#]" );
if ( loaded.getName() != "probe" )
	throw( message="get(String,Object): wrong entity returned, name=[#loaded.getName()#]" );

// 2) get(Class entityClass, Object id) — expect UnknownEntityTypeException
//    (broken on H5 too, dynamic-map-mode quirk, not a shim concern).
sf = ormGetSessionFactory();
ep = sf.getClassMetadata( "Widget" );
widgetClass = ep.getMappedClass();
classFormThrew = false;
classErrMsg = "";
try {
	sess.get( widgetClass, id );
} catch ( any e ) {
	classFormThrew = true;
	classErrMsg = e.message;
}
if ( !classFormThrew )
	throw( message="get(Class,Object) unexpectedly succeeded — dynamic-map-mode behaviour changed?" );
if ( !findNoCase( "Unknown entity", classErrMsg ) && !findNoCase( "lucee.runtime.Component", classErrMsg ) )
	throw( message="get(Class,Object): expected UnknownEntityTypeException, got [#classErrMsg#]" );

systemOutput( "ok — get(String,Object) resolves automatically; get(Class,Object) is dynamic-map-mode-broken (not a shim concern). No shim needed for the get family.", true );
</cfscript>
