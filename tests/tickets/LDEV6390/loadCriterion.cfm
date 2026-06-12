<cfscript>
	// LDEV-6390 probe: load org.hibernate.criterion classes via createObject.
	// Reproduces myleslee's 'bundle wiring for org.lucee.hibernate.extension is no longer valid'
	// reported against 5.6.15.18-SNAPSHOT when CBORM constructs Criteria/Projections.
	aggregate = createObject( "java", "org.hibernate.criterion.AggregateProjection" );
	projections = createObject( "java", "org.hibernate.criterion.Projections" );
	descriptor = createObject( "java", "org.hibernate.type.descriptor.sql.DoubleTypeDescriptor" );
	echo( "ok" );
</cfscript>
