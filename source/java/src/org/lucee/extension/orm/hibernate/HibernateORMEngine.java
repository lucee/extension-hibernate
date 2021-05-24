package org.lucee.extension.orm.hibernate;

import lucee.commons.io.log.Log;
import lucee.commons.io.res.Resource;
import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DataSourceManager;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.exp.PageException;
import lucee.runtime.listener.ApplicationContext;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.orm.ORMEngine;
import lucee.runtime.orm.ORMSession;
import lucee.runtime.type.Collection;
import lucee.runtime.type.Collection.Key;
import org.hibernate.EntityMode;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.event.service.spi.EventListenerRegistry;
import org.hibernate.event.spi.*;
import org.hibernate.internal.SessionFactoryImpl;
import org.hibernate.tuple.entity.EntityTuplizerFactory;
import org.lucee.extension.orm.hibernate.event.EventListener;
import org.lucee.extension.orm.hibernate.event.*;
import org.lucee.extension.orm.hibernate.tuplizer.AbstractEntityTuplizerImpl;
import org.lucee.extension.orm.hibernate.util.XMLUtil;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import java.io.IOException;
import java.util.*;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;


public class HibernateORMEngine implements ORMEngine {

	private static final int INIT_NOTHING = 1;
	private static final int INIT_CFCS = 2;
	private static final int INIT_ALL = 2;

	private Map<String, SessionFactoryData> factories = new ConcurrentHashMap<String, SessionFactoryData>();

	public HibernateORMEngine() {
	}

	@Override
	public void init(PageContext pc) throws PageException {
		SessionFactoryData data = getSessionFactoryData(pc, INIT_CFCS);
		data.init();// init all factories
	}

	@Override
	public ORMSession createSession(PageContext pc) throws PageException {
		try {
			SessionFactoryData data = getSessionFactoryData(pc, INIT_NOTHING);
			return new HibernateORMSession(pc, data);
		} catch (PageException pe) {
			throw pe;
		}
	}

	/*
	 * QueryPlanCache getQueryPlanCache(PageContext pc) throws PageException {
	 * return getSessionFactoryData(pc,INIT_NOTHING).getQueryPlanCache(); }
	 */

	/*
	 * public SessionFactory getSessionFactory(PageContext pc) throws PageException{
	 * return getSessionFactory(pc,INIT_NOTHING); }
	 */

	@Override
	public boolean reload(PageContext pc, boolean force) throws PageException {
		if (force) {
			getSessionFactoryData(pc, INIT_ALL);
		} else {
			if (factories.containsKey(hash(pc)))
				return false;
		}
		getSessionFactoryData(pc, INIT_CFCS);
		return true;
	}

