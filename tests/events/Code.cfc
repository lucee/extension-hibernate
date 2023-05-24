component persistent="true" accessors="true" {

	property name="ID" type="numeric" fieldtype="id" ormtype="long";// generator="identity";
	property name="code" type="string";

	property name="inserted" type="boolean" default="false";
	property name="updated" type="boolean" default="false";

	this.name = "Code"; // used for logging out events

	function preInsert(){
		// https://ortussolutions.atlassian.net/browse/OOE-1
		validate( "preInsert" );
		setInserted( true );
		eventLog( "preInsert" );
	}
	function postInsert(){
		// https://ortussolutions.atlassian.net/browse/OOE-1
		validate( "preInsert" );
		eventLog( "postInsert" );
	}

	function preUpdate(){
		// https://ortussolutions.atlassian.net/browse/OOE-1
		validate( "preInsert" );
		setUpdated( true );
		eventLog( "preUpdate" );
	}
	function postUpdate(){
		// https://ortussolutions.atlassian.net/browse/OOE-1
		validate( "preInsert" );
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

	private function validate( required string eventName ){
		if ( isNull( getCode() ) || getCode() == '' ){
			application.ormEventErrorLog.append( { "error": "getCode() is empty from inside #arguments.eventName#() event " } );
		}
	}
}