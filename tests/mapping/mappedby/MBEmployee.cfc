// The FK side of the one-to-one unique FK association
// fkcolumn="officeId" creates the FK column in this table
component persistent="true" table="MB_Employee" accessors="true" entityname="MBEmployee" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	property name="office"
		fieldtype="one-to-one"
		cfc="MBOffice"
		fkcolumn="officeId";

}
