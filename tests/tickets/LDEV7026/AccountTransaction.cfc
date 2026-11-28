component persistent="true" table="ldev7026_tx" accessors="true" {
	property name="id" fieldtype="id" ormtype="string" length="32" generator="assigned";
	property name="amount" ormtype="integer";
	property name="account" fieldtype="many-to-one" cfc="Account" fkcolumn="accountId" lazy="true";
}
