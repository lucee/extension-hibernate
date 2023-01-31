package org.lucee.extension.orm.hibernate;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import org.hibernate.EntityMode;
import org.hibernate.tuple.entity.EntityTuplizerFactory;
import org.lucee.extension.orm.hibernate.event.EventListenerIntegrator;
import org.lucee.extension.orm.hibernate.tuplizer.AbstractEntityTuplizerImpl;
import org.lucee.extension.orm.hibernate.util.XMLUtil;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import lucee.commons.io.log.Log;
import lucee.commons.io.res.Resource;
import lucee.loader.engine.CFMLEngineFactory;
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

	/**
	 * Instantiate the  Hibernate session and factory data.
	 * 
	 * @param pc PageContext
	 */
	@Override
	public void init(PageContext pc) throws PageException {
		getOrBuildSessionFactoryData( pc );
	}

	@Override
	public ORMSession createSession(PageContext pc) throws PageException {
		try {
			return new HibernateORMSession(
				pc, 
				getSessionFactory( pc.getApplicationContext().getName() )
			);
		}
		catch (PageException pe) {
			throw pe;
		}
	}

	/**
	 * Reload the ORM session.
	 * 
	 * Will NOT reload if force is false and the given pageContext already has a session factory.
	 * 
	 * @param pc The current page context object
	 * @param force Force reload all session factory data.
	 */

	@Override
	public boolean reload(PageContext pc, boolean force) throws PageException {
		if ( force || !isInitializedForApplication( pc.getApplicationContext().getName() ) ) {
			buildSessionFactoryData( pc );
			return false;
		}
		return false;
	}

	private boolean isInitializedForApplication( String applicationName ){
		return factories.containsKey( applicationName );
	}

	/**
	 * Get the SessionFactoryData by application name.
	 * 
	 * @param applicationName Lucee application name, retrieve from {@link lucee.runtime.listener.ApplicationContext#getName()}
	 */
	private SessionFactoryData getSessionFactory( String applicationName ){
		return factories.get( applicationName );
	}

	/**
	 * Retrieve a SessionFactoryData() if configured for this application. If not, build one and retrieve that.
	 * 
	 * @param pc Lucee PageContext object.
	 * @return extension SessionFactoryData object.
	 * @throws PageException
	 */
	private SessionFactoryData getOrBuildSessionFactoryData( PageContext pc ) throws PageException{
		if ( !isInitializedForApplication( pc.getApplicationContext().getName() ) ){
			SessionFactoryData data = buildSessionFactoryData( pc );
			data.init();
		}
		return getSessionFactory( pc.getApplicationContext().getName() );
	}

	/**
	 * Add a new session factory specific to this application.
	 * 
	 * @param applicationName Lucee application name, retrieve from {@link lucee.runtime.listener.ApplicationContext#getName()}
	 * @param factory the SessionFactoryData object which houses the application-level Hibernate session factory
	 */
	private void setSessionFactory( String applicationName, SessionFactoryData factory ){
		factories.put( applicationName, factory );
	}

	/**
	 * Wipe the SessionFactoryData object for this Lucee application name from memory.
	 * 
	 * @param applicationName The Lucee application name.
	 */
	private void clearSessionFactory( String applicationName ){
		SessionFactoryData data = getSessionFactory( applicationName );
		if ( data != null ) {
			data.reset();
			factories.remove( applicationName );
		}
	}

	/**
	 * Reload all ORM configuration and entities and reload the HIbernate ORM session factory. 
	 * 
	 * @param pc Lucee PageContext
	 * @return SessionFactoryData
	 * @throws PageException
	 */
	private SessionFactoryData buildSessionFactoryData(PageContext pc ) throws PageException {
		ApplicationContext appContext = pc.getApplicationContext();
		if (!appContext.isORMEnabled()) throw ExceptionUtil.createException((ORMSession) null, null, "ORM is not enabled", "");
		String applicationName = pc.getApplicationContext().getName();
		clearSessionFactory( applicationName );

		// datasource
		ORMConfiguration ormConf = appContext.getORMConfiguration();
		SessionFactoryData data = new SessionFactoryData(this, ormConf);
		setSessionFactory( applicationName, data );

		// config
		try {
			// arr=null;
				synchronized (data) {

					data.tmpList = HibernateSessionFactory.loadComponents(pc, this, ormConf);
					data.clearCFCs();

					// load entities
					if ( data.hasTempCFCs() ) {
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
		String eventHandlerPath = data.getORMConfiguration().eventHandler();

		EventListenerIntegrator integrator = data.getEventListenerIntegrator();
		if (eventHandlerPath != null && !eventHandlerPath.trim().isEmpty() ) {
			Component eventHandler = pc.loadComponent( eventHandlerPath.trim() );
			if (eventHandler != null) {
				integrator.setGlobalEventListener( eventHandler );
			}
		}

		Iterator<CFCInfo> it = data.getCFCs(key).values().iterator();
		while (it.hasNext()) {
			CFCInfo info = it.next();
			integrator.appendEventListenerCFC(info.getCFC());
		}
	}

	public void createMapping(PageContext pc, Component cfc, ORMConfiguration ormConf, SessionFactoryData data) throws PageException {
		String entityName = HibernateCaster.getEntityName(cfc);
		CFCInfo info = data.getCFC(entityName, null);
		String xml;
		if (info == null || (CommonUtil.equals(info.getCFC(), cfc))) {
			DataSource ds = CommonUtil.getDataSource(pc, cfc);

			if ( ormConf.autogenmap() ) {
				data.reset();
				pc.addPageSource(cfc.getPageSource(), true);
				DatasourceConnection dc = CommonUtil.getDatasourceConnection(pc, ds, null, null, false);
				try {
					Element root;
					root = HBMCreator.createXMLMapping(pc, dc, cfc, data);
					xml = XMLUtil.toString(root.getChildNodes(), true, true);
					if (ormConf.saveMapping()) {
						HBMCreator.saveMapping(cfc, root);
					}
				}
				catch (Exception e) {
					throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
				}
				finally {
					pc.removeLastPageSource(true);
					CommonUtil.releaseDatasourceConnection(pc, dc, false);
				}
			}
			// load
			else {
				try {
					xml = HBMCreator.loadMapping( cfc );
				}
				catch (Exception e) {
					throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
				}

			}
			data.addCFC(entityName, new CFCInfo(HibernateUtil.getCompileTime(pc, cfc.getPageSource()), xml, cfc, ds));
		}

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

	/**
	 * Get the ORM configuration for the given PageContext
	 * 
	 * @param pc PageContext object
	 * @return ORMConfiguration
	 */
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
	 * @return Lucee Component
	 * @throws PageException
	 */
	public Component create(PageContext pc, HibernateORMSession session, String entityName, boolean unique) throws PageException {
		SessionFactoryData data = session.getSessionFactoryData();
		// get existing entity
		Component cfc = _create(pc, entityName, unique, data);
		if (cfc != null) return cfc;

		// SessionFactoryData oldData = getSessionFactoryData(pc, INIT_NOTHING);
		// Map<Key, SessionFactory> oldFactories = oldData.getFactories();
		// SessionFactoryData newData = getSessionFactoryData(pc, INIT_CFCS);
		// Map<Key, SessionFactory> newFactories = newData.getFactories();

		// Iterator<Entry<Key, SessionFactory>> it = oldFactories.entrySet().iterator();
		// Entry<Key, SessionFactory> e;
		// SessionFactory newSF;
		// while (it.hasNext()) {
		// 	e = it.next();
		// 	newSF = newFactories.get(e.getKey());
		// 	if (e.getValue() != newSF) {
		// 		session.resetSession(pc, newSF, e.getKey(), oldData);
		// 		cfc = _create(pc, entityName, unique, data);
		// 		if (cfc != null) return cfc;
		// 	}
		// }

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
