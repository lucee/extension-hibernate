<cfscript>
	// LDEV-6390 probe: load Hibernate criteria classes via createObject.
	// Reproduces myleslee's 'bundle wiring for org.lucee.hibernate.extension is no longer valid'
	// reported against 5.6.15.18-SNAPSHOT when CBORM constructs Criteria/Projections.
	// Hibernate 7 removed org.hibernate.criterion.*; the criteria API is now the JPA
	// CriteriaBuilder (HibernateCriteriaBuilder) and the SQL type descriptors live in
	// org.hibernate.type.descriptor.jdbc.
	criteriaBuilder = createObject( "java", "org.hibernate.query.criteria.HibernateCriteriaBuilder" );
	jpaCriteriaBuilder = createObject( "java", "jakarta.persistence.criteria.CriteriaBuilder" );
	descriptor = createObject( "java", "org.hibernate.type.descriptor.jdbc.DoubleJdbcType" );
	echo( "ok" );
</cfscript>
