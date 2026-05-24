<cfscript>
// ORM init in Application.cfc throws before this template ever runs when
// PersonDetail references a missing CFC. The spec catches that throw and
// asserts the message tokens. If ORM init unexpectedly succeeds, we get
// here and the spec's fail() fires.
entityNew( "PersonDetail" );
echo( "ok" );
</cfscript>