	private SessionFactoryData getSessionFactoryData(PageContext pc, int initType) throws PageException {
		ApplicationContext appContext = pc.getApplicationContext();
		if (!appContext.isORMEnabled()) throw ExceptionUtil.createException((ORMSession) null, null, "ORM is not enabled", "");

		// datasource
		ORMConfiguration ormConf = appContext.getORMConfiguration();

		String key = hash(pc);
		SessionFactoryData data = factories.get(key);
		if (initType == INIT_ALL && data != null) {
			data.reset();
			data = null;
		}
		if (data == null) {
			data = new SessionFactoryData(this, ormConf);
			factories.put(key, data);
		}

		// config
		try {
			// arr=null;
			if (initType != INIT_NOTHING) {
				synchronized (data) {

					if (ormConf.autogenmap()) {
						data.clearCFCs();
					}

					data.tmpList = HibernateSessionFactory.loadComponents(pc, this, ormConf);

					// load entities
					if (data.tmpList != null && data.tmpList.size() > 0) {
						data.getNamingStrategy();// called here to make sure, it is called in the right context the first one

						if (data.tmpList.size() != data.sizeCFCs()) {
							Component cfc;
							String name, lcName;
							Map<String, String> names = new HashMap<String, String>();
							Iterator<Component> it = data.tmpList.iterator();
							while (it.hasNext()) {

								// check for ambiguous entity names ambiguous
								cfc = it.next();
								name = HibernateCaster.getEntityName(cfc);
								lcName = name.toLowerCase();
								if (names.containsKey(lcName)) {
									throw ExceptionUtil.createException(data, null, "Entity Name [" + name + "] is ambiguous, [" + names.get(lcName)
											+ "] and [" + cfc.getPageSource().getDisplayPath() + "] use the same entity name.", "");
								}
								names.put(lcName, cfc.getPageSource().getDisplayPath());

								// create/load CFC's hibernate mappings and create CFCInfo objects
								// TODO: adobe CF allows to override `autogenmap` and `saveMapping` at entity level
								if (ormConf.autogenmap()) {
									createEntityHibernateMapping(pc, cfc, ormConf, data);
								} else {
									loadEntityHibernateMapping(pc, cfc, ormConf, data);
								}

							}
						}

					}
				}
			}
		}
		finally {
			data.tmpList = null;
		}

		// already initialized for this application context

		// MUST
		// cacheconfig
		// cacheprovider
		// ...

		Log log = pc.getConfig().getLog("orm");

		Iterator<Entry<Key, String>> it = HibernateSessionFactory.createMappings(ormConf, data).entrySet().iterator();
		Entry<Key, String> e;
		while (it.hasNext()) {
			e = it.next();
			if (data.getConfiguration(e.getKey()) != null) continue;

			// DatasourceConnection dc = CommonUtil.getDatasourceConnection(pc, data.getDataSource(e.getKey()));
			try {
				data.setConfiguration(log, e.getValue(), data.getDataSource(e.getKey()), null, null, appContext == null ? "" : appContext.getName());
			}
			catch (Exception ex) {
				throw CommonUtil.toPageException(ex);
			}
			/*
			 * finally { CommonUtil.releaseDatasourceConnection(pc, dc); }
			 */
			addEventListeners(pc, data, e.getKey());

			EntityTuplizerFactory tuplizerFactory = data.getConfiguration(e.getKey()).config.getEntityTuplizerFactory();
			tuplizerFactory.registerDefaultTuplizerClass(EntityMode.MAP, AbstractEntityTuplizerImpl.class);
			tuplizerFactory.registerDefaultTuplizerClass(EntityMode.POJO, AbstractEntityTuplizerImpl.class);

			data.buildSessionFactory(e.getKey());
		}

		return data;
	}

	private static void addEventListeners(PageContext pc, SessionFactoryData data, Key key) throws PageException {
		if (!data.getORMConfiguration().eventHandling())
			return;
		String eventHandler = data.getORMConfiguration().eventHandler();
		AllEventListener listener = null;
		if (!Util.isEmpty(eventHandler, true)) {
			// try {
			Component c = pc.loadComponent(eventHandler.trim());

			listener = new AllEventListener(c);
			// config.setInterceptor(listener);
			// }catch (PageException e) {e.printStackTrace();}
		}

		SessionFactory factory = data.getFactory(key);
		EventListenerRegistry listeners = ((SessionFactoryImpl) factory).getServiceRegistry()
				.getService(EventListenerRegistry.class);

		Configuration conf = data.getConfiguration(key).config;

		conf.setInterceptor(new InterceptorImpl(listener));
		Map<String, CFCInfo> cfcs = data.getCFCs(key);
		// post delete
		List<EventListener> list = merge(listener, cfcs, CommonUtil.POST_DELETE);
		listeners.getEventListenerGroup(EventType.POST_DELETE)
				.appendListeners(list.toArray(new PostDeleteEventListener[list.size()]));

		// post insert
		list = merge(listener, cfcs, CommonUtil.POST_INSERT);
		listeners.getEventListenerGroup(EventType.POST_INSERT)
				.appendListeners(list.toArray(new PostInsertEventListener[list.size()]));

		// post update
		list = merge(listener, cfcs, CommonUtil.POST_UPDATE);
		listeners.getEventListenerGroup(EventType.POST_UPDATE)
				.appendListeners(list.toArray(new PostUpdateEventListener[list.size()]));

		// post load
		list = merge(listener, cfcs, CommonUtil.POST_LOAD);
		listeners.getEventListenerGroup(EventType.POST_LOAD)
				.appendListeners(list.toArray(new PostLoadEventListener[list.size()]));

		// pre delete
		list = merge(listener, cfcs, CommonUtil.PRE_DELETE);
		listeners.getEventListenerGroup(EventType.PRE_DELETE)
				.appendListeners(list.toArray(new PreDeleteEventListener[list.size()]));

		// pre insert
		// list = merge(listener, cfcs, CommonUtil.PRE_INSERT);
		// listeners.getEventListenerGroup(EventType.PRE_INSERT)
		// .appendListeners(list.toArray(new PreInsertEventListener[list.size()]));

		// pre load
		list = merge(listener, cfcs, CommonUtil.PRE_LOAD);
		listeners.getEventListenerGroup(EventType.PRE_LOAD)
				.appendListeners(list.toArray(new PreLoadEventListener[list.size()]));

		// pre update
		// list = merge(listener, cfcs, CommonUtil.PRE_UPDATE);
		// listeners.getEventListenerGroup(EventType.PRE_UPDATE)
		// .appendListeners(list.toArray(new PreUpdateEventListener[list.size()]));
	}

