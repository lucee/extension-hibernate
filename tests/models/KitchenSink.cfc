/**
 * This entity is intended to contain a property for each supported field type.
 * 
 * See HibernateCaster for a definitive list of supported types.
 */
component persistent="true" {

	property
		name     ="id"
		type     ="string"
		fieldtype="id"
		ormtype  ="string";

	property 
        name="timezone" 
        ormtype="timezone"
        default="America/Los_Angelos";

	property
		name     ="string"
		ormtype  ="string"
		default  ="defaultstringvalue";

	this.name = "KitchenSink";

}
