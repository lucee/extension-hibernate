<cfscript>
// Adobe docs: "objects with nativeId generation are inserted immediately when the object is saved"
// generator="identity" uses DB auto-increment, so Hibernate must INSERT immediately
// to get the generated ID back. The entity should be in DB before ormFlush().

entity = entityNew( "NativeIdEntity" );
entity.setName( "Immediate" );
entitySave( entity );

// the ID should be populated immediately (from the INSERT)
id = entity.getId();
if ( isNull( id ) || id == 0 )
	throw( message="native ID should be populated immediately after entitySave, got #isNull( id ) ? 'null' : id#" );

// entity should be in DB already, without explicit ormFlush
row = queryExecute( "SELECT count(*) as cnt FROM NID_Entity WHERE id = :id", { id: id } );
if ( row.cnt != 1 )
	throw( message="native ID entity should be in DB before ormFlush, got count=#row.cnt#" );

echo( "ok" );
</cfscript>
