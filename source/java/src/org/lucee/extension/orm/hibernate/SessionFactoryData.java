package org.lucee.extension.orm.hibernate;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.hibernate.cfg.Configuration;
import org.hibernate.SessionFactory;
import org.hibernate.engine.query.spi.QueryPlanCache;
import org.hibernate.internal.SessionFactoryImpl;
import org.lucee.extension.orm.hibernate.event.EventListenerIntegrator;
import org.lucee.extension.orm.hibernate.jdbc.DataSourceConfig;
import org.lucee.extension.orm.hibernate.naming.CFCNamingStrategy;
import org.lucee.extension.orm.hibernate.naming.DefaultNamingStrategy;
import org.lucee.extension.orm.hibernate.naming.SmartNamingStrategy;

import lucee.commons.io.log.Log;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.orm.ORMSession;
import lucee.runtime.orm.naming.NamingStrategy;
import lucee.runtime.type.Collection;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.type.Struct;

public class SessionFactoryData {

	/**
	 * Use during ORM initialization for tracking the in-progress list of Component entities.
	 */
	public List<Component> tmpList;

	private final Map<Key, DataSource> sources = new HashMap<Key, DataSource>();
	private final Map<Key, Map<String, CFCInfo>> cfcs = new HashMap<Key, Map<String, CFCInfo>>();
	private final Map<Key, DataSourceConfig> configurations = new HashMap<Key, DataSourceConfig>();
	private final Map<Key, SessionFactory> factories = new HashMap<Key, SessionFactory>();
	private final Map<Key, QueryPlanCache> queryPlanCaches = new HashMap<Key, QueryPlanCache>();

	private final ORMConfiguration ormConf;
	private NamingStrategy namingStrategy;
	private final HibernateORMEngine engine;
	private Struct tableInfo = CommonUtil.createStruct();
	private String cfcNamingStrategy;

	private EventListenerIntegrator eventListenerIntegrator = new EventListenerIntegrator();

	public SessionFactoryData(HibernateORMEngine engine, ORMConfiguration ormConf) {
		this.engine = engine;
		this.ormConf = ormConf;
	}

	public ORMConfiguration getORMConfiguration() {
		return ormConf;
	}

	public HibernateORMEngine getEngine() {
		return engine;
	}

	public QueryPlanCache getQueryPlanCache(Key datasSourceName) {
		QueryPlanCache qpc = queryPlanCaches.get(datasSourceName);
		if (qpc == null) {
			qpc = ((SessionFactoryImpl) this.getFactory(datasSourceName)).getQueryPlanCache();
			queryPlanCaches.put(datasSourceName, qpc);
		}
		return qpc;
	}

	public NamingStrategy getNamingStrategy() throws PageException {
		if (namingStrategy == null) {
			String strNamingStrategy = ormConf.namingStrategy();
			if (Util.isEmpty(strNamingStrategy, true)) {
				namingStrategy = DefaultNamingStrategy.INSTANCE;
			}
			else {
				strNamingStrategy = strNamingStrategy.trim();
				if ("default".equalsIgnoreCase(strNamingStrategy)) namingStrategy = DefaultNamingStrategy.INSTANCE;
				else if ("smart".equalsIgnoreCase(strNamingStrategy)) namingStrategy = SmartNamingStrategy.INSTANCE;
				else {
					CFCNamingStrategy cfcNS = new CFCNamingStrategy(cfcNamingStrategy == null ? strNamingStrategy : cfcNamingStrategy);
					cfcNamingStrategy = cfcNS.getComponent().getPageSource().getComponentName();
					namingStrategy = cfcNS;

				}
			}
		}
		if (namingStrategy == null) return DefaultNamingStrategy.INSTANCE;
		return namingStrategy;
	}

	public CFCInfo checkExistent(PageContext pc, Component cfc) throws PageException {
		CFCInfo info = getCFC(HibernateCaster.getEntityName(cfc), null);
		if (info != null) return info;

		throw ExceptionUtil.createException(this, null, "there is no mapping definition for component [" + cfc.getAbsName() + "]", "");
	}

	public List<String> getEntityNames() {
		Iterator<Map<String, CFCInfo>> it = cfcs.values().iterator();
		List<String> names = new ArrayList<String>();
		Iterator<CFCInfo> _it;
		while (it.hasNext()) {
			_it = it.next().values().iterator();
			while (_it.hasNext()) {
				names.add(HibernateCaster.getEntityName(_it.next().getCFC()));
			}
		}
		return names;
	}

