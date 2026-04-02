<cfscript>
// timezone default
sink = entityNew( "KitchenSink", { id: createUUID() } );
if ( sink.getTimezone() != "America/Los_Angeles" ) throw( message="timezone default: expected America/Los_Angeles, got #sink.getTimezone()#" );
// timezone round-trip (OOE-10 fix)
sink.setTimezone( "Europe/London" );
entitySave( sink );
ormFlush();
entityReload( sink );
if ( sink.getTimezone() != "Europe/London" ) throw( message="timezone persist: expected Europe/London, got #sink.getTimezone()#" );

// string
sink2 = entityNew( "KitchenSink", { id: createUUID() } );
if ( sink2.getString() != "johnwhish" ) throw( message="string default: expected johnwhish, got #sink2.getString()#" );
sink2.setString( "new" );
entitySave( sink2 );
ormFlush();
entityReload( sink2 );
if ( sink2.getString() != "new" ) throw( message="string persist: expected new, got #sink2.getString()#" );

// boolean
sink3 = entityNew( "KitchenSink", { id: createUUID() } );
if ( sink3.getBoolean() ) throw( message="boolean default: expected false" );
sink3.setBoolean( true );
entitySave( sink3 );
ormFlush();
entityReload( sink3 );
if ( !sink3.getBoolean() ) throw( message="boolean persist: expected true" );

// integer
sink4 = entityNew( "KitchenSink", { id: createUUID() } );
if ( sink4.getInteger() != 12303 ) throw( message="integer default: expected 12303, got #sink4.getInteger()#" );
sink4.setInteger( 99901 );
entitySave( sink4 );
ormFlush();
entityReload( sink4 );
if ( sink4.getInteger() != 99901 ) throw( message="integer persist: expected 99901, got #sink4.getInteger()#" );

// int (alias)
sink5 = entityNew( "KitchenSink", { id: createUUID() } );
if ( sink5.getInt() != 12404 ) throw( message="int default: expected 12404, got #sink5.getInt()#" );
sink5.setInt( 88808 );
entitySave( sink5 );
ormFlush();
entityReload( sink5 );
if ( sink5.getInt() != 88808 ) throw( message="int persist: expected 88808, got #sink5.getInt()#" );

// date default + round-trip
sink6 = entityNew( "KitchenSink", { id: createUUID() } );
if ( dateFormat( sink6.getDate(), "yyyy-mm-dd" ) != "2023-07-29" ) throw( message="date default: expected 2023-07-29" );
currentDate = now();
sink6.setDate( currentDate );
entitySave( sink6 );
ormFlush();
entityReload( sink6 );
if ( dateFormat( sink6.getDate(), "yyyy-mm-dd" ) != dateFormat( currentDate, "yyyy-mm-dd" ) )
	throw( message="date persist: expected #dateFormat( currentDate, 'yyyy-mm-dd' )#, got #dateFormat( sink6.getDate(), 'yyyy-mm-dd' )#" );

// datetime default + round-trip
sink6b = entityNew( "KitchenSink", { id: createUUID() } );
if ( dateCompare( sink6b.getDatetime(), createDateTime( 2023, 7, 29, 4, 56 ) ) != 0 )
	throw( message="datetime default: expected 2023-07-29T04:56" );
dtVal = now();
sink6b.setDatetime( dtVal );
entitySave( sink6b );
ormFlush();
entityReload( sink6b );
if ( dateFormat( sink6b.getDatetime(), "yyyy-mm-dd" ) != dateFormat( dtVal, "yyyy-mm-dd" ) )
	throw( message="datetime persist: date mismatch" );

// timestamp
sink7 = entityNew( "KitchenSink", { id: createUUID() } );
if ( dateFormat( sink7.getTimestamp(), "yyyy-mm-dd" ) != "2023-07-29" ) throw( message="timestamp default: expected 2023-07-29" );
sink7.setTimestamp( createDate( 2023, 08, 02 ) );
entitySave( sink7 );
ormFlush();
entityReload( sink7 );
if ( dateFormat( sink7.getTimestamp(), "yyyy-mm-dd" ) != "2023-08-02" ) throw( message="timestamp persist: expected 2023-08-02" );

echo( "ok" );
</cfscript>
