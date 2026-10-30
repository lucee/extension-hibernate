<cfscript>
	// LDEV-6390 probe: what classloader does new ClassLoaderServiceImpl() pin,
	// and is it different from Lucee's TCCL?
	// the extension and Hibernate are Maven libraries, take the classloader of the live SessionFactory
	sf = ORMGetSessionFactory();
	bundleCL = sf.getClass().getClassLoader();
	clsServiceImpl = bundleCL.loadClass( "org.hibernate.boot.registry.classloading.internal.ClassLoaderServiceImpl" );
	if ( !clsServiceImpl.getClassLoader().equals( bundleCL ) )
		throw( message="ClassLoaderServiceImpl is not defined by the classloader of the SessionFactory" );
	tccl = createObject( "java", "java.lang.Thread" ).currentThread().getContextClassLoader();

	systemOutput( "", true );
	systemOutput( "[LDEV-6390 probe]", true );
	systemOutput( "  bundle CL class : " & bundleCL.getClass().getName(), true );
	systemOutput( "  bundle CL toStr : " & bundleCL.toString(), true );
	systemOutput( "  TCCL class      : " & tccl.getClass().getName(), true );
	systemOutput( "  TCCL toStr      : " & tccl.toString(), true );
	systemOutput( "  same instance?  : " & bundleCL.equals( tccl ), true );

	// Bundle CL can see Hibernate's lazy inner classes; TCCL deliberately cannot
	// (EnvClassLoader only resolves exported packages, and Hibernate's internal
	// org.hibernate.type.descriptor.jdbc package is not exported). This asymmetry
	// is by design — pre-LDEV-6390 was TCCL-only and worked because such classes
	// are reached via JVM-direct lookup from the defining Hibernate class, never
	// via Hibernate's ClassLoaderService.
	loaded = bundleCL.loadClass( "org.hibernate.type.descriptor.jdbc.DoubleJdbcType$2" );
	systemOutput( "  inner via bundle: " & loaded.getName() & " defined by " & loaded.getClassLoader().toString(), true );

	try {
		loadedTccl = tccl.loadClass( "org.hibernate.type.descriptor.jdbc.DoubleJdbcType$2" );
		systemOutput( "  inner via tccl  : " & loadedTccl.getName() & " defined by " & loadedTccl.getClassLoader().toString(), true );
	} catch ( any e ) {
		systemOutput( "  inner via tccl  : NOT VISIBLE (expected) — " & left( e.message, 100 ), true );
	}

	// Live SessionFactory's ClassLoaderService — what does IT delegate to?
	serviceRegistry = sf.getServiceRegistry();
	cls = serviceRegistry.getService( bundleCL.loadClass( "org.hibernate.boot.registry.classloading.spi.ClassLoaderService" ) );
	systemOutput( "  live svc class  : " & cls.getClass().getName(), true );

	// Trigger the entity-name lookup with a real CFC entity name. Hibernate 5 did this in
	// MetamodelImpl.getImplementors(), Hibernate 7 in JpaMetamodel.resolveHqlEntityReference(),
	// which also tries to load the name as a class first.
	metamodel = sf.getMetamodel();
	startMiss = createObject( "java", "java.lang.System" ).nanoTime();
	for ( i = 1; i <= 1000; i++ ) {
		ref = metamodel.resolveHqlEntityReference( "LDEV6390Entity" );
	}
	missNs = createObject( "java", "java.lang.System" ).nanoTime() - startMiss;
	systemOutput( "  1000x CFC miss  : " & ( missNs / 1000000 ) & " ms (entity=" & ref.getHibernateEntityName() & ")", true );
	if ( ref.getHibernateEntityName() != "LDEV6390Entity" )
		throw( message="resolveHqlEntityReference: expected [LDEV6390Entity], got [#ref.getHibernateEntityName()#]" );

	echo( "ok" );
</cfscript>
