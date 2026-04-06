<cfscript>
// With dbcreate=validate and an entity mapping to a non-existent table,
// ORM init should fail. This file should never execute.
echo( "SILENT: schema validation did not catch missing table" );
</cfscript>
