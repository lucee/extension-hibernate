<cfscript>
// Probe: entityLoad("User", { lastLogin: "01/01/2009" }) — filter-struct path.
// On H5 the extension/Hibernate JdbcDateJavaType.wrap silently coerced the
// String to java.sql.Date via Lucee's autocast. On H7 JdbcDateJavaType.wrap
// rejects String outright with "Could not convert 'java.lang.String' to
// 'java.sql.Date' ... argument [...] is not assignable to java.util.Date".
//
// Test corpus pre-this binds dates as createDate()/now() Java types only —
// real-world apps (cborm dynamic finders, ColdBox controllers) routinely
// pass user-typed CFML date strings.
seed = entityNew( "User" );
seed.setId( createUUID() );
seed.setUserName( "Alice" );
seed.setLastLogin( createDate( 2009, 1, 1 ) );
entitySave( seed );
ormFlush();
ormClearSession();

// Filter-struct form — Hibernate builds a Criteria-equivalent and binds
// lastLogin as a parameter. The String "01/01/2009" must coerce to a date.
result = entityLoad( "User", { lastLogin: "01/01/2009" } );
if ( !isArray( result ) )
	throw( message="entityLoad: expected array, got [#serializeJSON( result )#]" );
if ( arrayLen( result ) != 1 )
	throw( message="entityLoad: expected 1 match for date string '01/01/2009', got [#arrayLen( result )#]" );
if ( result[ 1 ].getUserName() != "Alice" )
	throw( message="entityLoad: expected user [Alice], got [#result[ 1 ].getUserName()#]" );

echo( "ok" );
</cfscript>