	private static List<EventListener> merge(EventListener listener, Map<String, CFCInfo> cfcs,
			Collection.Key eventType) {
		List<EventListener> list = new ArrayList<EventListener>();

		Iterator<Entry<String, CFCInfo>> it = cfcs.entrySet().iterator();
		Entry<String, CFCInfo> entry;
		Component cfc;
		while (it.hasNext()) {
			entry = it.next();
			cfc = entry.getValue().getCFC();
			if (EventListener.hasEventType(cfc, eventType)) {
				if (CommonUtil.POST_DELETE.equals(eventType))
					list.add(new PostDeleteEventListenerImpl(cfc));
				if (CommonUtil.POST_INSERT.equals(eventType))
					list.add(new PostInsertEventListenerImpl(cfc));
				if (CommonUtil.POST_LOAD.equals(eventType))
					list.add(new PostLoadEventListenerImpl(cfc));
				if (CommonUtil.POST_UPDATE.equals(eventType))
					list.add(new PostUpdateEventListenerImpl(cfc));

				if (CommonUtil.PRE_DELETE.equals(eventType))
					list.add(new PreDeleteEventListenerImpl(cfc));
				if (CommonUtil.PRE_INSERT.equals(eventType))
					list.add(new PreInsertEventListenerImpl(cfc));
				if (CommonUtil.PRE_LOAD.equals(eventType))
					list.add(new PreLoadEventListenerImpl(cfc));
				if (CommonUtil.PRE_UPDATE.equals(eventType))
					list.add(new PreUpdateEventListenerImpl(cfc));
			}
		}

		// general listener
		if (listener != null && EventListener.hasEventType(listener.getCFC(), eventType))
			list.add(listener);

		return list;
	}

	public String hash(PageContext pc) {
		ApplicationContext _ac = pc.getApplicationContext();
		Object ds = _ac.getORMDataSource();
		ORMConfiguration ormConf = _ac.getORMConfiguration();

		StringBuilder data = new StringBuilder(ormConf.hash()).append(ormConf.autogenmap()).append(':')
				.append(ormConf.getCatalog()).append(':').append(ormConf.isDefaultCfcLocation()).append(':')
				.append(ormConf.getDbCreate()).append(':').append(ormConf.getDialect()).append(':')
				.append(ormConf.eventHandling()).append(':').append(ormConf.namingStrategy()).append(':')
				.append(ormConf.eventHandler()).append(':').append(ormConf.flushAtRequestEnd()).append(':')
				.append(ormConf.logSQL()).append(':').append(ormConf.autoManageSession()).append(':')
				.append(ormConf.skipCFCWithError()).append(':').append(ormConf.saveMapping()).append(':')
				.append(ormConf.getSchema()).append(':').append(ormConf.secondaryCacheEnabled()).append(':')
				.append(ormConf.useDBForMapping()).append(':').append(ormConf.getCacheProvider()).append(':').append(ds)
				.append(':');

		append(data, ormConf.getCfcLocations());
		append(data, ormConf.getSqlScript());
		append(data, ormConf.getCacheConfig());
		append(data, ormConf.getOrmConfig());

		return CFMLEngineFactory.getInstance().getSystemUtil().hash64b(data.toString());
	}

