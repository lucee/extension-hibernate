<cfscript>
	// ORM work outside a transaction can leave the Hibernate session holding a connection.
	// A following transaction{} must still run ORM and queryExecute() on the same connection.
	ormReload();

	function newItem( name ) {
		var item = entityNew( "Item" );
		item.setId( replace( createUUID(), "-", "", "all" ) );
		item.setName( arguments.name );
		return item;
	}

	outside = newItem( "outside" );
	switch ( url.scenario ) {
		case "none":
			// control: no ORM work before the block
			break;
		case "save":
			entitySave( outside );
			break;
		case "saveFlush":
			entitySave( outside );
			ormFlush();
			break;
		case "saveClear":
			entitySave( outside );
			ormFlush();
			ormClearSession();
			break;
		case "reload":
			entitySave( outside );
			ormFlush();
			entityReload( outside );
			break;
		default:
			throw( message="unknown scenario [#url.scenario#]" );
	}

	transaction {
		inside = newItem( "inside" );
		entitySave( inside, true );
		ormFlush();
		// queryExecute() uses the transaction{} connection, so it must see the ORM insert
		n = queryExecute( "SELECT count(*) AS n FROM ldev6941_item WHERE id = :id", { id: inside.getId() } ).n;
		if ( n != 1 ) throw( message="queryExecute() inside transaction{} did not see the ORM insert (count #n#), so ORM and queryExecute() ran on different connections" );
		// on a second connection this update would wait for the ORM's row lock
		queryExecute( "UPDATE ldev6941_item SET name = 'updated' WHERE id = :id", { id: inside.getId() } );
	}

	rows = queryExecute( "SELECT name FROM ldev6941_item WHERE id = :id", { id: inside.getId() } );
	if ( rows.recordCount != 1 || rows.name != "updated" ) throw( message="expected the updated row after commit, got #serializeJSON( rows )#" );

	echo( "ok" );
</cfscript>
