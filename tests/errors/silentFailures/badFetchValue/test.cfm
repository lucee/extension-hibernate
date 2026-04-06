<cfscript>
// fetch="bogus" should throw at ORM init
// This file should never execute — the Application.cfc init should fail first
echo( "SILENT: fetch=bogus was silently ignored" );
</cfscript>
