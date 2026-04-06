<cfscript>
// fieldtype="collection" without elementtype should throw at ORM init
// This file should never execute — the Application.cfc init should fail first
echo( "SILENT: collection without elementtype was silently ignored" );
</cfscript>
