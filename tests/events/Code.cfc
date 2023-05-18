component persistent="true" {

	property name="ID" type="numeric" fieldtype="id" ormtype="long";// generator="identity";
	property name="code" type="string";

	this.name = "Code"; // used for logging out events

	function preInsert(){
		eventLog( "preInsert" );
	}
	function postInsert(){
		eventLog( "postInsert" );
	}

	function preUpdate(){
		eventLog( "preUpdate" );
	}
	function postUpdate(){
		eventLog( "postUpdate" );
	}

	function preLoad(){
		eventLog( "preLoad" );
	}
	function postLoad(){
		eventLog( "postLoad" );
	}

	function preDelete(){
		eventLog( "preDelete" );
	}
	function postDelete(){
		eventLog( "postDelete" );
	}

	private function eventLog( required string eventName ){
		application.ormEventLog.append( {
			"src": this.name,
			"eventName": arguments.eventName
		} );
	}
}