package org.lucee.extension.orm.hibernate;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Properties;
import java.util.Set;

import org.hibernate.MappingException;
import org.hibernate.boot.MetadataSources;
import org.hibernate.boot.registry.BootstrapServiceRegistry;
import org.hibernate.boot.registry.BootstrapServiceRegistryBuilder;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;
import org.hibernate.cache.ehcache.internal.EhcacheRegionFactory;
import org.hibernate.cfg.AvailableSettings;
import org.hibernate.cfg.Configuration;
import org.hibernate.cfg.Environment;
import org.hibernate.service.ServiceRegistry;
import org.hibernate.tool.hbm2ddl.SchemaExport;
import org.hibernate.tool.hbm2ddl.SchemaExport.Action;
import org.hibernate.tool.hbm2ddl.SchemaUpdate;
import org.hibernate.tool.schema.TargetType;
import org.lucee.extension.orm.hibernate.jdbc.ConnectionProviderImpl;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import lucee.commons.io.log.Log;
import lucee.commons.io.res.Resource;
import lucee.commons.io.res.filter.ResourceFilter;
import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.InterfacePage;
import lucee.runtime.Mapping;
import lucee.runtime.Page;
import lucee.runtime.PageContext;
import lucee.runtime.PageSource;
import lucee.runtime.config.Config;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.exp.PageException;
import lucee.runtime.listener.ApplicationContext;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.util.TemplateUtil;

public class HibernateSessionFactory {

	public static final String HIBERNATE_3_PUBLIC_ID = "-//Hibernate/Hibernate Mapping DTD 3.0//EN";
	public static final String HIBERNATE_3_SYSTEM_ID = "http://hibernate.sourceforge.net/hibernate-mapping-3.0.dtd";
	public static final String HIBERNATE_3_DOCTYPE_DEFINITION = "<!DOCTYPE hibernate-mapping PUBLIC \"" + HIBERNATE_3_PUBLIC_ID + "\" \"" + HIBERNATE_3_SYSTEM_ID + "\">";

