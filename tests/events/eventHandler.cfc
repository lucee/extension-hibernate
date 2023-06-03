component hint="logs out any orm events"  {
	this.name = "global"; // used for logging out events

	function init(){
		return this;
	}

	// Currently not implemented
	function preFlush(  entity ){ // entities
		eventLog( arguments );
	}
	function onFlush( entity ) {
		eventLog( arguments );
	}
	// Currently not implemented
	function postFlush( entity ){ // entities
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

	function preUpdate( entity, oldData  ){
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

		if ( !isNull(args.2 ) ){  // only postNew, preUpdate should have two args
			if ( isSimpleValue( args.2 ) ){
				systemOutput("simple arguments.2: " & args.2, true);
			} else if ( isStruct( args.2) ) {
				systemOutput("struct arguments.2: " & serializeJson(args.2), true); // hmm??
			} else {
				try {
					systemOutput("arguments.2: " & args.2.getClass(), true); //hmm?
				} catch (e) {
					systemOutput("arguments.2: " & e.message, true);
				}
			}
		}

		//if ( ! structKeyExists( application, "ormEventLog" ) )
		//    application.ormEventLog = [];
		application.ormEventLog.append( {
			"src": this.name,
			"eventName": eventName,
			"args": args
		} );

		var noEntityExpected = {
			"onFlush" : true,
			"onClear" : true
		};

		if (structKeyExists(noEntityExpected, eventName)) return;

		try {
			if ( isNull(arguments.args.entity ) ) {
				throw ("entity was null");
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