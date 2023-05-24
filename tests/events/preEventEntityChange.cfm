<cfsetting showdebugoutput="false">
<cfscript>
	code = entityNew( 'Code' );
	code.setId( 55 );
	code.setCode( '<cfscript></cfscript>' );
	// should trigger preInsert, postInsert, and onFlush
	entitySave( code );
	ormFlush();

	ormClearSession();
	updated = entityLoad( "Code", 55,true );

	updated.setCode( '<cfscript>var michael="🤪";</cfscript>');
	entitySave( updated );
	ormFlush();

	ormClearSession();
	finalEntity = entityLoad( "Code", 55, true );
	
	result = {
		finalEntity: {
			id : finalEntity.getId(),
			inserted : finalEntity.getInserted(),
			updated : finalEntity.getUpdated(),
			code : finalEntity.getCode()
		},
		errors: []
	};

	loop array=application.ormEventErrorLog item="a" {
		arrayAppend(result.errors, a);
	};
	echo( result.toJson() );
</cfscript>