	public static Configuration createConfiguration(Log log, String mappings, DataSource ds, String user, String pass, SessionFactoryData data, String applicationContextName)
			throws SQLException, IOException, PageException {
		ORMConfiguration ormConf = data.getORMConfiguration();

		// dialect
		String dialect = null;
		String tmpDialect = ORMConfigurationUtil.getDialect(ormConf, ds.getName());
		if (!Util.isEmpty(tmpDialect)) dialect = Dialect.getDialect(tmpDialect);
		if (dialect != null && Util.isEmpty(dialect)) dialect = null;

		// Cache Provider
		String cacheProvider = ormConf.getCacheProvider();
		Class<?> cacheProviderFactory = null;

		if (Util.isEmpty(cacheProvider) || "EHCache".equalsIgnoreCase(cacheProvider)) {
			cacheProviderFactory = EhcacheRegionFactory.class;
		}
		// else if ("JBossCache".equalsIgnoreCase(cacheProvider)) cacheProvider =
		// "org.hibernate.cache.TreeCacheProvider";
		// else if ("HashTable".equalsIgnoreCase(cacheProvider)) cacheProvider =
		// "org.hibernate.cache.HashtableCacheProvider";
		// else if ("SwarmCache".equalsIgnoreCase(cacheProvider)) cacheProvider =
		// "org.hibernate.cache.SwarmCacheProvider";
		// else if ("OSCache".equalsIgnoreCase(cacheProvider)) cacheProvider =
		// "org.hibernate.cache.OSCacheProvider";

		/// JBossCache -> https://mvnrepository.com/artifact/org.hibernate/hibernate-jbosscache
		// OSCache -> https://mvnrepository.com/artifact/org.hibernate/hibernate-oscache
		// SwarmCache -> https://mvnrepository.com/artifact/org.hibernate/hibernate-swarmcache

		Resource cc = ormConf.getCacheConfig();

		BootstrapServiceRegistry bootstrapRegistry = new BootstrapServiceRegistryBuilder().applyIntegrator(data.getEventListenerIntegrator()).build();

		Configuration configuration = new Configuration(bootstrapRegistry);

		// is ehcache
		Resource cacheConfig = null;
		if (cacheProvider != null && cacheProvider.toLowerCase().indexOf("ehcache") != -1) {
			CFMLEngine eng = CFMLEngineFactory.getInstance();
			String varName = eng.getCastUtil().toVariableName(applicationContextName, applicationContextName);
			String xml;
			if (cc == null || !cc.isFile()) {
				cacheConfig = eng.getResourceUtil().getTempDirectory().getRealResource("ehcache/" + varName + ".xml");
				xml = createEHConfigXML(varName);
			}
			// we need to change or set the name
			else {
				String b64 = varName + eng.getSystemUtil().hash64b(CommonUtil.toString(cc, (Charset) null));
				cacheConfig = eng.getResourceUtil().getTempDirectory().getRealResource("ehcache/" + b64 + ".xml");
				Document doc = CommonUtil.toDocument(cc, null);
				Element root = doc.getDocumentElement();
				root.setAttribute("name", b64);

				xml = CommonUtil.toString(root, false, true, null, null, CommonUtil.UTF8().name());
			}

			if (!cacheConfig.isFile()) {
				cacheConfig.getParentResource().mkdirs();
				eng.getIOUtil().write(cacheConfig, xml, false, null);
			}
		}

		// ormConfig
		Resource conf = ormConf.getOrmConfig();
		if (conf != null) {
			try {
				Document doc = CommonUtil.toDocument(conf, null);
				configuration.configure(doc);
			}
			catch (Exception e) {
				log.log(Log.LEVEL_ERROR, "hibernate", e);

			}
		}

		try {
			configuration.addInputStream(new ByteArrayInputStream(mappings.getBytes("UTF-8")));
		}
		catch (MappingException me) {
			throw ExceptionUtil.createException(data, null, me);
		}

		configuration.setProperty(AvailableSettings.FLUSH_BEFORE_COMPLETION, "false")

				.setProperty(AvailableSettings.ALLOW_UPDATE_OUTSIDE_TRANSACTION, "true")

				.setProperty(AvailableSettings.AUTO_CLOSE_SESSION, "false");

		setProperty(configuration, Environment.CONNECTION_PROVIDER, new ConnectionProviderImpl(ds, user, pass));

		// SQL dialect
		if (dialect != null) configuration.setProperty(AvailableSettings.DIALECT, dialect);
		// Enable Hibernate's current session context
		configuration.setProperty(AvailableSettings.CURRENT_SESSION_CONTEXT_CLASS, "thread")

				// Echo all executed SQL to stdout
				.setProperty(AvailableSettings.SHOW_SQL, CommonUtil.toString(ormConf.logSQL())).setProperty("hibernate.format_sql", CommonUtil.toString(ormConf.logSQL()))
				// formatting of SQL logged to the console
				.setProperty(AvailableSettings.FORMAT_SQL, CommonUtil.toString(ormConf.logSQL())).setProperty("hibernate.format_sql", CommonUtil.toString(ormConf.logSQL()))
				// Specifies whether secondary caching should be enabled
				.setProperty(AvailableSettings.USE_SECOND_LEVEL_CACHE, CommonUtil.toString(ormConf.secondaryCacheEnabled()))
				// Drop and re-create the database schema on startup
				.setProperty("hibernate.exposeTransactionAwareSessionFactory", "false")
				// .setProperty("hibernate.hbm2ddl.auto", "create")
				.setProperty(AvailableSettings.DEFAULT_ENTITY_MODE, "dynamic-map");

		String catalog = ORMConfigurationUtil.getCatalog(ormConf, ds.getName());
		String schema = ORMConfigurationUtil.getSchema(ormConf, ds.getName());

		if (!Util.isEmpty(catalog)) configuration.setProperty("hibernate.default_catalog", catalog);
		if (!Util.isEmpty(schema)) configuration.setProperty("hibernate.default_schema", schema);

		if (ormConf.secondaryCacheEnabled()) {
			if (cacheConfig != null && cacheConfig.isFile()) {
				configuration.setProperty("hibernate.cache.provider_configuration_file_resource_path", cacheConfig.getAbsolutePath());
				configuration.setProperty("cache.provider_configuration_file_resource_path", cacheConfig.getAbsolutePath());
				if (cacheConfig instanceof File) configuration.setProperty("net.sf.ehcache.configurationResourceName", ((File) cacheConfig).toURI().toURL().toExternalForm());
				else throw new IOException("only local configuration files are supported");

			}

			if (cacheProviderFactory != null) {
				setProperty(configuration, AvailableSettings.CACHE_REGION_FACTORY, cacheProviderFactory);
			}
			// AvailableSettings.CACHE_REGION_FACTORY
			// hibernate.cache.region.factory_class
			// hibernate.cache.use_second_level_cache

			// <property
			// name="hibernate.cache.region.factory_class">org.hibernate.cache.ehcache.EhCacheRegionFactory</property>
			// <property name="hibernate.cache.provider_class">org.hibernate.cache.EhCacheProvider</property>

			configuration.setProperty("hibernate.cache.use_query_cache", "true");
			// <prop
			// key="hibernate.cache.provider_configuration_file_resource_path">hibernate-ehcache.xml</prop>

			// hibernate.cache.provider_class=org.hibernate.cache.EhCacheProvider
		}

		schemaExport(log, configuration, ds, user, pass, data);

		return configuration;
	}

