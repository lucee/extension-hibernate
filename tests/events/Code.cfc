component persistent="true" {

	property name="ID" type="numeric" fieldtype="id" ormtype="long";// generator="identity";
	property name="code" type="string";

	this.name = "code"; // used for logging out events
}