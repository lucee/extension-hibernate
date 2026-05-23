<cfscript>
// Car extends Vehicle extends AuditedBase (mappedSuperClass).
// Expect: Car gets `doors` (own), `wheels` (real-parent), `auditedBy` (mappedSuperClass 2 levels up).
// Discriminator must distinguish Car from a plain Vehicle.

v = entityNew( "Vehicle" );
v.setId( createUUID() );
v.setWheels( 2 );
v.setAuditedBy( "alice" );
entitySave( v );

c = entityNew( "Car" );
c.setId( createUUID() );
c.setWheels( 4 );
c.setDoors( 4 );
c.setAuditedBy( "bob" );
entitySave( c );

ormFlush();
ormClearSession();

// Load Car by PK — should hit the discriminator and include all inherited fields.
loadedCar = entityLoadByPK( "Car", c.getId() );
if ( isNull( loadedCar ) )
	throw( message="Car not loaded by PK" );
if ( loadedCar.getDoors() != 4 )
	throw( message="Car own property `doors` not persisted, got [#loadedCar.getDoors()#]" );
if ( loadedCar.getWheels() != 4 )
	throw( message="Car real-parent property `wheels` not persisted, got [#loadedCar.getWheels()#]" );
if ( loadedCar.getAuditedBy() != "bob" )
	throw( message="Car mappedSuperClass property `auditedBy` not persisted, got [#loadedCar.getAuditedBy()#]" );

// Discriminator check: entityLoad("Car") should NOT return the plain Vehicle.
allCars = entityLoad( "Car", {} );
if ( arrayLen( allCars ) != 1 )
	throw( message="expected 1 Car, got [#arrayLen( allCars )#] — discriminator may be broken" );

// Vehicle root-load should see both rows.
allVehicles = entityLoad( "Vehicle", {} );
if ( arrayLen( allVehicles ) != 2 )
	throw( message="expected 2 Vehicles (incl. Car), got [#arrayLen( allVehicles )#]" );

echo( "ok" );
</cfscript>
