package org.lucee.extension.orm.hibernate;

import java.lang.reflect.Modifier;
import java.net.JarURLConnection;
import java.net.URL;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

import org.lucee.extension.orm.hibernate.util.CommonUtil;

import lucee.commons.io.log.Log;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.db.DataSource;
import lucee.runtime.type.Struct;

/**
 * Hibernate Dialect manager
 */
public class Dialect {

	private Dialect() {}

	private static Struct dialects = CommonUtil.createStruct();

	static {

		try {
			// all dialect classes in the hibernate-core jar, Lucee loads it as a Maven library
			ClassLoader bcl = org.hibernate.dialect.SybaseDialect.class.getClassLoader();
			URL url = bcl.getResource("org/hibernate/dialect/SybaseDialect.class");
			JarURLConnection conn = (JarURLConnection) url.openConnection();
			conn.setUseCaches(false);
			try (JarFile jar = conn.getJarFile()) {
				Enumeration<JarEntry> e = jar.entries();
				String path = null;
				while (e.hasMoreElements()) {
					path = e.nextElement().getName();
					if (!path.startsWith("org/hibernate/dialect/") || !path.endsWith(".class")) continue;
					path = path.substring(0, path.length() - 6).replace('/', '.');
					try {
						String name;
						Class<?> clazz = bcl.loadClass(path);
						if (org.hibernate.dialect.Dialect.class.isAssignableFrom(clazz) && !Modifier.isAbstract(clazz.getModifiers())) {
							dialects.setEL(CommonUtil.createKey(path), path);
							name = CommonUtil.last(path, ".");
							dialects.setEL(CommonUtil.createKey(name), path);
							if (name.endsWith("Dialect")) {
								name = name.substring(0, name.length() - 7);
								dialects.setEL(CommonUtil.createKey(name), path);
							}
						}
					}
					catch (Throwable t) {
						// expected — dialects can have missing transitive deps across Hibernate versions
						Log log = CommonUtil.getORMLog();
						if ( log != null ) log.log( Log.LEVEL_DEBUG, "hibernate",
							"Skipping dialect class [" + path + "] that failed to load during the jar scan", t );
					}
				}
			}
		}
		catch (Exception ex) {
			// total scan failure — registered set limited to the hardcoded list below
			Log log = CommonUtil.getORMLog();
			if ( log != null ) log.log( Log.LEVEL_WARN, "hibernate",
				"Failed to scan the hibernate-core jar for Hibernate dialect classes; falling back to hardcoded list", ex );
		}

		// Hibernate 7.3 deleted all version-specific dialect classes; the surviving
		// per-vendor dialect detects the server version via JDBC metadata at SF build.
		// The jar scan above auto-registers what's actually in the core jar (FQN +
		// simple name + short name). Below: legacy aliases only — historical names
		// that no longer have a matching class, mapped to their surviving family.
		// Names from `hibernate-community-dialects` (Derby, Firebird, Informix, Ingres,
		// Teradata, TimesTen, CUBRID, Cache71, Mckoi, etc.) are intentionally absent —
		// we do not ship that artifact, so resolution returns null with a clear error.

		// Oracle — Oracle8i/9/9i/10g/12c all gone, only OracleDialect survives
		String oracle = "org.hibernate.dialect.OracleDialect";
		addLegacyAlias("Oracle8i", oracle);
		addLegacyAlias("Oracle9", oracle);
		addLegacyAlias("Oracle9i", oracle);
		addLegacyAlias("Oracle10g", oracle);
		addLegacyAlias("Oracle12c", oracle);
		addLegacyAlias("DataDirectOracle9", oracle);

		// SQLServer — 2005/2008/2012 all gone, only SQLServerDialect survives
		String sqlServer = "org.hibernate.dialect.SQLServerDialect";
		addLegacyAlias("SQLServer2005", sqlServer);
		addLegacyAlias("SQLServer2008", sqlServer);
		addLegacyAlias("SQLServer2012", sqlServer);

		// PostgreSQL — 81/82/9/91/92/93/94/95/10 all gone, only PostgreSQLDialect survives
		String postgres = "org.hibernate.dialect.PostgreSQLDialect";
		addLegacyAlias("PostgreSQL81", postgres);
		addLegacyAlias("PostgreSQL82", postgres);
		addLegacyAlias("PostgreSQL9", postgres);
		addLegacyAlias("PostgreSQL91", postgres);
		addLegacyAlias("PostgreSQL92", postgres);
		addLegacyAlias("PostgreSQL93", postgres);
		addLegacyAlias("PostgreSQL94", postgres);
		addLegacyAlias("PostgreSQL95", postgres);
		addLegacyAlias("PostgreSQL10", postgres);

		// MySQL — every version-specific dialect gone, only MySQLDialect survives (Stage 7h)
		String mysql = "org.hibernate.dialect.MySQLDialect";
		addLegacyAlias("MySQL5", mysql);
		addLegacyAlias("MySQL55", mysql);
		addLegacyAlias("MySQL57", mysql);
		addLegacyAlias("MySQL5InnoDB", mysql);
		addLegacyAlias("MySQL57InnoDB", mysql);
		addLegacyAlias("MySQL8", mysql);
		addLegacyAlias("MySQLInnoDB", mysql);
		addLegacyAlias("MySQLMyISAM", mysql);

		// MariaDB — 10/53/102/103 all gone, only MariaDBDialect survives
		String mariaDb = "org.hibernate.dialect.MariaDBDialect";
		addLegacyAlias("MariaDB10", mariaDb);
		addLegacyAlias("MariaDB53", mariaDb);
		addLegacyAlias("MariaDB102", mariaDb);
		addLegacyAlias("MariaDB103", mariaDb);

		// Sybase — Sybase11 / SybaseAnywhere gone; SybaseASE15/157 collapse to SybaseASEDialect
		String sybaseAse = "org.hibernate.dialect.SybaseASEDialect";
		addLegacyAlias("SybaseASE15", sybaseAse);
		addLegacyAlias("SybaseASE157", sybaseAse);
		String sybase = "org.hibernate.dialect.SybaseDialect";
		addLegacyAlias("Sybase11", sybase);
		addLegacyAlias("SybaseAnywhere", sybase);

		// HANA — Cloud/Column/Row variants gone, only HANADialect survives
		String hana = "org.hibernate.dialect.HANADialect";
		addLegacyAlias("HANACloudColumnStore", hana);
		addLegacyAlias("HANAColumnStore", hana);
		addLegacyAlias("HANARowStore", hana);

		// DB2 — DB2390(V8) → DB2zDialect, DB2400(V7R3) → DB2iDialect, DB297 → DB2Dialect
		String db2 = "org.hibernate.dialect.DB2Dialect";
		String db2i = "org.hibernate.dialect.DB2iDialect";
		String db2z = "org.hibernate.dialect.DB2zDialect";
		addLegacyAlias("DB297", db2);
		addLegacyAlias("DB2390", db2z);
		addLegacyAlias("DB2390V8", db2z);
		addLegacyAlias("DB2400", db2i);
		addLegacyAlias("DB2400V7R3", db2i);

		// Cockroach — CockroachDB192/201 gone, only CockroachDialect survives
		String cockroach = "org.hibernate.dialect.CockroachDialect";
		addLegacyAlias("CockroachDB192", cockroach);
		addLegacyAlias("CockroachDB201", cockroach);

	}