	private static void setProperty(Configuration configuration, String name, Object value) {
		Properties props = new Properties();
		props.put(name, value);
		configuration.addProperties(props);
	}

	private static String createEHConfigXML(String cacheName) {
		return new StringBuilder().append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>").append("<ehcache").append("    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"")
				.append("    xsi:noNamespaceSchemaLocation=\"ehcache.xsd\"").append("    updateCheck=\"true\" name=\"" + cacheName + "\">")
				.append("    <diskStore path=\"java.io.tmpdir\"/>").append("    <defaultCache").append("            maxElementsInMemory=\"10000\"")
				.append("            eternal=\"false\"").append("            timeToIdleSeconds=\"120\"").append("            timeToLiveSeconds=\"120\"")
				.append("            maxElementsOnDisk=\"10000000\"").append("            diskExpiryThreadIntervalSeconds=\"120\"")
				.append("            memoryStoreEvictionPolicy=\"LRU\">").append("        <persistence strategy=\"localTempSwap\"/>").append("    </defaultCache>")
				.append("</ehcache>").toString();
	}

	private static void schemaExport(Log log, Configuration configuration, DataSource ds, String user, String pass, SessionFactoryData data)
			throws PageException, SQLException, IOException {
		ORMConfiguration ormConf = data.getORMConfiguration();

		ServiceRegistry serviceRegistry = new StandardServiceRegistryBuilder().applySettings(configuration.getProperties()).build();

		MetadataSources metadata = new MetadataSources(serviceRegistry);
		EnumSet<TargetType> enumSet = EnumSet.of(TargetType.DATABASE);

		if (ORMConfiguration.DBCREATE_NONE == ormConf.getDbCreate()) {
			configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "none");
			return;
		}
		else if (ORMConfiguration.DBCREATE_DROP_CREATE == ormConf.getDbCreate()) {
			configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "create");
			SchemaExport export = new SchemaExport();
			export.setHaltOnError(true);
			export.execute(enumSet, Action.BOTH, metadata.buildMetadata());
			printError(log, data, export.getExceptions(), false);
			executeSQLScript(ormConf, ds, user, pass);
		}
		else if (/* ORMConfiguration.DBCREATE_CREATE */3 == ormConf.getDbCreate()) {
			configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "create-only");
			SchemaExport export = new SchemaExport();
			export.setHaltOnError(true);
			export.execute(enumSet, Action.CREATE, metadata.buildMetadata());
			printError(log, data, export.getExceptions(), false);
			executeSQLScript(ormConf, ds, user, pass);
		}
		else if (/* ORMConfiguration.DBCREATE_CREATE_DROP */4 == ormConf.getDbCreate()) {
			configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "create-drop");
			SchemaExport export = new SchemaExport();
			export.setHaltOnError(true);
			export.execute(enumSet, Action.BOTH, metadata.buildMetadata());
			printError(log, data, export.getExceptions(), false);
			executeSQLScript(ormConf, ds, user, pass);
		}
		else if (ORMConfiguration.DBCREATE_UPDATE == ormConf.getDbCreate()) {
			configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "update");
			SchemaUpdate update = new SchemaUpdate();
			update.setHaltOnError(true);
			update.execute(enumSet, metadata.buildMetadata());
			printError(log, data, update.getExceptions(), false);
		}
	}

	private static void printError(Log log, SessionFactoryData data, List<Exception> exceptions, boolean throwException) throws PageException {
		if (exceptions == null || exceptions.size() == 0) return;
		Iterator<Exception> it = exceptions.iterator();
		if (!throwException || exceptions.size() > 1) {
			while (it.hasNext()) {
				log.log(Log.LEVEL_ERROR, "hibernate", it.next());
			}
		}
		if (!throwException) return;

		it = exceptions.iterator();
		while (it.hasNext()) {
			throw ExceptionUtil.createException(data, null, it.next());
		}
	}

	private static void executeSQLScript(ORMConfiguration ormConf, DataSource ds, String user, String pass) throws SQLException, IOException, PageException {
		Resource sqlScript = ORMConfigurationUtil.getSqlScript(ormConf, ds.getName());
		if (sqlScript != null && sqlScript.isFile()) {
			BufferedReader br = CommonUtil.toBufferedReader(sqlScript, (Charset) null);
			String line;
			StringBuilder sql = new StringBuilder();
			String str;
			Statement stat = null;
			PageContext pc = CFMLEngineFactory.getInstance().getThreadPageContext();
			DatasourceConnection dc = CommonUtil.getDatasourceConnection(pc, ds, user, pass, true);
			try {

				stat = dc.getConnection().createStatement();
				while ((line = br.readLine()) != null) {
					line = line.trim();
					if (line.startsWith("//") || line.startsWith("--")) continue;
					if (line.endsWith(";")) {
						sql.append(line.substring(0, line.length() - 1));
						str = sql.toString().trim();
						if (str.length() > 0) stat.execute(str);
						sql = new StringBuilder();
					}
					else {
						sql.append(line).append(" ");
					}
				}
				str = sql.toString().trim();
				if (str.length() > 0) {
					stat.execute(str);
				}
			}
			finally {
				CFMLEngineFactory.getInstance().getDBUtil().closeSilent(stat);
				CommonUtil.releaseDatasourceConnection(pc, dc, true);
			}
		}
	}

	public static Map<Key, String> createMappings(ORMConfiguration ormConf, SessionFactoryData data) {
		Map<Key, String> mappings = new HashMap<Key, String>();
		Iterator<Entry<Key, Map<String, CFCInfo>>> it = data.getCFCs().entrySet().iterator();
		while (it.hasNext()) {
			Entry<Key, Map<String, CFCInfo>> e = it.next();

			Set<String> done = new HashSet<String>();
			StringBuilder mapping = new StringBuilder();
			mapping.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
			mapping.append(HIBERNATE_3_DOCTYPE_DEFINITION + "\n");
			mapping.append("<hibernate-mapping>\n");
			Iterator<Entry<String, CFCInfo>> _it = e.getValue().entrySet().iterator();
			Entry<String, CFCInfo> entry;
			while (_it.hasNext()) {
				entry = _it.next();
				createMappings(ormConf, entry.getKey(), entry.getValue(), done, mapping, data);

			}
			mapping.append("</hibernate-mapping>");
			mappings.put(e.getKey(), mapping.toString());
		}
		return mappings;
	}

	private static void createMappings(ORMConfiguration ormConf, String key, CFCInfo value, Set<String> done, StringBuilder mappings, SessionFactoryData data) {
		if (done.contains(key)) return;
		CFCInfo v;
		String ext = value.getCFC().getExtends();
		if (!Util.isEmpty(ext)) {
			try {
				Component base = data.getEntityByCFCName(ext, false);
				ext = HibernateCaster.getEntityName(base);
			}
			catch (Throwable t) {
				if (t instanceof ThreadDeath) throw (ThreadDeath) t;
			}

			ext = HibernateUtil.id(CommonUtil.last(ext, ".").trim());
			if (!done.contains(ext)) {
				v = data.getCFC(ext, null);
				if (v != null) createMappings(ormConf, ext, v, done, mappings, data);
			}
		}

		mappings.append(value.getXML());
		done.add(key);
	}

	public static List<Component> loadComponents(PageContext pc, HibernateORMEngine engine, ORMConfiguration ormConf) throws PageException {
		CFMLEngine en = CFMLEngineFactory.getInstance();
		String[] ext = HibernateUtil.merge(en.getInfo().getCFMLComponentExtensions(), en.getInfo().getLuceeComponentExtensions());

		ResourceFilter filter = en.getResourceUtil().getExtensionResourceFilter(ext, true);
		List<Component> components = new ArrayList<Component>();
		loadComponents(pc, engine, components, ormConf.getCfcLocations(), filter, ormConf);
		return components;
	}

	private static void loadComponents(PageContext pc, HibernateORMEngine engine, List<Component> components, Resource[] reses, ResourceFilter filter, ORMConfiguration ormConf)
			throws PageException {
		Mapping[] mappings = createMappings(pc, reses);
		ApplicationContext ac = pc.getApplicationContext();
		Mapping[] existing = ac.getComponentMappings();
		if (existing == null) existing = new Mapping[0];
		try {
			Mapping[] tmp = new Mapping[existing.length + 1];
			for (int i = 1; i < tmp.length; i++) {
				tmp[i] = existing[i - 1];
			}
			ac.setComponentMappings(tmp);
			for (int i = 0; i < reses.length; i++) {
				if (reses[i] != null && reses[i].isDirectory()) {
					tmp[0] = mappings[i];
					ac.setComponentMappings(tmp);
					loadComponents(pc, engine, mappings[i], components, reses[i], filter, ormConf);
				}
			}
		}
		finally {
			ac.setComponentMappings(existing);
		}
	}

	private static void loadComponents(PageContext pc, HibernateORMEngine engine, Mapping cfclocation, List<Component> components, Resource res, ResourceFilter filter,
			ORMConfiguration ormConf) throws PageException {
		if (res == null) return;

		if (res.isDirectory()) {
			Resource[] children = res.listResources(filter);

			// first load all files
			for (int i = 0; i < children.length; i++) {
				if (children[i].isFile()) loadComponents(pc, engine, cfclocation, components, children[i], filter, ormConf);
			}

			// and then invoke subfiles
			for (int i = 0; i < children.length; i++) {
				if (children[i].isDirectory()) loadComponents(pc, engine, cfclocation, components, children[i], filter, ormConf);
			}
		}
		else if (res.isFile()) {
			if (!HibernateUtil.isApplicationName(pc, res.getName())) {
				try {

					// MUST still a bad solution
					PageSource ps = pc.toPageSource(res, null);
					if (ps == null || ps.getComponentName().indexOf("..") != -1) {
						PageSource ps2 = null;
						Resource root = cfclocation.getPhysical();
						String path = CFMLEngineFactory.getInstance().getResourceUtil().getPathToChild(res, root);
						if (!Util.isEmpty(path, true)) {
							ps2 = cfclocation.getPageSource(path);
						}
						if (ps2 != null) ps = ps2;
					}

					// Page p = ps.loadPage(pc.getConfig());
					String name = res.getName();
					name = HibernateUtil.removeExtension(name, name);

					TemplateUtil tu = CFMLEngineFactory.getInstance().getTemplateUtil();

					Page p = tu.loadPage(pc, ps, true);
					if (!(p instanceof InterfacePage)) {
						Component cfc = tu.loadComponent(pc, p, name, true, true, false, true);
						if (cfc.isPersistent()) {
							components.add(cfc);
						}
					}
				}
				catch (PageException e) {
					if (!ormConf.skipCFCWithError()) throw e;
					// e.printStackTrace();
				}
			}
		}
	}

	public static Mapping[] createMappings(PageContext pc, Resource[] resources) {

		Mapping[] mappings = new Mapping[resources.length];
		Config config = pc.getConfig();
		for (int i = 0; i < mappings.length; i++) {
			mappings[i] = CommonUtil.createMapping(config, "/", resources[i].getAbsolutePath());
		}
		return mappings;
	}
}
