component persistent="true" table="ldev7026_account" accessors="true" {
	property name="id" fieldtype="id" ormtype="string" length="32" generator="assigned";
	property name="balance" ormtype="integer";
	property name="transactions" fieldtype="one-to-many" cfc="AccountTransaction" fkcolumn="accountId" type="array" lazy="true" inverse="true";
}
