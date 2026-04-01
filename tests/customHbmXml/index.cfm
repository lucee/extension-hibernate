<cfscript>
// autogenmap=false — ORM should use the hand-written Widget.cfc.hbm.xml
// which maps to custom table/column names: custom_widgets, widget_id, widget_label, widget_qty
widget = entityNew( "Widget", { id: createUUID(), label: "Sprocket", quantity: 42 } );
entitySave( widget );
ormFlush();

// verify the custom table and column names from our hbm.xml are used
result = queryExecute( "SELECT widget_label, widget_qty FROM custom_widgets WHERE widget_id = :id",
	{ id: widget.getId() } );
if ( result.recordCount != 1 )
	throw( message="expected 1 row in custom_widgets, got #result.recordCount#" );
if ( result.widget_label[ 1 ] != "Sprocket" )
	throw( message="expected Sprocket, got #result.widget_label[ 1 ]#" );
if ( result.widget_qty[ 1 ] != 42 )
	throw( message="expected 42, got #result.widget_qty[ 1 ]#" );

echo( "ok" );
</cfscript>
