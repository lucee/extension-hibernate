// DELIBERATELY no ormtype= on the id property. After LDEV-6343 lands the id
// type should resolve to Person's integer id type. Today the bug defaults to
// varchar(255), which then can't FK-constrain to Person's integer id and SF
// init dies at schema generation.
component persistent="true" table="person_detail_noormtype" accessors="true" {
	property name="id"     fieldtype="id" generator="foreign" params="{property='parent'}";
	property name="parent" fieldtype="one-to-one" cfc="Person" constrained="true";
	property name="bio"    ormtype="string" length="200";
}
