component persistent="true" {

	property name="id" type="string" fieldtype="id" ormtype="string";
	property name="name" type="string";
	property name="username" type="string";
	property name="password" type="string";
	property name="createdOn" ormtype="datetime" dbdefault="2016-10-10";

	this.name = "User";
}