	public Component getEntityByEntityName(String entityName, boolean unique) throws PageException {
		Component cfc;

		// first check cfcs for this entity
		CFCInfo info = getCFC(entityName, null);
		if (info != null) {
			cfc = info.getCFC();
			return unique ? (Component) cfc.duplicate(false) : cfc;
		}

		// if parsing is in progress, the cfc can be found here
		if (hasTempCFCs()) {
			Iterator<Component> it = tmpList.iterator();
			while (it.hasNext()) {
				cfc = it.next();
				if (HibernateCaster.getEntityName(cfc).equalsIgnoreCase(entityName)) return unique ? (Component) cfc.duplicate(false) : cfc;
			}
		}
		throw ExceptionUtil.createException((ORMSession) null, null, "entity [" + entityName + "] does not exist", "");
	}

	public Component getEntityByCFCName(String cfcName, boolean unique) throws PageException {
		String name = cfcName;
		int pointIndex = cfcName.lastIndexOf('.');
		if (pointIndex != -1) {
			name = cfcName.substring(pointIndex + 1);
		}
		else cfcName = null;

		Component cfc;
		List<String> names = new ArrayList<String>();

		if (hasTempCFCs()) {
			Iterator<Component> it2 = tmpList.iterator();
			while (it2.hasNext()) {
				cfc = it2.next();
				names.add(cfc.getName());
				if (HibernateUtil.isEntity(ormConf, cfc, cfcName, name)) // if(cfc.equalTo(name))
					return unique ? (Component) cfc.duplicate(false) : cfc;
			}
		}
		else {
			// search cfcs
			Iterator<Map<String, CFCInfo>> it = cfcs.values().iterator();
			Map<String, CFCInfo> _cfcs;
			while (it.hasNext()) {
				_cfcs = it.next();
				Iterator<CFCInfo> _it = _cfcs.values().iterator();
				while (_it.hasNext()) {
					cfc = _it.next().getCFC();
					names.add(cfc.getName());
					if (HibernateUtil.isEntity(ormConf, cfc, cfcName, name)) // if(cfc.instanceOf(name))
						return unique ? (Component) cfc.duplicate(false) : cfc;
				}
			}
		}

		CFCInfo info = getCFC(name, null);
		if (info != null) {
			cfc = info.getCFC();
			return unique ? (Component) cfc.duplicate(false) : cfc;
		}

		throw ExceptionUtil.createException((ORMSession) null, null, "entity [" + name + "] " + (Util.isEmpty(cfcName) ? "" : "with cfc name [" + cfcName + "] ")
				+ "does not exist, existing  entities are [" + CFMLEngineFactory.getInstance().getListUtil().toList(names, ", ") + "]", "");

	}

	/**
	 * Get the Hibernate configuration for the given datasource name.
	 *
	 * @param ds
	 *            Datasource object
	 *
	 * @return an instance of the {@link org.lucee.extension.orm.hibernate.jdbc.DataSourceConfig} object
	 */
	public DataSourceConfig getConfiguration(DataSource ds) {
		return configurations.get(CommonUtil.toKey(ds.getName()));
	}

	/**
	 * Get the Hibernate configuration for the given datasource name.
	 *
	 * @param key
	 *            Datasource name, as a Lucee collection key
	 *
	 * @return an instance of the {@link org.lucee.extension.orm.hibernate.jdbc.DataSourceConfig} object
	 */
	public DataSourceConfig getConfiguration(Key key) {
		return configurations.get(key);
	}

	public void setConfiguration(Log log, String mappings, DataSource ds, String user, String pass,
			String applicationContextName) throws PageException, SQLException, IOException {

		Configuration configuration = new ConfigurationBuilder().withDatasource(ds).withDatasourceCreds(user, pass)
				.withORMConfig(getORMConfiguration()).withEventListener(getEventListenerIntegrator())
				.withApplicationName(applicationContextName).withXMLMappings(mappings).withLog(log).build();
		configurations.put(CommonUtil.toKey(ds.getName()), new DataSourceConfig(ds, configuration));
		HibernateSessionFactory.schemaExport(log, configuration, ds, user, pass, this);
	}

