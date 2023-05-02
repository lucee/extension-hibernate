component persistent="true" {

	property name="id" type="string" fieldtype="id" ormtype="string";
	property name="name" type="string";
	property name="username" type="string";
	property name="password" type="string";

	this.name = "User";
}