<cfscript>
	// LDEV-6390: Criteria with a row count projection — the CBORM-style surface
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

	// Hibernate 7 removed the legacy Criteria API (Session.createCriteria, org.hibernate.criterion.Projections),
	// the same row count goes through the JPA CriteriaBuilder
	ormSess = ORMGetSession();
	cb = ormSess.getCriteriaBuilder();
	q = cb.createQuery( createObject( "java", "java.lang.Class" ).forName( "java.lang.Long" ) );
	root = q.from( ormGetSessionFactory().getMetamodel().entity( "LDEV6390Entity" ) );
	q.select( cb.count( root ) );
	count = ormSess.createQuery( q ).getSingleResult();

	if ( count != 3 )
		throw( message="rowCount Criteria: expected 3, got [#count#]" );
	echo( "ok" );
</cfscript>
