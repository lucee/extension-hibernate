<cfscript>
id = createUUID();
acct = entityNew( "Account", { id: id, balance: 12345678.1234, rate: 12.123456 } );
entitySave( acct );
ormFlush();
ormClearSession();

loaded = entityLoadByPK( "Account", id );
if ( loaded.getBalance() != 12345678.1234 )
	throw( message="balance mismatch: #loaded.getBalance()#" );

echo( "ok" );
</cfscript>
