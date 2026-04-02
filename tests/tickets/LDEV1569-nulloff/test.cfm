<cfscript>
	// ORM entity with NULL property (no default)
	queryExecute( "DELETE FROM LDEV1569 WHERE id='ns1'", {}, { datasource: "h2" } );
	queryExecute( "INSERT INTO LDEV1569 (id, name, description) VALUES ('ns1', 'hasname', NULL)", {}, { datasource: "h2" } );
	ormClearSession();

	entity = entityLoadByPK( "NullEntity", "ns1" );
	ormJson = serializeJSON( entity );
	ormParsed = deserializeJSON( ormJson );

	// Non-persistent CFC with unset property
	dto = new DTO();
	dto.setId( "x1" );
	dto.setName( "hasname" );
	dtoJson = serializeJSON( dto );
	dtoParsed = deserializeJSON( dtoJson );

	// Non-persistent CFC with explicit null
	dto2 = new DTO();
	dto2.setId( "x2" );
	dto2.setName( "hasname" );
	dto2.setDescription( javaCast( "null", "" ) );
	dto2Json = serializeJSON( dto2 );
	dto2Parsed = deserializeJSON( dto2Json );

	// Non-persistent CFC with all set
	dto3 = new DTO();
	dto3.setId( "x3" );
	dto3.setName( "hasname" );
	dto3.setDescription( "hasdesc" );
	dto3Json = serializeJSON( dto3 );
	dto3Parsed = deserializeJSON( dto3Json );

	// Plain struct with null
	ps = { id: "x4", name: "hasname", description: javaCast( "null", "" ) };
	psJson = serializeJSON( ps );
	psParsed = deserializeJSON( psJson );

	result = {
		orm_json: ormJson,
		orm_hasDescription: structKeyExists( ormParsed, "description" ),
		dto_json: dtoJson,
		dto_hasDescription: structKeyExists( dtoParsed, "description" ),
		dto_explicitNull_json: dto2Json,
		dto_explicitNull_hasDescription: structKeyExists( dto2Parsed, "description" ),
		dto_allSet_json: dto3Json,
		dto_allSet_hasDescription: structKeyExists( dto3Parsed, "description" ),
		struct_json: psJson,
		struct_hasDescription: structKeyExists( psParsed, "description" )
	};

	echo( serializeJSON( result ) );
</cfscript>
