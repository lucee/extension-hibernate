package org.lucee.extension.orm.hibernate;
import org.lucee.extension.orm.hibernate.mapping.HBMCreator;

import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.util.HibernateUtil;
import org.lucee.extension.orm.hibernate.util.ORMConfigurationUtil;

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.hibernate.engine.jdbc.connections.spi.ConnectionProvider;
import org.hibernate.cfg.AvailableSettings;
import org.hibernate.cfg.Configuration;

import lucee.commons.io.log.Log;
import lucee.commons.io.res.Resource;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.type.Collection.Key;

public class HibernateSessionFactory {

	private HibernateSessionFactory() {}

	/**
	 * Generate the database schema based on the configured settings (dropcreate, update, etc.)
	 *
	 * @param log
	 *            Lucee logger object
	 * @param configuration
	 *            Hibernate configuration
	 * @param ds
	 *            Datasource
	 * @param user
	 *            Datasource username
	 * @param pass
	 *            Datasource password
	 * @param data
	 *            Session factory data container
	 *
	 * @throws PageException
	 * @throws SQLException
	 * @throws IOException
	 */
	public static void schemaExport(Log log, Configuration configuration, String xmlMappings, DataSource ds, String user, String pass, SessionFactoryData data)
			throws PageException, SQLException, IOException {
		ORMConfiguration ormConf = data.getORMConfiguration();

		// Hibernate 7 removed the standalone SchemaExport / SchemaUpdate execute() entry points
		// (the org.hibernate.tool.hbm2ddl package moved out of hibernate-core). We now just set
		// HBM2DDL_AUTO and let buildSessionFactory() drive schema work via the standard
		// SchemaManagementTool — same end result, no separate boot-time export pass.
		switch (ormConf.getDbCreate()) {
			case ORMConfiguration.DBCREATE_NONE:
				configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "none");
				return;
			case ORMConfiguration.DBCREATE_DROP_CREATE:
				configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "create");
				return;
			case 3 /* DBCREATE_CREATE */:
				configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "create-only");
				return;
			case 4 /* DBCREATE_CREATE_DROP */:
				configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "create-drop");
				return;
			case ORMConfiguration.DBCREATE_UPDATE:
				configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "update");
				return;
			case 5 /* DBCREATE_VALIDATE */:
				configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "validate");
				return;
			default:
				return;
		}
	}

	/**
	 * Auto-detect and set default catalog/schema from JDBC metadata if not already configured.
	 *
	 * NOT CURRENTLY CALLED — kept for the embedded warning. If you are tempted to
	 * call this from schemaExport(): don't. Setting DEFAULT_CATALOG on the Configuration's
	 * Properties leaks into the session factory's SQL generation, prefixing all table
	 * names with the catalog (e.g. DB.foo), which breaks MySQL/MSSQL. A Properties copy
	 * doesn't fully isolate because the ServiceRegistry builder may mutate the input map.
	 *
	 * Original motivation was HHH-10882 (H2 SchemaUpdate silently generating no DDL when
	 * default_catalog/default_schema were unset). That bug was fixed in Hibernate 7.3,
	 * so this approach is no longer needed for that case. The SQL-prefix problem is a
	 * separate Hibernate behaviour and remains.
	 *
	 * @see <a href="https://hibernate.atlassian.net/browse/HHH-10882">HHH-10882</a>
	 */
	private static void ensureDefaultCatalogAndSchema(java.util.Properties props, Log log) {
		String existingCatalog = (String) props.get(AvailableSettings.DEFAULT_CATALOG);
		String existingSchema = (String) props.get(AvailableSettings.DEFAULT_SCHEMA);
		if ( !Util.isEmpty(existingCatalog, true) && !Util.isEmpty(existingSchema, true) ) {
			return;
		}

		Object cpObj = props.get("hibernate.connection.provider_class");
		if ( !(cpObj instanceof ConnectionProvider) ) return;

		ConnectionProvider cp = (ConnectionProvider) cpObj;
		try {
			Connection conn = cp.getConnection();
			try {
				// DatasourceConnection wraps the real JDBC connection — unwrap to get
				// reliable getCatalog()/getSchema() which may not be delegated
				Connection raw = conn;
				if ( conn instanceof DatasourceConnection ) {
					raw = ((DatasourceConnection) conn).getConnection();
				}
				if ( Util.isEmpty(existingCatalog, true) ) {
					String catalog = raw.getCatalog();
					if ( !Util.isEmpty(catalog, true) ) {
						props.setProperty(AvailableSettings.DEFAULT_CATALOG, catalog);
						log.log(Log.LEVEL_DEBUG, "hibernate", "Auto-detected default catalog [" + catalog + "] for schema tools");
					}
				}
				if ( Util.isEmpty(existingSchema, true) ) {
					String schema = raw.getSchema();
					if ( !Util.isEmpty(schema, true) ) {
						props.setProperty(AvailableSettings.DEFAULT_SCHEMA, schema);
						log.log(Log.LEVEL_DEBUG, "hibernate", "Auto-detected default schema [" + schema + "] for schema tools");
					}
				}
			} finally {
				cp.closeConnection(conn);
			}
		} catch (Exception e) {
			log.log(Log.LEVEL_WARN, "hibernate", "Failed to auto-detect default catalog/schema: " + e.getMessage());
		}
	}

	/**
	 * Execute the ormSettings.sqlScript file against the given datasource, if configured.
	 * Called after buildSessionFactory() so HBM2DDL_AUTO has finished schema creation.
	 */
	public static void runSqlScript(ORMConfiguration ormConf, DataSource ds) throws SQLException, IOException, PageException {
		Resource sqlScript = ORMConfigurationUtil.getSqlScript(ormConf, ds.getName());
		if (sqlScript == null || !sqlScript.isFile()) return;

		PageContext pc = CFMLEngineFactory.getInstance().getThreadPageContext();
		DatasourceConnection dc = CommonUtil.getDatasourceConnection(pc, ds, null, null, true);
		try (BufferedReader br = CommonUtil.toBufferedReader(sqlScript, (Charset) null)) {
			Statement stat = dc.getConnection().createStatement();
			try {
				String line;
				StringBuilder sql = new StringBuilder();
				while ((line = br.readLine()) != null) {
					line = line.trim();
					if (line.startsWith("//") || line.startsWith("--")) continue;
					if (line.endsWith(";")) {
						sql.append(line.substring(0, line.length() - 1));
						String str = sql.toString().trim();
						if (str.length() > 0) stat.execute(str);
						sql = new StringBuilder();
					}
					else {
						sql.append(line).append(" ");
					}
				}
				String str = sql.toString().trim();
				if (str.length() > 0) stat.execute(str);
			}
			finally {
				CFMLEngineFactory.getInstance().getDBUtil().closeSilent(stat);
				CommonUtil.releaseDatasourceConnection(pc, dc, true);
			}
		}
	}

	public static Map<Key, String> assembleMappingsByDatasource(SessionFactoryData data) {
		Map<Key, String> mappings = new HashMap<Key, String>();
		Iterator<Entry<Key, Map<String, CFCInfo>>> it = data.getCFCs().entrySet().iterator();
		while (it.hasNext()) {
			Entry<Key, Map<String, CFCInfo>> e = it.next();

			Set<String> done = new HashSet<String>();
			StringBuilder mapping = new StringBuilder();
			mapping.append(HBMCreator.getXMLOpen());
			mapping.append("<hibernate-mapping>");
			Iterator<Entry<String, CFCInfo>> _it = e.getValue().entrySet().iterator();
			_it.forEachRemaining(entry -> {
				mapping.append(assembleMappingForCFC(entry.getKey(), entry.getValue(), done, data));
			});
			mapping.append("</hibernate-mapping>");
			mappings.put(e.getKey(), mapping.toString());
		}
		return mappings;
	}

	private static String assembleMappingForCFC(String key, CFCInfo value, Set<String> done, SessionFactoryData data) {
		if (done.contains(key))
			return "";
		CFCInfo v;
		StringBuilder mappings = new StringBuilder();
		String ext = value.getCFC().getExtends();
		if (!Util.isEmpty(ext)) {
			// LDEV-6340: mappedSuperClass / persistent="false" / non-CFC parents
			// legitimately aren't registered as entities — their properties get
			// inlined by HBMCreator.loadForeignCFC during HBM generation, so
			// there's no parent <class> to prepend here. Don't throw, don't log.
			Component parent = data.getEntityByCFCName(ext, false, null);
			if (parent != null) {
				ext = HibernateCaster.getEntityName(parent);
			}

			ext = HibernateUtil.id(CommonUtil.last(ext, ".").trim());
			// LDEV-91: a parent that is not an entity (e.g. mappedSuperClass) can have the same
			// file name as the child, then the name lookup resolves to the child itself
			if (!done.contains(ext) && !ext.equals(key)) {
				v = data.getCFC(ext, null);
				if (v != null) {
					mappings.append(HBMCreator.stripXMLOpenClose(assembleMappingForCFC(ext, v, done, data)));
				}
			}
		}

		mappings.append(HBMCreator.stripXMLOpenClose(value.getXML()));
		done.add(key);
		return mappings.toString();
	}

}
