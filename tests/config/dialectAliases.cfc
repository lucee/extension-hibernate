component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function run( testResults, testBox ) {

		describe( "Dialect alias resolution (Hibernate 7.3)", function() {

			var dialectMgr  = createObject( "java", "org.lucee.extension.orm.hibernate.Dialect", "org.lucee.hibernate.extension" );
			var classLoader = dialectMgr.getClass().getClassLoader();
			var hbDialect   = classLoader.loadClass( "org.hibernate.dialect.Dialect" );

			// surviving short names — these should be picked up by the OSGi auto-scan
			// of org/hibernate/dialect/*.class in hibernate-core
			var survivors = {
				"H2"             : "org.hibernate.dialect.H2Dialect",
				"HSQL"           : "org.hibernate.dialect.HSQLDialect",
				"MySQL"          : "org.hibernate.dialect.MySQLDialect",
				"MariaDB"        : "org.hibernate.dialect.MariaDBDialect",
				"Oracle"         : "org.hibernate.dialect.OracleDialect",
				"PostgreSQL"     : "org.hibernate.dialect.PostgreSQLDialect",
				"PostgresPlus"   : "org.hibernate.dialect.PostgresPlusDialect",
				"SQLServer"      : "org.hibernate.dialect.SQLServerDialect",
				"AzureSQLServer" : "org.hibernate.dialect.AzureSQLServerDialect",
				"Sybase"         : "org.hibernate.dialect.SybaseDialect",
				"SybaseASE"      : "org.hibernate.dialect.SybaseASEDialect",
				"DB2"            : "org.hibernate.dialect.DB2Dialect",
				"DB2i"           : "org.hibernate.dialect.DB2iDialect",
				"DB2z"           : "org.hibernate.dialect.DB2zDialect",
				"HANA"           : "org.hibernate.dialect.HANADialect",
				"Cockroach"      : "org.hibernate.dialect.CockroachDialect",
				"Spanner"        : "org.hibernate.dialect.SpannerDialect"
			};

			// legacy aliases — historical names whose class was deleted in H7.3.
			// Each maps to its surviving family member.
			var legacyAliases = {
				// Oracle — all version-specific dialects gone
				"Oracle8i"             : "org.hibernate.dialect.OracleDialect",
				"Oracle9"              : "org.hibernate.dialect.OracleDialect",
				"Oracle9i"             : "org.hibernate.dialect.OracleDialect",
				"Oracle10g"            : "org.hibernate.dialect.OracleDialect",
				"Oracle12c"            : "org.hibernate.dialect.OracleDialect",
				"DataDirectOracle9"    : "org.hibernate.dialect.OracleDialect",
				// SQLServer
				"SQLServer2005"        : "org.hibernate.dialect.SQLServerDialect",
				"SQLServer2008"        : "org.hibernate.dialect.SQLServerDialect",
				"SQLServer2012"        : "org.hibernate.dialect.SQLServerDialect",
				// PostgreSQL
				"PostgreSQL81"         : "org.hibernate.dialect.PostgreSQLDialect",
				"PostgreSQL82"         : "org.hibernate.dialect.PostgreSQLDialect",
				"PostgreSQL9"          : "org.hibernate.dialect.PostgreSQLDialect",
				"PostgreSQL91"         : "org.hibernate.dialect.PostgreSQLDialect",
				"PostgreSQL92"         : "org.hibernate.dialect.PostgreSQLDialect",
				"PostgreSQL93"         : "org.hibernate.dialect.PostgreSQLDialect",
				"PostgreSQL94"         : "org.hibernate.dialect.PostgreSQLDialect",
				"PostgreSQL95"         : "org.hibernate.dialect.PostgreSQLDialect",
				"PostgreSQL10"         : "org.hibernate.dialect.PostgreSQLDialect",
				// MySQL — collapsed in Stage 7h
				"MySQL5"               : "org.hibernate.dialect.MySQLDialect",
				"MySQL55"              : "org.hibernate.dialect.MySQLDialect",
				"MySQL57"              : "org.hibernate.dialect.MySQLDialect",
				"MySQL5InnoDB"         : "org.hibernate.dialect.MySQLDialect",
				"MySQL57InnoDB"        : "org.hibernate.dialect.MySQLDialect",
				"MySQL8"               : "org.hibernate.dialect.MySQLDialect",
				"MySQLInnoDB"          : "org.hibernate.dialect.MySQLDialect",
				"MySQLMyISAM"          : "org.hibernate.dialect.MySQLDialect",
				// MariaDB
				"MariaDB10"            : "org.hibernate.dialect.MariaDBDialect",
				"MariaDB53"            : "org.hibernate.dialect.MariaDBDialect",
				"MariaDB102"           : "org.hibernate.dialect.MariaDBDialect",
				"MariaDB103"           : "org.hibernate.dialect.MariaDBDialect",
				// Sybase
				"Sybase11"             : "org.hibernate.dialect.SybaseDialect",
				"SybaseAnywhere"       : "org.hibernate.dialect.SybaseDialect",
				"SybaseASE15"          : "org.hibernate.dialect.SybaseASEDialect",
				"SybaseASE157"         : "org.hibernate.dialect.SybaseASEDialect",
				// HANA
				"HANACloudColumnStore" : "org.hibernate.dialect.HANADialect",
				"HANAColumnStore"      : "org.hibernate.dialect.HANADialect",
				"HANARowStore"         : "org.hibernate.dialect.HANADialect",
				// DB2
				"DB297"                : "org.hibernate.dialect.DB2Dialect",
				"DB2390"               : "org.hibernate.dialect.DB2zDialect",
				"DB2390V8"             : "org.hibernate.dialect.DB2zDialect",
				"DB2400"               : "org.hibernate.dialect.DB2iDialect",
				"DB2400V7R3"           : "org.hibernate.dialect.DB2iDialect",
				// Cockroach
				"CockroachDB192"       : "org.hibernate.dialect.CockroachDialect",
				"CockroachDB201"       : "org.hibernate.dialect.CockroachDialect"
			};

			// names that moved to hibernate-community-dialects (artifact we don't bundle).
			// Resolution should return null so callers get a clear error rather than
			// blowing up at SF build with ClassNotFoundException.
			var droppedCommunity = [
				"Derby", "DerbyTenFive", "DerbyTenSix", "DerbyTenSeven",
				"Firebird", "FrontBase", "Informix", "Informix10",
				"Ingres", "Ingres9", "Ingres10", "Interbase", "JDataStore",
				"Mckoi", "MimerSQL", "Pointbase", "Progress", "RDMSOS2200",
				"SAPDB", "Teradata", "Teradata14", "TimesTen", "CUBRID", "Cache71"
			];

			it( "every surviving family resolves via OSGi auto-scan", function() {
				var failures = [];
				for ( var name in survivors ) {
					var resolved = dialectMgr.getDialect( name );
					if ( isNull( resolved ) ) {
						arrayAppend( failures, "[#name#] resolved to null — OSGi scan missed it" );
					} else if ( resolved != survivors[ name ] ) {
						arrayAppend( failures, "[#name#] expected [#survivors[ name ]#] got [#resolved#]" );
					}
				}
				expect( failures ).toBeEmpty( "Surviving dialect short names did not resolve correctly: " & arrayToList( failures, "; " ) );
			});

			it( "every legacy alias resolves to its surviving family class", function() {
				var failures = [];
				for ( var alias in legacyAliases ) {
					var resolved = dialectMgr.getDialect( alias );
					if ( isNull( resolved ) ) {
						arrayAppend( failures, "[#alias#] resolved to null — alias not registered" );
					} else if ( resolved != legacyAliases[ alias ] ) {
						arrayAppend( failures, "[#alias#] expected [#legacyAliases[ alias ]#] got [#resolved#]" );
					}
				}
				expect( failures ).toBeEmpty( "Legacy aliases did not collapse correctly: " & arrayToList( failures, "; " ) );
			});

			it( "every registered FQN loads as a real Hibernate Dialect class", function() {
				// Walk the entire alias map. Each value must be a loadable class
				// AND a subclass of org.hibernate.dialect.Dialect — guards against
				// (a) typos in our alias map and (b) classes silently disappearing
				// in future Hibernate upgrades.
				var dialects = dialectMgr.getDialects();
				var seen     = {};
				var failures = [];
				var keys     = structKeyArray( dialects );
				for ( var k in keys ) {
					var fqn = dialects.get( k );
					if ( isNull( fqn ) || structKeyExists( seen, fqn ) ) continue;
					seen[ fqn ] = true;
					try {
						var clazz = classLoader.loadClass( fqn );
						if ( !hbDialect.isAssignableFrom( clazz ) ) {
							arrayAppend( failures, "[#fqn#] is not assignable to org.hibernate.dialect.Dialect" );
						}
					} catch ( any e ) {
						arrayAppend( failures, "[#fqn#] failed to load: #e.message#" );
					}
				}
				expect( failures ).toBeEmpty( "Registered dialect FQNs failed validation: " & arrayToList( failures, "; " ) );
			});

			it( "community-dialect names resolve to null (artifact not bundled)", function() {
				var stillRegistered = [];
				for ( var name in droppedCommunity ) {
					var resolved = dialectMgr.getDialect( name );
					if ( !isNull( resolved ) ) {
						arrayAppend( stillRegistered, "[#name#] still resolves to [#resolved#]" );
					}
				}
				expect( stillRegistered ).toBeEmpty( "Community-only dialects should not be registered: " & arrayToList( stillRegistered, "; " ) );
			});

			it( "lookup is case-insensitive", function() {
				expect( dialectMgr.getDialect( "h2"          ) ).toBe( "org.hibernate.dialect.H2Dialect" );
				expect( dialectMgr.getDialect( "MYSQL"       ) ).toBe( "org.hibernate.dialect.MySQLDialect" );
				expect( dialectMgr.getDialect( "oracle10G"   ) ).toBe( "org.hibernate.dialect.OracleDialect" );
				expect( dialectMgr.getDialect( "postgresql"  ) ).toBe( "org.hibernate.dialect.PostgreSQLDialect" );
			});

			it( "FQN passed in resolves to itself", function() {
				expect( dialectMgr.getDialect( "org.hibernate.dialect.OracleDialect" ) ).toBe( "org.hibernate.dialect.OracleDialect" );
				expect( dialectMgr.getDialect( "org.hibernate.dialect.MySQLDialect"  ) ).toBe( "org.hibernate.dialect.MySQLDialect" );
			});

			it( "empty / unknown names return null", function() {
				expect( isNull( dialectMgr.getDialect( ""             ) ) ).toBeTrue();
				expect( isNull( dialectMgr.getDialect( "DefinitelyNotADialect" ) ) ).toBeTrue();
			});

		});

	}

}
