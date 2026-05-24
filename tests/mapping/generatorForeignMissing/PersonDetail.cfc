// generator="foreign" with property="parent" → looks up the parent property's
// cfc= attribute → "DoesNotExistAtAll" → no such entity registered.
//
// Today (LDEV-6342 RED): HBMCreator.getDefaultTypeForGenerator catches the
// PageException from getEntityByCFCName, logs WARN, defaults id type to
// "string". Hibernate later fails at SF build with an unrelated error that
// doesn't name the actual cause.
//
// After fix (LDEV-6342 GREEN): throw at the catch site with the property,
// entity, and missing-CFC name in the message — points the user straight at
// the typo.
component persistent="true" table="person_detail" accessors="true" {
	property name="id"     fieldtype="id" ormtype="integer" generator="foreign" property="parent";
	property name="parent" fieldtype="one-to-one" cfc="DoesNotExistAtAll" constrained="true";
	property name="bio"    ormtype="string" length="200";
}
