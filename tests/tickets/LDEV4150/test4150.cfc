
component accessors="true" persistent="true" {
	property name="id" type="string";
	property name="name" type="string" sqltype="varchar" length="100";
	property name="address" type="string" sqltype="nvarchar" length="150";
	
	public component function init() {
		return this;
	}
}