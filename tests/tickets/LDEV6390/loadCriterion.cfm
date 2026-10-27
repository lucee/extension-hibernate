<cfscript>
	// the extension and Hibernate are Maven libraries, load them through the extension's Maven coordinate
	function hibernateArtifact() {
		var q = extensionList();
		loop query=q {
			if ( q.id == "FAD1E8CB-4F45-4184-86359145767C29DE" ) return "org.lucee:hibernate-extension:" & q.version;
		}
		throw( message="hibernate extension [FAD1E8CB-4F45-4184-86359145767C29DE] not found via extensionList()" );
	}

	// LDEV-6390 probe: load Hibernate criteria classes via createObject.
	// Reproduces myleslee's 'bundle wiring for org.lucee.hibernate.extension is no longer valid'
	// reported against 5.6.15.18-SNAPSHOT when CBORM constructs Criteria/Projections.
	// Hibernate 7 removed org.hibernate.criterion.*; the criteria API is now the JPA
	// CriteriaBuilder (HibernateCriteriaBuilder) and the SQL type descriptors live in
	// org.hibernate.type.descriptor.jdbc.
	criteriaBuilder = createObject( "java", "org.hibernate.query.criteria.HibernateCriteriaBuilder", { maven: [ hibernateArtifact() ] } );
	jpaCriteriaBuilder = createObject( "java", "jakarta.persistence.criteria.CriteriaBuilder", { maven: [ hibernateArtifact() ] } );
	descriptor = createObject( "java", "org.hibernate.type.descriptor.jdbc.DoubleJdbcType", { maven: [ hibernateArtifact() ] } );
	echo( "ok" );
</cfscript>
