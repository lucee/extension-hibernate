<cfscript>
entitySave( entityNew( "Auto", { id: createUUID(), make: "Zebra", model: "Z1" } ) );
entitySave( entityNew( "Auto", { id: createUUID(), make: "Alpha", model: "A1" } ) );
entitySave( entityNew( "Auto", { id: createUUID(), make: "Middle", model: "M1" } ) );
ormFlush();

// entityLoad with sort order
sorted = entityLoad( "Auto", {}, "make ASC" );
if ( sorted[ 1 ].getMake() != "Alpha" ) throw( message="sort ASC: expected Alpha first, got #sorted[ 1 ].getMake()#" );
if ( sorted[ 3 ].getMake() != "Zebra" ) throw( message="sort ASC: expected Zebra last, got #sorted[ 3 ].getMake()#" );

// descending
sortedDesc = entityLoad( "Auto", {}, "make DESC" );
if ( sortedDesc[ 1 ].getMake() != "Zebra" ) throw( message="sort DESC: expected Zebra first, got #sortedDesc[ 1 ].getMake()#" );

echo( "ok" );
</cfscript>
