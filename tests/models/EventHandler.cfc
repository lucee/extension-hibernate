component
	hint      ="logs out any orm events"
	persistent="false"
	implements="cfide.orm.IEventHandler"
{

	this.name = "EventHandler"; // used for logging out events

	function init(){
		return this;
	}

	public void function onFlush( entity ){
		eventLog( "onFlush", arguments );
	}

	public void function postNew( any entity, any entityName ){
		eventLog( "postNew", arguments );
	}

	public void function preLoad( entity ){
		eventLog( "preLoad", arguments );
	}
	public void function postLoad( entity ){
		eventLog( "postLoad", arguments );
	}

	public void function preInsert( entity ){
		eventLog( "preInsert", arguments );
	}
	public void function postInsert( entity ){
		eventLog( "postInsert", arguments );
	}

	public void function preUpdate( entity, Struct oldData ){
		eventLog( "preUpdate", arguments );
	}
	public void function postUpdate( entity ){
		eventLog( "postUpdate", arguments );
	}

	public void function preDelete( entity ){
		eventLog( "preDelete", arguments );
	}
	public void function onDelete( entity ){
		eventLog( "onDelete", arguments );
	}
	public void function postDelete( entity ){
		eventLog( "postDelete", arguments );
	}

	public void function onEvict(){
		eventLog( "onEvict", arguments );
	}
	public void function onClear( entity ){
		eventLog( "onClear", arguments );
	}
	public void function onDirtyCheck( entity ){
		eventLog( "onDirtyCheck", arguments );
	}
	public void function onAutoFlush( entity ){
		eventLog( "onAutoFlush", arguments );
	}

	public void function onMissingMethod( missingMethodName ){
		systemOutput( "on missing method [#missingMethodName#]", true );
	}

	private function eventLog( required string eventName, required struct args ){
		// disabled due to https://luceeserver.atlassian.net/browse/LDEV-3616
		// var s = CallStackGet( "array" )[3];
		// systemOutput( "------- EventHandler.#arguments.eventName#  #listLast(s.template,"/\")#: #s.lineNumber#", true );

		application.ormEventLog.append( {
			"src"       : this.name,
			"eventName" : arguments.eventName,
			"args"      : args
		} );
	}

}