	/**
	 * Register a legacy alias under both its short form and its FQN form.
	 *
	 * Both <code>"MySQL5InnoDB"</code> and <code>"org.hibernate.dialect.MySQL5InnoDBDialect"</code>
	 * resolve to the same surviving target. The jar scan above only registers FQNs
	 * for classes that still exist in hibernate-core; users migrating from H5 who hard-coded
	 * the FQN of a since-removed dialect would otherwise see their setting silently dropped.
	 */
	private static void addLegacyAlias(String shortName, String target) {
		dialects.setEL(CommonUtil.createKey(shortName), target);
		dialects.setEL(CommonUtil.createKey("org.hibernate.dialect." + shortName + "Dialect"), target);
	}

	/**
	 * Get the Hibernate dialect for the given Datasource
	 *
	 * @param ds
	 *            - Datasource object to check dialect on
	 *
	 * @return the string dialect value, like "org.hibernate.dialect.PostgreSQLDialect"
	 */
	// currently unused
	public static String getDialect(DataSource ds) {
		String name = ds.getClassDefinition().getClassName();
		if ("net.sourceforge.jtds.jdbc.Driver".equalsIgnoreCase(name)) {
			String dsn = ds.getConnectionStringTranslated();
			if (dsn.toLowerCase().indexOf("sybase") != -1) return getDialect("Sybase");
			return getDialect("SQLServer");
		}
		return getDialect(name);
	}

	/**
	 * Return a SQL dialect that match the given Name
	 *
	 * @param name
	 *            - Dialect name like "Oracle" or "MySQL57"
	 *
	 * @return the full dialect string name, like "org.hibernate.dialect.OracleDialect" or
	 *         "org.hibernate.dialect.MySQL57Dialect"
	 */
	public static String getDialect(String name) {
		if (Util.isEmpty(name))
			return null;
		String dialect = (String) dialects.get(CommonUtil.createKey(name), null);
		return dialect;
	}

	/**
	 * Get all configurable dialects
	 *
	 * @return the configured dialects
	 */
	public static Struct getDialects() {
		return dialects;
	}

	/**
	 * Get an iterator of dialect key names
	 *
	 * @return a String iteratator to iterate over all known dialects
	 */
	public static Iterator<String> getDialectNames() {
		return dialects.keysAsStringIterator();
	}
}
