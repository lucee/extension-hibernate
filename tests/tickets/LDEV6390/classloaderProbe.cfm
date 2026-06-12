<cfscript>
	// LDEV-6390 probe: what classloader does new ClassLoaderServiceImpl() pin,
	// and is it different from Lucee's TCCL?
	clsServiceImpl = createObject( "java", "org.hibernate.boot.registry.classloading.internal.ClassLoaderServiceImpl" );
	bundleCL = clsServiceImpl.getClass().getClassLoader();
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
	// org.hibernate.type.descriptor.sql package is not exported). This asymmetry
	// is by design — pre-LDEV-6390 was TCCL-only and worked because such classes
	// are reached via JVM-direct lookup from the defining Hibernate class, never
	// via Hibernate's ClassLoaderService.
	loaded = bundleCL.loadClass( "org.hibernate.type.descriptor.sql.DoubleTypeDescriptor$2" );
	systemOutput( "  inner via bundle: " & loaded.getName() & " defined by " & loaded.getClassLoader().toString(), true );

	try {
		loadedTccl = tccl.loadClass( "org.hibernate.type.descriptor.sql.DoubleTypeDescriptor$2" );
		systemOutput( "  inner via tccl  : " & loadedTccl.getName() & " defined by " & loadedTccl.getClassLoader().toString(), true );
	} catch ( any e ) {
		systemOutput( "  inner via tccl  : NOT VISIBLE (expected) — " & left( e.message, 100 ), true );
	}

	// Live SessionFactory's ClassLoaderService — what does IT delegate to?
	sf = ORMGetSessionFactory();
	serviceRegistry = sf.getServiceRegistry();
	cls = serviceRegistry.getService( bundleCL.loadClass( "org.hibernate.boot.registry.classloading.spi.ClassLoaderService" ) );
	systemOutput( "  live svc class  : " & cls.getClass().getName(), true );

	// Trigger MetamodelImpl.getImplementors() with a real CFC entity name (miss path)
	// and with a real Hibernate class (hit path) — measure throws via diff timings.
	metamodel = sf.getMetamodel();
	startMiss = createObject( "java", "java.lang.System" ).nanoTime();
	for ( i = 1; i <= 1000; i++ ) {
		impls = metamodel.getImplementors( "LDEV6390Entity" );
	}
	missNs = createObject( "java", "java.lang.System" ).nanoTime() - startMiss;
	systemOutput( "  1000x CFC miss  : " & ( missNs / 1000000 ) & " ms (impls=" & impls[ 1 ] & ")", true );

	echo( "ok" );
</cfscript>
