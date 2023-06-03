component hint="logs out any orm events"  {
	this.name = "global"; // used for logging out events

	function init(){
		return this;
	}

	function onFlush( entity ) {
		eventLog( arguments );
	}

	function postNew( any entity, any entityName ){
		eventLog( arguments );
	}

	function preLoad( entity ){
		eventLog( arguments );
	}
	function postLoad( entity ){
		eventLog( arguments );
	}

	function preInsert( entity ){
		eventLog( arguments );
	}
	function postInsert( entity ){
		eventLog( arguments );
	}

	function preUpdate( entity, Struct oldData  ){
		systemOutput(oldData, true);
		eventLog( arguments );
	}
	function postUpdate( entity ){
		eventLog( arguments );
	}

	function preDelete( entity ){
		eventLog( arguments );
	}	
	function onDelete( entity ) {
		eventLog( arguments );
	}
	function postDelete( entity ) {
		eventLog( arguments );
	}

	function onEvict() {
		eventLog( arguments );
	}
	function onClear( entity ) {
		eventLog( arguments );
	}
	function onDirtyCheck( entity ) {
		eventLog( arguments );
	}
	function onAutoFlush( entity ) {
		eventLog( arguments );
	}

	function onMissingMethod(missingMethodName){
		systemOutput( "on missing method [#missingMethodName#]", true );
	}

	private function eventLog( required struct args ){
		var eventName = CallStackGet( "array" )[2].function;
		var s = CallStackGet( "array" )[3];
		systemOutput( "------- #eventName#  #listLast(s.template,"/\")#: #s.lineNumber#", true );
		systemOutput( "arguments: " & structKeyList(args), true);

		//if ( ! structKeyExists( application, "ormEventLog" ) )
		//    application.ormEventLog = [];
		application.ormEventLog.append( {
			"src": this.name,
			"eventName": eventName,
			"args": args
		} );

		try {
			// Certain events like onFlush, onClear, onAutoFlush will not have an associated entity.
			if ( isNull(arguments.args.entity ) ) {
				return;
			}

			if (isObject( args.entity ) ){
				try {
					var obj = GetComponentMetaData(args.entity);
					if (obj.fullname neq "testAdditional.events.Code")
						throw "wrong entity: " & obj.fullname;
				} catch( e ) {
					systemOutput( e.message, true );
					throw e.message;	
				}
			}

		} catch(e) {
			application.ormEventErrorLog.append({ 
				"error" : e.message & " #eventName#  #listLast(s.template,"/\")#: #s.lineNumber#",
				"src": this.name,
				"eventName": eventName
			} );
		}
	}
}