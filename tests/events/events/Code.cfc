component persistent="true" extends="eventHandler" cfcName="code" {

	property name="ID" type="numeric" fieldtype="id" ormtype="long";// generator="identity";
	property name="code" type="string";
	
}