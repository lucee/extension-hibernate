// one-to-one unique FK association: MBEmployee has the FK column referencing MBOffice
// MBOffice uses mappedby to say "the relationship is via the 'office' property in MBEmployee"
// This is NOT the same as JPA mappedBy — see Adobe docs on "Unique Foreign Key association"
component persistent="true" table="MB_Office" accessors="true" entityname="MBOffice" {

	property name="id"       fieldtype="id" ormtype="string";
	property name="location" ormtype="string";
	property name="employee"
		fieldtype="one-to-one"
		cfc="MBEmployee"
		mappedby="office";

}
