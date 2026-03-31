component persistent="false" {

	function onFlush( entity ) {
		eventLog( "onFlush" );
	}

	function preLoad( entity ) {
		eventLog( "preLoad" );
	}

	function postLoad( entity ) {
		eventLog( "postLoad" );
	}

	function preInsert( entity ) {
		eventLog( "preInsert" );
	}

	function postInsert( entity ) {
		eventLog( "postInsert" );
	}

	function preUpdate( entity, struct oldData ) {
		eventLog( "preUpdate" );
	}

	function postUpdate( entity ) {
		eventLog( "postUpdate" );
	}

	function preDelete( entity ) {
		eventLog( "preDelete" );
	}

	function onDelete( entity ) {
		eventLog( "onDelete" );
	}

	function postDelete( entity ) {
		eventLog( "postDelete" );
	}

	function onClear( entity ) {
		eventLog( "onClear" );
	}

	function onEvict() {
		eventLog( "onEvict" );
	}

	private function eventLog( required string eventName ) {
		application.ormEventLog.append( eventName );
	}

}
