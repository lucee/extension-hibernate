<cfscript>
// numeric types: short, long, float, double, big_decimal
sink = entityNew( "ExtraTypesNumeric", {
	id:             createUUID(),
	shortVal:       42,
	longVal:        9999999999,
	floatVal:       3.14,
	doubleVal:      2.71828,
	bigDecimalVal:  123456.789
} );
entitySave( sink );
ormFlush();

entityReload( sink );

if ( sink.getShortVal() != 42 )
	throw( message="short: expected 42, got #sink.getShortVal()#" );
if ( sink.getLongVal() != 9999999999 )
	throw( message="long: expected 9999999999, got #sink.getLongVal()#" );
if ( numberFormat( sink.getFloatVal(), "0.00" ) != "3.14" )
	throw( message="float: expected 3.14, got #sink.getFloatVal()#" );
if ( numberFormat( sink.getDoubleVal(), "0.00000" ) != "2.71828" )
	throw( message="double: expected 2.71828, got #sink.getDoubleVal()#" );
// big_decimal defaults to decimal(19,2) so value is truncated to 2 decimal places
if ( sink.getBigDecimalVal() != 123456.79 )
	throw( message="big_decimal: expected 123456.79, got #sink.getBigDecimalVal()#" );

echo( "ok" );
</cfscript>