	private void append(StringBuilder data, Resource[] reses) {
		if (reses == null)
			return;
		for (int i = 0; i < reses.length; i++) {
			append(data, reses[i]);
		}
	}

	private void append(StringBuilder data, Resource res) {
		if (res == null)
			return;
		if (res.isFile()) {
			CFMLEngine eng = CFMLEngineFactory.getInstance();
			try {
				data.append(eng.getSystemUtil().hash64b(eng.getIOUtil().toString(res, null)));
				return;
			} catch (IOException e) {
			}
		}
		data.append(res.getAbsolutePath()).append(':');
	}

	public void loadEntityHibernateMapping(PageContext pc, Component cfc, ORMConfiguration ormConf,
			SessionFactoryData data) throws PageException {
		String entityName = HibernateCaster.getEntityName(cfc);
		CFCInfo info = loadXMLMappingAndGetCFCInfo(pc, cfc, ormConf);
		data.addCFC(entityName, info);
	}

	public void createEntityHibernateMapping(PageContext pc, Component cfc, ORMConfiguration ormConf, SessionFactoryData data) throws PageException {
		String entityName = HibernateCaster.getEntityName(cfc);
		CFCInfo info = data.getCFC(entityName, null);
		long cfcCompTime = HibernateUtil.getCompileTime(pc, cfc.getPageSource());

		// if info is null and orm saveMapping is set to `true`, try to load mapping from previously saved mapping
		if( ormConf.saveMapping() ){
			info = loadXMLMappingAndGetCFCInfo(pc, cfc, ormConf);
		}

		if(info == null || CommonUtil.equals(info.getCFC(), cfc) || info.getModified() <= cfcCompTime ) {
			data.reset();
			info = createXMLMappingAndGetCFCInfo( pc, cfc, ormConf, data);
		}

		// load
		data.addCFC(entityName, info);
	}

	private static CFCInfo createXMLMappingAndGetCFCInfo(PageContext pc, Component cfc, ORMConfiguration ormConf, SessionFactoryData data) throws PageException {

		String xml;
		Element root;
		Document doc = null;
		DataSource ds = CommonUtil.getDataSource(pc, cfc);

		try {
			doc = CommonUtil.newDocument();
		}
		catch (Throwable t) {
			if (t instanceof ThreadDeath) throw (ThreadDeath) t;
		}
		
		root = doc.createElement("hibernate-mapping");
		doc.appendChild(root);
		pc.addPageSource(cfc.getPageSource(), true);
		DataSourceManager manager = pc.getDataSourceManager();
		DatasourceConnection dc = manager.getConnection(pc, ds, null, null);
		try {
			HBMCreator.createXMLMapping(pc, dc, cfc, root, data);
		}
		finally {
			pc.removeLastPageSource(true);
			manager.releaseConnection(pc, dc);
		}
		try {
			xml = XMLUtil.toString(root.getChildNodes(), true, true);
		}
		catch (Exception e) {
			throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
		}
		
		if (ormConf.saveMapping()) {
			Resource res = cfc.getPageSource().getResource();
			if (res != null) {
				res = res.getParentResource().getRealResource(res.getName() + ".hbm.xml");
				try {
					String rootXMLMappingString = CommonUtil.toString(root, false, true, HibernateSessionFactory.HIBERNATE_3_PUBLIC_ID, HibernateSessionFactory.HIBERNATE_3_SYSTEM_ID, CommonUtil.UTF8().name() );
					CommonUtil.write(res, rootXMLMappingString, CommonUtil.UTF8(), false);
				}
				catch (Exception e) {
					throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
				}
			}
		}

		return new CFCInfo(HibernateUtil.getCompileTime(pc, cfc.getPageSource()), xml, cfc, ds);
	}

