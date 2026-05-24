component persistent="true" table="person_noormtype" accessors="true" {
	property name="id"   fieldtype="id" ormtype="integer" generator="native";
	property name="name" ormtype="string" length="100";

	property name="detail" fieldtype="one-to-one" cfc="PersonDetail" mappedBy="parent" cascade="all";
}
