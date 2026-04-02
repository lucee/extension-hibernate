<cfscript>
// ormtype="garbage" should throw at ORM init
// This file should never execute — the Application.cfc init should fail first
echo( "SILENT: ormtype=garbage was silently ignored" );
</cfscript>
