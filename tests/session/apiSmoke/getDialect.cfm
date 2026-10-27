<cfscript>
// Hibernate 7 removed SessionFactory.getDialect(); the dialect now lives on
// JdbcServices, accessed via the SessionFactoryImplementor.
dialect = ORMGetSessionFactory().getJdbcServices().getDialect();

className = dialect.getClass().getName();

if ( className does not contain "Dialect" )
	throw( message="Expected dialect class name to contain 'Dialect', got [#className#]" );

if ( className does not contain "H2" )
	throw( message="Expected H2 dialect for test datasource, got [#className#]" );

echo( "ok" );
</cfscript>
