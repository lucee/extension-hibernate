<cfscript>
// collectionType="badvalue" should throw at ORM init
// This file should never execute — the Application.cfc init should fail first
echo( "SILENT: collectionType=badvalue was silently ignored" );
</cfscript>
