<cfscript>
	// A lazy proxy loaded outside transaction{} and initialized as the first ORM read inside the
	// block: the proxy load opens the connection, hydration then starts the ORM transaction, which
	// must not release that connection while the load is still reading it.
	ormReload();

	function uid() {
		return replace( createUUID(), "-", "", "all" );
	}

	// setup data, then start the request again with an empty session
	account = entityNew( "Account" );
	account.setId( uid() );
	account.setBalance( 100 );
	entitySave( account );
	tx = entityNew( "AccountTransaction" );
	tx.setId( uid() );
	tx.setAmount( 5 );
	tx.setAccount( account );
	entitySave( tx );
	ormFlush();
	ormClearSession();
	// the setup leaves the session holding a connection, release it like a new request would
	ormCloseSession();

	accountId = account.getId();
	txId = tx.getId();

	switch ( url.scenario ) {
		case "proxy":
		case "proxyAfterQuery":
		case "proxyLoadByPK":
		case "saveThenProxy":
			t = entityLoad( "AccountTransaction", {}, "", { maxresults: 1 } )[ 1 ];
			break;
		case "collection":
			a = entityLoadByPK( "Account", accountId );
			break;
		default:
			throw( message="unknown scenario [#url.scenario#]" );
	}
	if ( url.scenario == "saveThenProxy" ) {
		// ORM work outside the block leaves the session holding its connection (LDEV-6941)
		other = entityNew( "Account" );
		other.setId( uid() );
		other.setBalance( 1 );
		entitySave( other );
		ormFlush();
	}

	transaction {
		switch ( url.scenario ) {
			case "proxy":
			case "saveThenProxy":
				balance = t.getAccount().getBalance();
				break;
			case "proxyAfterQuery":
				queryExecute( "SELECT count(*) AS n FROM ldev7026_tx" );
				balance = t.getAccount().getBalance();
				break;
			case "proxyLoadByPK":
				balance = entityLoadByPK( "Account", t.getAccount().getId() ).getBalance();
				break;
			case "collection":
				if ( arrayLen( a.getTransactions() ) != 1 ) throw( message="expected one transaction in the lazy collection" );
				balance = a.getBalance();
				break;
		}
		if ( balance != 100 ) throw( message="expected balance 100, got [#balance#]" );

		// LDEV-6941: ORM work and queryExecute() in the block must still share one connection
		inside = entityNew( "AccountTransaction" );
		inside.setId( uid() );
		inside.setAmount( 7 );
		inside.setAccount( entityLoadByPK( "Account", accountId ) );
		entitySave( inside, true );
		ormFlush();
		n = queryExecute( "SELECT count(*) AS n FROM ldev7026_tx WHERE id = :id", { id: inside.getId() } ).n;
		if ( n != 1 ) throw( message="queryExecute() inside transaction{} did not see the ORM insert (count #n#), so ORM and queryExecute() ran on different connections" );
		// on a second connection this update would wait for the ORM's row lock
		queryExecute( "UPDATE ldev7026_tx SET amount = 8 WHERE id = :id", { id: inside.getId() } );
		transactionRollback();
	}

	// the rollback must undo both the ORM insert and the queryExecute() update
	n = queryExecute( "SELECT count(*) AS n FROM ldev7026_tx WHERE id = :id", { id: inside.getId() } ).n;
	if ( n != 0 ) throw( message="transactionRollback() did not roll back the ORM insert, so ORM work ran outside the transaction{} connection" );

	echo( "ok" );
</cfscript>
