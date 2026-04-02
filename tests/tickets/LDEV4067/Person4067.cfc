component accessors="true" persistent="true" table="LDEV4067" {
	property name="id" type="string" fieldtype="id" ormtype="string";
	property name="name" type="string";

	this.memento = {
		mappers = {
			"theName": () => variables.getName()
		}
	};
}
