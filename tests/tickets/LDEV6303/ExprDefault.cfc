component persistent="true" table="ldev6303_expr_default" accessors="true" {
	property name="id" fieldtype="id" ormtype="integer";
	property name="literal" ormtype="string" default="literal";
	property name="expr" ormtype="string" default="#repeatString( 'x', 3 )#";
	property name="exprNumber" ormtype="integer" default="#1 + 2#";
}
