component persistent="true" cachename="Autos" cacheuse="read-only" {

	property name="id" type="string" fieldtype="id" ormtype="string";
	property name="make" type="string";
	property name="model" type="string";

	this.name = "Auto";
}