	public SessionFactory buildSessionFactory(Key datasSourceName) {
		// Key key=eng.getCreationUtil().createKey(ds.getName());
		DataSourceConfig dsc = getConfiguration(datasSourceName);
		if (dsc == null) throw new RuntimeException("cannot build factory because there is no configuration"); // this should never
																												// happen

		Thread thread = Thread.currentThread();
		ClassLoader old = thread.getContextClassLoader();
		SessionFactory sf;
		try {
			// use the core classloader
			thread.setContextClassLoader(CFMLEngineFactory.getInstance().getClass().getClassLoader());
			sf = dsc.config.buildSessionFactory();
		}
		finally {
			// reset
			thread.setContextClassLoader(old);
		}

		factories.put(datasSourceName, sf);
		return sf;
	}

	public SessionFactory getFactory(Key datasSourceName) {
		SessionFactory factory = factories.get(datasSourceName);
		if (factory != null && factory.isClosed()) factory = null;
		if (factory == null && getConfiguration(datasSourceName) != null) factory = buildSessionFactory(datasSourceName);// this should never be happen
		return factory;
	}

	/**
	 * Reset the session factory and clear all known configuration.
	 */
	public void reset() {
		configurations.clear();
		Iterator<SessionFactory> it = factories.values().iterator();
		while (it.hasNext()) {
			it.next().close();
		}
		factories.clear();
		// namingStrategy=null; because the ormconf not change, this has not to change
		// as well
		tableInfo = CommonUtil.createStruct();
	}

	public Struct getTableInfo(DatasourceConnection dc, String tableName) throws PageException {
		Collection.Key keyTableName = CommonUtil.createKey(tableName);
		Struct columnsInfo = (Struct) tableInfo.get(keyTableName, null);
		if (columnsInfo != null) return columnsInfo;

		columnsInfo = HibernateUtil.checkTable(dc, tableName, this);
		tableInfo.setEL(keyTableName, columnsInfo);
		return columnsInfo;
	}

	// CFC methods
	public void addCFC(String entityName, CFCInfo info) {
		DataSource ds = info.getDataSource();
		Key dsn = CommonUtil.toKey(ds.getName());

		Map<String, CFCInfo> map = cfcs.get(dsn);
		if (map == null) cfcs.put(dsn, map = new HashMap<String, CFCInfo>());
		map.put(HibernateUtil.id(entityName), info);
		sources.put(dsn, ds);
	}

	CFCInfo getCFC(String entityName, CFCInfo defaultValue) {
		Iterator<Map<String, CFCInfo>> it = cfcs.values().iterator();
		while (it.hasNext()) {
			CFCInfo info = it.next().get(HibernateUtil.id(entityName));
			if (info != null) return info;
		}
		return defaultValue;
	}

	public Map<Key, Map<String, CFCInfo>> getCFCs() {
		return cfcs;
	}

	/*
	 * public Map<String, CFCInfo> getCFCs(DataSource ds) { Key
	 * key=eng.getCreationUtil().createKey(ds.getName()); Map<String, CFCInfo> rtn = cfcs.get(key);
	 * if(rtn==null) return new HashMap<String, CFCInfo>(); return rtn; }
	 */

	public Map<String, CFCInfo> getCFCs(Key datasSourceName) {
		Map<String, CFCInfo> rtn = cfcs.get(datasSourceName);
		if (rtn == null) return new HashMap<String, CFCInfo>();
		return rtn;
	}

	public void clearCFCs() {
		cfcs.clear();
	}

	public int sizeCFCs() {
		Iterator<Map<String, CFCInfo>> it = cfcs.values().iterator();
		int size = 0;
		while (it.hasNext()) {
			size += it.next().size();
		}
		return size;
	}

	public DataSource[] getDataSources() {
		return sources.values().toArray(new DataSource[sources.size()]);
	}

	/**
	 * Call all SessionFactory objects to ensure they're all built
	 */
	public void init() {
		Iterator<Key> it = cfcs.keySet().iterator();
		while (it.hasNext()) {
			getFactory(it.next());
		}
	}

	public Map<Key, SessionFactory> getFactories() {
		Iterator<Key> it = cfcs.keySet().iterator();
		Map<Key, SessionFactory> map = new HashMap<Key, SessionFactory>();
		Key key;
		while (it.hasNext()) {
			key = it.next();
			map.put(key, getFactory(key));
		}
		return map;
	}

	public DataSource getDataSource(Key datasSourceName) {
		return sources.get(datasSourceName);
	}

	public EventListenerIntegrator getEventListenerIntegrator() {
		return eventListenerIntegrator;
	}

	/**
	 * See if we have loaded entities. (ORM-ish CFML Components)
	 *
	 * @return True if entity list is not null and not empty.
	 */
	public boolean hasTempCFCs() {
		return tmpList != null && !tmpList.isEmpty();
	}
}
