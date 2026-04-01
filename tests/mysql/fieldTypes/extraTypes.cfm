<cfscript>
// all extra field types including text, yes_no, true_false
sink = entityNew( "ExtraTypes", {
	id:             createUUID(),
	shortVal:       42,
	longVal:        9999999999,
	floatVal:       3.14,
	doubleVal:      2.71828,
	bigDecimalVal:  123456.789,
	textVal:        repeatString( "lorem ipsum ", 100 ),
	yesNoVal:       true,
	trueFalseVal:   false
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
if ( len( sink.getTextVal() ) < 100 )
	throw( message="text: expected long string, got len=#len( sink.getTextVal() )#" );
if ( !sink.getYesNoVal() )
	throw( message="yes_no: expected true" );
if ( sink.getTrueFalseVal() )
	throw( message="true_false: expected false" );

echo( "ok" );
</cfscript>
