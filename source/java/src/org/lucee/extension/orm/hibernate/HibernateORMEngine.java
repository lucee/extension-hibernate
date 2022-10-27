package org.lucee.extension.orm.hibernate;

import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import org.hibernate.EntityMode;
import org.hibernate.SessionFactory;
import org.hibernate.tuple.entity.EntityTuplizerFactory;
import org.lucee.extension.orm.hibernate.event.EventListenerIntegrator;
import org.lucee.extension.orm.hibernate.tuplizer.AbstractEntityTuplizerImpl;
import org.lucee.extension.orm.hibernate.util.XMLUtil;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import lucee.commons.io.log.Log;
import lucee.commons.io.res.Resource;
import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.exp.PageException;
import lucee.runtime.listener.ApplicationContext;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.orm.ORMEngine;
import lucee.runtime.orm.ORMSession;
import lucee.runtime.type.Collection.Key;

public class HibernateORMEngine implements ORMEngine {

	private static final int INIT_NOTHING = 1;
	private static final int INIT_CFCS = 2;
	private static final int INIT_ALL = 2;

	private Map<String, SessionFactoryData> factories = new ConcurrentHashMap<String, SessionFactoryData>();

	static {
		// Patch because commandbox otherwise uses com.sun.xml.internal.bind.v2.ContextFactory for unknown
		// reason
		// Class clazz = ContextFactory.class;
		// System.setProperty("javax.xml.bind.context.factory", "com.sun.xml.bind.v2.ContextFactory");
	}

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
		}
		catch (PageException pe) {
			throw pe;
		}
	}

	/*
	 * QueryPlanCache getQueryPlanCache(PageContext pc) throws PageException { return
	 * getSessionFactoryData(pc,INIT_NOTHING).getQueryPlanCache(); }
	 */

	/*
	 * public SessionFactory getSessionFactory(PageContext pc) throws PageException{ return
	 * getSessionFactory(pc,INIT_NOTHING); }
	 */

	@Override
	public boolean reload(PageContext pc, boolean force) throws PageException {
		if (force) {
			getSessionFactoryData(pc, INIT_ALL);
		}
		else {
			if (factories.containsKey(hash(pc))) return false;
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
						data.tmpList = HibernateSessionFactory.loadComponents(pc, this, ormConf);

						data.clearCFCs();
					}
					else throw ExceptionUtil.createException(data, null, "orm setting autogenmap=false is not supported yet", null);

					// load entities
					if (data.tmpList != null && data.tmpList.size() > 0) {
						data.getNamingStrategy();// called here to make sure, it is called in the right context the
													// first one

						// creates CFCInfo objects
						{
							Iterator<Component> it = data.tmpList.iterator();
							while (it.hasNext()) {
								createMapping(pc, it.next(), ormConf, data);
							}
						}
						if (data.tmpList.size() != data.sizeCFCs()) {
							Component cfc;
							String name, lcName;
							Map<String, String> names = new HashMap<String, String>();
							Iterator<Component> it = data.tmpList.iterator();
							while (it.hasNext()) {
								cfc = it.next();
								name = HibernateCaster.getEntityName(cfc);
								lcName = name.toLowerCase();
								if (names.containsKey(lcName)) throw ExceptionUtil.createException(data, null, "Entity Name [" + name + "] is ambigous, [" + names.get(lcName)
										+ "] and [" + cfc.getPageSource().getDisplayPath() + "] use the same entity name.", "");
								names.put(lcName, cfc.getPageSource().getDisplayPath());
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
		if (!data.getORMConfiguration().eventHandling()) return;
		String eventHandler = data.getORMConfiguration().eventHandler();

		EventListenerIntegrator integrator = data.getEventListenerIntegrator();

		if (!Util.isEmpty(eventHandler, true)) {
			// try {
			Component c = pc.loadComponent(eventHandler.trim());
			if (c != null) integrator.setAllEventListener(c);
		}

		Iterator<CFCInfo> it = data.getCFCs(key).values().iterator();
		while (it.hasNext()) {
			CFCInfo info = it.next();
			integrator.setEventListene(info.getCFC());
		}
	}

	public String hash(PageContext pc) {
		ApplicationContext _ac = pc.getApplicationContext();
		Object ds = _ac.getORMDataSource();
		ORMConfiguration ormConf = _ac.getORMConfiguration();

		StringBuilder data = new StringBuilder(ormConf.hash()).append(ormConf.autogenmap()).append(':').append(ormConf.getCatalog()).append(':')
				.append(ormConf.isDefaultCfcLocation()).append(':').append(ormConf.getDbCreate()).append(':').append(ormConf.getDialect()).append(':')
				.append(ormConf.eventHandling()).append(':').append(ormConf.namingStrategy()).append(':').append(ormConf.eventHandler()).append(':')
				.append(ormConf.flushAtRequestEnd()).append(':').append(ormConf.logSQL()).append(':').append(ormConf.autoManageSession()).append(':')
				.append(ormConf.skipCFCWithError()).append(':').append(ormConf.saveMapping()).append(':').append(ormConf.getSchema()).append(':')
				.append(ormConf.secondaryCacheEnabled()).append(':').append(ormConf.useDBForMapping()).append(':').append(ormConf.getCacheProvider()).append(':').append(ds)
				.append(':');

		append(data, ormConf.getCfcLocations());
		append(data, ormConf.getSqlScript());
		append(data, ormConf.getCacheConfig());
		append(data, ormConf.getOrmConfig());

		return CFMLEngineFactory.getInstance().getSystemUtil().hash64b(data.toString());
	}

	private void append(StringBuilder data, Resource[] reses) {
		if (reses == null) return;
		for (int i = 0; i < reses.length; i++) {
			append(data, reses[i]);
		}
	}

	private void append(StringBuilder data, Resource res) {
		if (res == null) return;
		if (res.isFile()) {
			CFMLEngine eng = CFMLEngineFactory.getInstance();
			try {
				data.append(eng.getSystemUtil().hash64b(eng.getIOUtil().toString(res, null)));
				return;
			}
			catch (IOException e) {
			}
		}
		data.append(res.getAbsolutePath()).append(':');
	}

	public void createMapping(PageContext pc, Component cfc, ORMConfiguration ormConf, SessionFactoryData data) throws PageException {
		String entityName = HibernateCaster.getEntityName(cfc);
		CFCInfo info = data.getCFC(entityName, null);
		String xml;
		long cfcCompTime = HibernateUtil.getCompileTime(pc, cfc.getPageSource());
		if (info == null || (CommonUtil.equals(info.getCFC(), cfc))) {// && info.getModified()!=cfcCompTime
			DataSource ds = CommonUtil.getDataSource(pc, cfc);
			StringBuilder sb = new StringBuilder();

			long xmlLastMod = loadMapping(sb, ormConf, cfc);
			Element root;
			// create mapping
			if (true || xmlLastMod < cfcCompTime) {// MUSTMUST
				data.reset();
				Document doc = null;
				try {
					doc = CommonUtil.newDocument();
				}
				catch (Exception e) {
					Log log = pc.getConfig().getLog("orm");
					log.error("hibernate", e);
				}

				root = doc.createElement("hibernate-mapping");
				doc.appendChild(root);
				pc.addPageSource(cfc.getPageSource(), true);
				DatasourceConnection dc = CommonUtil.getDatasourceConnection(pc, ds, null, null, false);
				try {
					HBMCreator.createXMLMapping(pc, dc, cfc, root, data);
				}
				finally {
					pc.removeLastPageSource(true);
					CommonUtil.releaseDatasourceConnection(pc, dc, false);
				}
				try {
					xml = XMLUtil.toString(root.getChildNodes(), true, true);
				}
				catch (Exception e) {
					throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
				}
				saveMapping(ormConf, cfc, root);
			}
			// load
			else {
				xml = sb.toString();
				try {
					root = CommonUtil.toXML(xml).getOwnerDocument().getDocumentElement();
				}
				catch (Exception e) {
					throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
				}
				/*
				 * print.o("1+++++++++++++++++++++++++++++++++++++++++"); print.o(xml);
				 * print.o("2+++++++++++++++++++++++++++++++++++++++++"); print.o(root);
				 * print.o("3+++++++++++++++++++++++++++++++++++++++++");
				 */

			}
			data.addCFC(entityName, new CFCInfo(HibernateUtil.getCompileTime(pc, cfc.getPageSource()), xml, cfc, ds));
		}

	}

	private static void saveMapping(ORMConfiguration ormConf, Component cfc, Element hm) {
		if (ormConf.saveMapping()) {
			Resource res = cfc.getPageSource().getResource();
			if (res != null) {
				res = res.getParentResource().getRealResource(res.getName() + ".hbm.xml");
				try {
					CommonUtil.write(res, CommonUtil.toString(hm, false, true, HibernateSessionFactory.HIBERNATE_3_PUBLIC_ID, HibernateSessionFactory.HIBERNATE_3_SYSTEM_ID,
							CommonUtil.UTF8().name()), CommonUtil.UTF8(), false);
				}
				catch (Exception e) {
				}
			}
		}
	}

	private static long loadMapping(StringBuilder sb, ORMConfiguration ormConf, Component cfc) {

		Resource res = cfc.getPageSource().getResource();
		if (res != null) {
			res = res.getParentResource().getRealResource(res.getName() + ".hbm.xml");
			try {
				sb.append(CommonUtil.toString(res, CommonUtil.UTF8()));
				return res.lastModified();
			}
			catch (Exception e) {
			}
		}
		return 0;
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
		if (!ac.isORMEnabled()) return null;
		return ac.getORMConfiguration();
	}

	/**
	 * @param pc
	 * @param session
	 * @param entityName name of the entity to get
	 * @param unique create a unique version that can be manipulated
	 * @param init call the nit method of the cfc or not
	 * @return
	 * @throws PageException
	 */
	public Component create(PageContext pc, HibernateORMSession session, String entityName, boolean unique) throws PageException {
		SessionFactoryData data = session.getSessionFactoryData();
		// get existing entity
		Component cfc = _create(pc, entityName, unique, data);
		if (cfc != null) return cfc;

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
				if (cfc != null) return cfc;
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
		if (locations == null) return "";
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < locations.length; i++) {
			if (i > 0) sb.append(", ");
			sb.append(locations[i].getAbsolutePath());
		}
		return sb.toString();
	}

	private static Component _create(PageContext pc, String entityName, boolean unique, SessionFactoryData data) throws PageException {
		CFCInfo info = data.getCFC(entityName, null);
		if (info != null) {
			Component cfc = info.getCFC();
			if (unique) {
				cfc = (Component) cfc.duplicate(false);
				if (cfc.contains(pc, CommonUtil.INIT)) cfc.call(pc, "init", new Object[] {});
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
