<cfscript>
	include "setup.cfm";
	entity = entityLoadByPK( "Composite", { k1: 1, k2: "b" } );
	echo( entity.getName() );
</cfscript>
