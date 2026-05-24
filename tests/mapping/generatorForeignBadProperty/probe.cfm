<cfscript>
// ORM init in Application.cfc throws before this template runs. The spec's
// try/catch around _InternalRequest captures the throw and asserts message.
entityNew( "BadProperty" );
echo( "ok" );
</cfscript>