	private static CFCInfo loadXMLMappingAndGetCFCInfo(PageContext pc, Component cfc, ORMConfiguration ormConf) throws PageException {
		DataSource ds = CommonUtil.getDataSource(pc, cfc);
		Resource res = cfc.getPageSource().getResource();
		Exception unableToLoadXMLException;
		if (res != null) {
			res = res.getParentResource().getRealResource(res.getName() + ".hbm.xml");
			try {
				String xml = CommonUtil.toString(res, CommonUtil.UTF8());
				return new CFCInfo(HibernateUtil.getCompileTime(pc, cfc.getPageSource()), xml, cfc, ds);
			} catch (Exception e) {
				unableToLoadXMLException = e;
			}
		} else {
			// Q: does the null check make sense above, I mean can the resource be null?
			unableToLoadXMLException = new Exception("XML mapping for CFC couldn't be loaded because, Unable to find Resource for CFC[" + cfc.getAbsName() + "]");
		}
		
		// if auto-gen mapping is set to `false`, let them know the exception while loading the .hbxml
		if (!ormConf.autogenmap()) {
			throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(unableToLoadXMLException);
		}
		
		return null;
	}

	@Override
	public int getMode() {
		// MUST impl
		return MODE_LAZY;
	}

	@Override
	public String getLabel() {
		return "Hibernate";
	}

	@Override
	public ORMConfiguration getConfiguration(PageContext pc) {
		ApplicationContext ac = pc.getApplicationContext();
		if (!ac.isORMEnabled())
			return null;
		return ac.getORMConfiguration();
	}

	/**
	 * @param pc
	 * @param session
	 * @param entityName name of the entity to get
	 * @param unique     create a unique version that can be manipulated
	 * @param init       call the nit method of the cfc or not
	 * @return
	 * @throws PageException
	 */
	public Component create(PageContext pc, HibernateORMSession session, String entityName, boolean unique)
			throws PageException {
		SessionFactoryData data = session.getSessionFactoryData();
		// get existing entity
		Component cfc = _create(pc, entityName, unique, data);
		if (cfc != null)
			return cfc;

		SessionFactoryData oldData = getSessionFactoryData(pc, INIT_NOTHING);
		Map<Key, SessionFactory> oldFactories = oldData.getFactories();
		SessionFactoryData newData = getSessionFactoryData(pc, INIT_CFCS);
		Map<Key, SessionFactory> newFactories = newData.getFactories();

		Iterator<Entry<Key, SessionFactory>> it = oldFactories.entrySet().iterator();
		Entry<Key, SessionFactory> e;
		SessionFactory newSF;
		while (it.hasNext()) {
			e = it.next();
			newSF = newFactories.get(e.getKey());
			if (e.getValue() != newSF) {
				session.resetSession(pc, newSF, e.getKey(), oldData);
				cfc = _create(pc, entityName, unique, data);
				if (cfc != null)
					return cfc;
			}
		}

		ORMConfiguration ormConf = pc.getApplicationContext().getORMConfiguration();
		Resource[] locations = ormConf.getCfcLocations();

		throw ExceptionUtil.createException(data, null,
				"No entity (persistent component) with name [" + entityName + "] found, available entities are ["
						+ CFMLEngineFactory.getInstance().getListUtil().toList(data.getEntityNames(), ", ") + "] ",
				"component are searched in the following directories [" + toString(locations) + "]");

	}

	private String toString(Resource[] locations) {
		if (locations == null)
			return "";
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < locations.length; i++) {
			if (i > 0)
				sb.append(", ");
			sb.append(locations[i].getAbsolutePath());
		}
		return sb.toString();
	}

	private static Component _create(PageContext pc, String entityName, boolean unique, SessionFactoryData data)
			throws PageException {
		CFCInfo info = data.getCFC(entityName, null);
		if (info != null) {
			Component cfc = info.getCFC();
			if (unique) {
				cfc = (Component) cfc.duplicate(false);
				if (cfc.contains(pc, CommonUtil.INIT))
					cfc.call(pc, "init", new Object[] {});
			}
			return cfc;
		}
		return null;
	}
}

class CFCInfo {
	private String xml;
	private long modified;
	private Component cfc;
	private DataSource ds;

	public CFCInfo(long modified, String xml, Component cfc, DataSource ds) {
		this.modified = modified;
		this.xml = xml;
		this.cfc = cfc;
		this.ds = ds;
	}

	/**
	 * @return the cfc
	 */
	public Component getCFC() {
		return cfc;
	}

	/**
	 * @return the xml
	 */
	public String getXML() {
		return xml;
	}

	/**
	 * @return the modified
	 */
	public long getModified() {
		return modified;
	}

	public DataSource getDataSource() {
		return ds;
	}

}
