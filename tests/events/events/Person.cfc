component persistent="true" cfcName="person" {

	property name="ID" type="numeric" ormtype="int" fieldtype="id" ormtype="long" generator="increment";
	property name="Person" type="string";

    public function preInsert( entity, event ) {
        systemOutput("@person.preInsert", true);
        systemOutput(arguments, true);
		systemOutput(this, true);
		setPerson("Lucee");
		systemOutput(this, true);
        return this;
	}

    public void function postInsert() {
        systemOutput("@person.postInsert", true);
        systemOutput(arguments, true);
		systemOutput(this, true);
	}

	this.name = "Person"; // used for logging out events
}