component accessors="true" persistent="true" table="LDEV4067_init" {
	property name="id" type="string" fieldtype="id" ormtype="string";
	property name="name" type="string";
	property name="status" type="string" default="active";

	this.initCalled = false;
	this.getNameFn = function() {
		return variables.getName();
	};

	function init() {
		this.initCalled = true;
		return this;
	}
}
