<cfscript>
// LDEV-1697: Lucee throws an ambiguity error when cfclocation lists a parent dir
// AND its child dir (e.g. ["/orm", "/orm/ems"]) — ACF dedups silently.
// Filed 2018-03-01, still Backlog. This test reproduces the failure path.

truck = entityNew( "Truck", { id: createUUID(), model: "F-150" } );
entitySave( truck );

plane = entityNew( "Plane", { id: createUUID(), model: "747" } );
entitySave( plane );

ormFlush();

// verify both via direct SQL
truckResult = queryExecute( "SELECT count(*) as cnt FROM Truck" );
if ( truckResult.cnt[ 1 ] != 1 )
	throw( message="expected 1 truck, got #truckResult.cnt[ 1 ]#" );

planeResult = queryExecute( "SELECT count(*) as cnt FROM Plane" );
if ( planeResult.cnt[ 1 ] != 1 )
	throw( message="expected 1 plane, got #planeResult.cnt[ 1 ]#" );

// verify each appears exactly once in entityNameArray (no duplicate registration)
names = entityNameArray();
truckCount = 0;
planeCount = 0;
for ( n in names ) {
	if ( compareNoCase( n, "Truck" ) == 0 ) truckCount++;
	if ( compareNoCase( n, "Plane" ) == 0 ) planeCount++;
}
if ( truckCount != 1 )
	throw( message="expected 1 Truck registration, got #truckCount# in: #arrayToList( names )#" );
if ( planeCount != 1 )
	throw( message="expected 1 Plane registration, got #planeCount# in: #arrayToList( names )#" );

echo( "ok" );
</cfscript>
