package org.lucee.extension.orm.hibernate;

import java.lang.reflect.Modifier;
import java.net.URL;
import java.util.Enumeration;
import java.util.Iterator;

import org.apache.felix.framework.BundleWiringImpl.BundleClassLoader;
import org.osgi.framework.Bundle;

import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.db.DataSource;
import lucee.runtime.type.Struct;
import lucee.runtime.util.ListUtil;

public class Dialect {
	private static Struct dialects = CommonUtil.createStruct();

	static {

		try {
			BundleClassLoader bcl = (BundleClassLoader) org.hibernate.dialect.SybaseDialect.class.getClassLoader();
			Bundle b = bcl.getBundle();

			// List all XML files in the OSGI-INF directory and below
			ListUtil util = CFMLEngineFactory.getInstance().getListUtil();
			Enumeration<URL> e = b.findEntries("org/hibernate/dialect", "*.class", true);
			String path;
			while (e.hasMoreElements()) {
				try {
					path = e.nextElement().getPath();
					if (path.startsWith("/")) path = path.substring(1);
					else if (path.startsWith("\\")) path = path.substring(1);
					if (path.endsWith(".class")) path = path.substring(0, path.length() - 6);
					path = path.replace('/', '.');
					path = path.replace('\\', '.');
					String name;
					Class<?> clazz = bcl.loadClass(path);
					if (org.hibernate.dialect.Dialect.class.isAssignableFrom(clazz) && !Modifier.isAbstract(clazz.getModifiers())) {
						dialects.setEL(CommonUtil.createKey(path), path);
						dialects.setEL(CommonUtil.createKey(CommonUtil.last(path, ".")), path);
						name = CommonUtil.last(path, ".");
						dialects.setEL(CommonUtil.createKey(name), path);
						if (name.endsWith("Dialect")) {
							name = name.substring(0, name.length() - 7);
							dialects.setEL(CommonUtil.createKey(name), path);
						}

						// print.e("dialects.setEL(\"" + name + "\",\"" + path + "\");");
					}
				}
				catch (Exception exx) {
					exx.printStackTrace();
				}
			}
		}
		catch (Exception ex) {
			ex.printStackTrace();
		}
		dialects.setEL("CUBRID", "org.hibernate.dialect.CUBRIDDialect");
		dialects.setEL("Cache71", "org.hibernate.dialect.Cache71Dialect");
		dialects.setEL("CockroachDB192", "org.hibernate.dialect.CockroachDB192Dialect");
		dialects.setEL("CockroachDB201", "org.hibernate.dialect.CockroachDB201Dialect");
		dialects.setEL("DB2390", "org.hibernate.dialect.DB2390Dialect");
		dialects.setEL("DB2390V8", "org.hibernate.dialect.DB2390V8Dialect");
		dialects.setEL("DB2400", "org.hibernate.dialect.DB2400Dialect");
		dialects.setEL("DB2400V7R3", "org.hibernate.dialect.DB2400V7R3Dialect");
		dialects.setEL("DB297", "org.hibernate.dialect.DB297Dialect");
		dialects.setEL("DB2", "org.hibernate.dialect.DB2Dialect");
		dialects.setEL("DataDirectOracle9", "org.hibernate.dialect.DataDirectOracle9Dialect");
		dialects.setEL("Derby", "org.hibernate.dialect.DerbyDialect");
		dialects.setEL("DerbyTenFive", "org.hibernate.dialect.DerbyTenFiveDialect");
		dialects.setEL("DerbyTenSeven", "org.hibernate.dialect.DerbyTenSevenDialect");
		dialects.setEL("DerbyTenSix", "org.hibernate.dialect.DerbyTenSixDialect");
		dialects.setEL("Firebird", "org.hibernate.dialect.FirebirdDialect");
		dialects.setEL("FrontBase", "org.hibernate.dialect.FrontBaseDialect");
		dialects.setEL("H2", "org.hibernate.dialect.H2Dialect");
		dialects.setEL("HANACloudColumnStore", "org.hibernate.dialect.HANACloudColumnStoreDialect");
		dialects.setEL("HANAColumnStore", "org.hibernate.dialect.HANAColumnStoreDialect");
		dialects.setEL("HANARowStore", "org.hibernate.dialect.HANARowStoreDialect");
		dialects.setEL("HSQL", "org.hibernate.dialect.HSQLDialect");
		dialects.setEL("Informix10", "org.hibernate.dialect.Informix10Dialect");
		dialects.setEL("Informix", "org.hibernate.dialect.InformixDialect");
		dialects.setEL("Ingres10", "org.hibernate.dialect.Ingres10Dialect");
		dialects.setEL("Ingres9", "org.hibernate.dialect.Ingres9Dialect");
		dialects.setEL("Ingres", "org.hibernate.dialect.IngresDialect");
		dialects.setEL("Interbase", "org.hibernate.dialect.InterbaseDialect");
		dialects.setEL("JDataStore", "org.hibernate.dialect.JDataStoreDialect");
		dialects.setEL("MariaDB102", "org.hibernate.dialect.MariaDB102Dialect");
		dialects.setEL("MariaDB103", "org.hibernate.dialect.MariaDB103Dialect");
		dialects.setEL("MariaDB10", "org.hibernate.dialect.MariaDB10Dialect");
		dialects.setEL("MariaDB53", "org.hibernate.dialect.MariaDB53Dialect");
		dialects.setEL("MariaDB", "org.hibernate.dialect.MariaDBDialect");
		dialects.setEL("Mckoi", "org.hibernate.dialect.MckoiDialect");
		dialects.setEL("MimerSQL", "org.hibernate.dialect.MimerSQLDialect");
		dialects.setEL("MySQL55", "org.hibernate.dialect.MySQL55Dialect");
		dialects.setEL("MySQL57", "org.hibernate.dialect.MySQL57Dialect");
		dialects.setEL("MySQL57InnoDB", "org.hibernate.dialect.MySQL57InnoDBDialect");
		dialects.setEL("MySQL5", "org.hibernate.dialect.MySQL5Dialect");
		dialects.setEL("MySQL5InnoDB", "org.hibernate.dialect.MySQL5InnoDBDialect");
		dialects.setEL("MySQL8", "org.hibernate.dialect.MySQL8Dialect");
		dialects.setEL("MySQL", "org.hibernate.dialect.MySQL8Dialect");
		dialects.setEL("MySQLInnoDB", "org.hibernate.dialect.MySQLInnoDBDialect");
		dialects.setEL("MySQLMyISAM", "org.hibernate.dialect.MySQLMyISAMDialect");
		dialects.setEL("Oracle10g", "org.hibernate.dialect.Oracle10gDialect");
		dialects.setEL("Oracle12c", "org.hibernate.dialect.Oracle12cDialect");
		dialects.setEL("Oracle8i", "org.hibernate.dialect.Oracle8iDialect");
		dialects.setEL("Oracle9", "org.hibernate.dialect.Oracle9Dialect");
		dialects.setEL("Oracle9i", "org.hibernate.dialect.Oracle9iDialect");
		dialects.setEL("Oracle", "org.hibernate.dialect.OracleDialect");
		dialects.setEL("Pointbase", "org.hibernate.dialect.PointbaseDialect");
		dialects.setEL("PostgreSQL10", "org.hibernate.dialect.PostgreSQL10Dialect");
		dialects.setEL("PostgreSQL81", "org.hibernate.dialect.PostgreSQL81Dialect");
		dialects.setEL("PostgreSQL82", "org.hibernate.dialect.PostgreSQL82Dialect");
		dialects.setEL("PostgreSQL91", "org.hibernate.dialect.PostgreSQL91Dialect");
		dialects.setEL("PostgreSQL92", "org.hibernate.dialect.PostgreSQL92Dialect");
		dialects.setEL("PostgreSQL93", "org.hibernate.dialect.PostgreSQL93Dialect");
		dialects.setEL("PostgreSQL94", "org.hibernate.dialect.PostgreSQL94Dialect");
		dialects.setEL("PostgreSQL95", "org.hibernate.dialect.PostgreSQL95Dialect");
		dialects.setEL("PostgreSQL9", "org.hibernate.dialect.PostgreSQL9Dialect");
		dialects.setEL("PostgreSQL", "org.hibernate.dialect.PostgreSQLDialect");
		dialects.setEL("PostgresPlus", "org.hibernate.dialect.PostgresPlusDialect");
		dialects.setEL("Progress", "org.hibernate.dialect.ProgressDialect");
		dialects.setEL("RDMSOS2200", "org.hibernate.dialect.RDMSOS2200Dialect");
		dialects.setEL("SAPDB", "org.hibernate.dialect.SAPDBDialect");
		dialects.setEL("SQLServer2005", "org.hibernate.dialect.SQLServer2005Dialect");
		dialects.setEL("SQLServer2008", "org.hibernate.dialect.SQLServer2008Dialect");
		dialects.setEL("SQLServer2012", "org.hibernate.dialect.SQLServer2012Dialect");
		dialects.setEL("SQLServer", "org.hibernate.dialect.SQLServerDialect");
		dialects.setEL("Sybase11", "org.hibernate.dialect.Sybase11Dialect");
		dialects.setEL("SybaseASE157", "org.hibernate.dialect.SybaseASE157Dialect");
		dialects.setEL("SybaseASE15", "org.hibernate.dialect.SybaseASE15Dialect");
		dialects.setEL("SybaseAnywhere", "org.hibernate.dialect.SybaseAnywhereDialect");
		dialects.setEL("Sybase", "org.hibernate.dialect.SybaseDialect");
		dialects.setEL("Teradata14", "org.hibernate.dialect.Teradata14Dialect");
		dialects.setEL("Teradata", "org.hibernate.dialect.TeradataDialect");
		dialects.setEL("TimesTen", "org.hibernate.dialect.TimesTenDialect");

	}

	/**
	 * return a SQL dialect that match the given Name
	 * 
	 * @param name
	 * @return
	 */
	public static String getDialect(DataSource ds) {
		String name = ds.getClassDefinition().getClassName();
		if ("net.sourceforge.jtds.jdbc.Driver".equalsIgnoreCase(name)) {
			String dsn = ds.getDsnTranslated();
			if (dsn.toLowerCase().indexOf("sybase") != -1) return getDialect("Sybase");
			return getDialect("SQLServer");
		}
		return getDialect(name);
	}

	public static String getDialect(String name) {
		String d = _getDialect(name);

		// print.e(name + ":" + d);
		return d;
	}

	public static String _getDialect(String name) {
		if (Util.isEmpty(name)) return null;
		String dialect = (String) dialects.get(CommonUtil.createKey(name), null);
		return dialect;
	}

	public static Iterator<String> getDialectNames() {
		return dialects.keysAsStringIterator();
	}
}
