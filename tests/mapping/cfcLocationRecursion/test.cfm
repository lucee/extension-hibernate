<cfscript>
// Foo lives in ./child/entities/ — a sibling Application.cfc dir. If the
// parent's cfclocation recursion is blind to that boundary (current Lucee
// and ACF behaviour), Foo is registered in this parent SF and entityNew
// resolves it. If recursion ever starts honouring Application.cfc boundaries,
// this throws and the spec fails.
foo = entityNew( "Foo" );
echo( "ok" );
</cfscript>
