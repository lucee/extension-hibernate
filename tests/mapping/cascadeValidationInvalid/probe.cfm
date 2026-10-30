<cfscript>
// SF build must fail at startup with the validator's nice error.
// If we ever reach the body, the validator silently accepted the bad token —
// the test will see "ok" and fail rather than throw.
parent = entityNew( "InvalidParent" );
echo( "ok" );
</cfscript>
