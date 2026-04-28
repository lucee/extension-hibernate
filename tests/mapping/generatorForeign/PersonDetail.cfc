// Dependent side — id is the FK to Person via the foreign generator.
component persistent="true" table="person_detail" accessors="true" {

	// generator="foreign" — id derived from the Person entity referenced by `parent`.
	property name="id"     fieldtype="id" ormtype="integer" generator="foreign" property="parent";
	property name="parent" fieldtype="one-to-one" cfc="Person" constrained="true";

	property name="bio" ormtype="string" length="200";
}
