<cfscript>
	// LDEV-6390: Criteria with AggregateProjection (rowCount) — the CBORM-style surface
	// that triggers ClassLoaderService.classForName for org.hibernate.criterion.*
	// and lazy SQL type descriptors. Pre-5.6.15.18 Hibernate built its own ClassLoaderService
	// from TCCL; LDEV-6390 pinned it to ClassLoaderServiceImpl.class.getClassLoader() and
	// regressed criteria + projection loads for users running on certain Lucee versions.
	for ( i = 1; i <= 3; i++ ) {
		e = entityNew( "LDEV6390Entity" );
		e.setId( createUUID() );
		e.setName( "row-" & i );
		entitySave( e );
	}
	ormFlush();

	ormSess = ORMGetSession();
	crit = ormSess.createCriteria( "LDEV6390Entity" );
	projections = createObject( "java", "org.hibernate.criterion.Projections" );
	crit.setProjection( projections.rowCount() );
	count = crit.uniqueResult();

	if ( count != 3 )
		throw( message="rowCount Criteria: expected 3, got [#count#]" );
	echo( "ok" );
</cfscript>
