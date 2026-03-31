<cfscript>
// force schema creation
entitySave( entityNew( "KitchenSink", { id: createUUID() } ) );
ormFlush();

// notnull
cfdbinfo( type="Columns", name="cols", table="KITCHENSINK" );
notnullCol = cols.filter( function( row ) { return row.COLUMN_NAME == "NOTNULLABLE"; } );
if ( notnullCol.NULLABLE[ 1 ] != 0 ) throw( message="notnullable column should not be nullable" );
nullableCol = cols.filter( function( row ) { return row.COLUMN_NAME == "NULLABLE"; } );
if ( nullableCol.NULLABLE[ 1 ] != 1 ) throw( message="nullable column should be nullable" );

// insert=false: value not persisted on insert
sink = entityNew( "KitchenSink", { id: createUUID() } );
if ( sink.getNoInsert() != "thedefault" ) throw( message="noinsert default: expected thedefault" );
entitySave( sink );
ormFlush();
entityReload( sink );
if ( !isNull( sink.getNoInsert() ) && len( sink.getNoInsert() ) ) throw( message="noinsert after insert: expected null/empty, got #sink.getNoInsert()#" );

// insert=false: can update after insert
sink.setNoInsert( "valuetoinsert" );
entitySave( sink );
ormFlush();
entityReload( sink );
if ( sink.getNoInsert() != "valuetoinsert" ) throw( message="noinsert after update: expected valuetoinsert, got #sink.getNoInsert()#" );

// update=false: value persisted on insert
sink2 = entityNew( "KitchenSink", { id: createUUID() } );
sink2.setNoUpdate( "valuetoinsert" );
entitySave( sink2 );
ormFlush();
entityReload( sink2 );
if ( sink2.getNoUpdate() != "valuetoinsert" ) throw( message="noupdate after insert: expected valuetoinsert, got #sink2.getNoUpdate()#" );

// update=false: value not changed on update
sink2.setNoUpdate( "valuetoupdate" );
entitySave( sink2 );
ormFlush();
entityReload( sink2 );
if ( sink2.getNoUpdate() != "valuetoinsert" ) throw( message="noupdate after update: expected valuetoinsert, got #sink2.getNoUpdate()#" );

// empty default
sink3 = entityNew( "KitchenSink", { id: createUUID() } );
if ( sink3.getEmptyDefault() != "" ) throw( message="emptydefault: expected empty string" );
entitySave( sink3 );
ormFlush();
entityReload( sink3 );
if ( sink3.getEmptyDefault() != "" ) throw( message="emptydefault after persist: expected empty string" );

echo( "ok" );
</cfscript>
