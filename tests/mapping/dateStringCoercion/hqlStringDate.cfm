<cfscript>
// Probe: HQL named-parameter binding accepts a String for a Date column.
// On H5 the parameter coercion path went through Hibernate's JavaTypeRegistry
// which let strings pass via Lucee's autocoercion. On H7 strict typing in
// JdbcDateJavaType.wrap throws on String input — fix path likely in the
// extension's HQL parameter binding (where Lucee hands the param struct off
// to Hibernate) wherever String→Date coercion previously happened implicitly.
seed = entityNew( "User" );
seed.setId( createUUID() );
seed.setUserName( "Bob" );
seed.setLastLogin( createDate( 2012, 1, 1 ) );
entitySave( seed );
ormFlush();
ormClearSession();

result = ormExecuteQuery(
	"FROM User WHERE lastLogin = :p",
	{ p: "01/01/2012" }
);
if ( !isArray( result ) )
	throw( message="ormExecuteQuery: expected array, got [#serializeJSON( result )#]" );
if ( arrayLen( result ) != 1 )
	throw( message="ormExecuteQuery: expected 1 match for HQL date string '01/01/2012', got [#arrayLen( result )#]" );
if ( result[ 1 ].getUserName() != "Bob" )
	throw( message="ormExecuteQuery: expected user [Bob], got [#result[ 1 ].getUserName()#]" );

echo( "ok" );
</cfscript>
