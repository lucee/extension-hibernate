component accessors="true" persistent="true" table="LDEV4067_direct" {
	property name="id" type="string" fieldtype="id" ormtype="string";
	property name="name" type="string";

	this.getNameFn = function() {
		return variables.getName();
	};
}
