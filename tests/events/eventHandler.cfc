component hint="logs out any orm events"  {
	this.name = "EventHandler"; // used for logging out events

	function init(){
		return this;
	}

	function onFlush( entity ) {
		eventLog( "onFlush", arguments );
	}

	function postNew( any entity, any entityName ){
		eventLog( "postNew", arguments );
	}

	function preLoad( entity ){
		eventLog( "preLoad", arguments );
	}
	function postLoad( entity ){
		eventLog( "postLoad", arguments );
	}

	function preInsert( entity ){
		eventLog( "preInsert", arguments );
	}
	function postInsert( entity ){
		eventLog( "postInsert", arguments );
	}

	function preUpdate( entity, Struct oldData  ){
		eventLog( "preUpdate", arguments );
	}
	function postUpdate( entity ){
		eventLog( "postUpdate", arguments );
	}

	function preDelete( entity ){
		eventLog( "preDelete", arguments );
	}	
	function onDelete( entity ) {
		eventLog( "onDelete", arguments );
	}
	function postDelete( entity ) {
		eventLog( "postDelete", arguments );
	}

	function onEvict() {
		eventLog( "onEvict", arguments );
	}
	function onClear( entity ) {
		eventLog( "onClear", arguments );
	}
	function onDirtyCheck( entity ) {
		eventLog( "onDirtyCheck", arguments );
	}
	function onAutoFlush( entity ) {
		eventLog( "onAutoFlush", arguments );
	}

	function onMissingMethod(missingMethodName){
		systemOutput( "on missing method [#missingMethodName#]", true );
	}

	private function eventLog( required string eventName, required struct args ){
		// disabled due to https://luceeserver.atlassian.net/browse/LDEV-3616
		// var s = CallStackGet( "array" )[3];
		// systemOutput( "------- EventHandler.#arguments.eventName#  #listLast(s.template,"/\")#: #s.lineNumber#", true );

		application.ormEventLog.append( {
			"src": this.name,
			"eventName": arguments.eventName,
			"args": args
		} );
	}
}