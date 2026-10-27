package org.lucee.extension.orm.hibernate;

import org.lucee.extension.orm.hibernate.logging.LoggerLevelManager;
import org.lucee.extension.orm.hibernate.logging.OrmLoggingSettings;
import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.util.ExceptionUtil;
import org.lucee.extension.orm.hibernate.util.HibernateUtil;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import org.hibernate.FlushMode;
import org.hibernate.LockMode;
import org.hibernate.NonUniqueResultException;
import org.hibernate.QueryException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.engine.spi.EntityKey;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.engine.spi.Status;
import org.hibernate.generator.Generator;
import org.hibernate.metamodel.model.domain.EntityDomainType;
import org.hibernate.persister.entity.EntityPersister;
import org.hibernate.query.ParameterMetadata;
import org.hibernate.query.Query;
import org.hibernate.query.QueryParameter;
import org.hibernate.query.SelectionQuery;
import org.hibernate.type.BindableType;
import org.hibernate.type.CompositeType;
import org.hibernate.type.Type;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Order;
import jakarta.persistence.criteria.Path;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

import lucee.commons.io.log.Log;
import lucee.commons.lang.types.RefBoolean;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.ComponentScope;
import lucee.runtime.PageContext;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.SQLItem;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.orm.ORMEngine;
import lucee.runtime.orm.ORMSession;
import lucee.runtime.orm.ORMTransaction;
import lucee.runtime.type.Array;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.type.Struct;
import lucee.runtime.type.dt.TimeSpan;
import lucee.runtime.type.scope.Argument;

public class HibernateORMSession implements ORMSession {

	public class SessionAndConn {

		private Session s;
		private final DataSource d;
		private SessionFactory factory;
		private volatile boolean invalidated;

		public SessionAndConn(SessionFactory factory, DataSource ds) {
			this.d = ds;
			this.factory = factory;
		}

		public Session getSession(PageContext pc) {
			if (invalidated) {
				close(pc);
				throw new IllegalStateException(
					"ORM session unavailable — the session factory has been closed, likely by ORMReload() on another thread"
				);
			}
			if (s == null || !s.isOpen()) {
				if (factory == null || factory.isClosed()) {
					throw new IllegalStateException(
						"ORM session unavailable — the session factory has been closed, likely by ORMReload() on another thread"
					);
				}
				s = factory.openSession();
			}
			return s;
		}

		/**
		 * Mark this session for cleanup. The owning thread will close and release
		 * the connection on its next ORM operation or at end of request.
		 * Safe to call from any thread.
		 */
		public void invalidate() {
			invalidated = true;
		}

		public void close(PageContext pc) {
			try {
				if (s != null && s.isOpen()) {
					Transaction tx = s.getTransaction();
					if (tx != null && tx.isActive()) {
						tx.rollback();
					}
					s.close();
				}
			}
			catch (Exception e) {
				// session close failed — log but don't prevent cleanup
			}
			finally {
				s = null;
			}
		}

		public boolean isOpen() {
			return s != null && s.isOpen();
		}

		public boolean hasActiveTransaction() {
			if (s == null || !s.isOpen()) return false;
			Transaction tx = s.getTransaction();
			return tx != null && tx.isActive();
		}

		public DataSource getDataSource() {
			return d;
		}
	}

	private SessionFactoryData data;
	private final Map<Key, SessionAndConn> sessions = new ConcurrentHashMap<>();

	public HibernateORMSession(PageContext pc, SessionFactoryData data) throws PageException {
		this.data = data;
		data.registerSession( this );
		// Apply per-request logging config — settings can change without ormReload()
		ORMConfiguration ormConf = pc.getApplicationContext().getORMConfiguration();
		OrmLoggingSettings logSettings = OrmLoggingSettings.load( pc, ormConf );
		LoggerLevelManager.configure( CommonUtil.getORMLog( pc ), logSettings.logSQL,
		    logSettings.logParams, logSettings.logCache, logSettings.logVerbose );
	}

	/*
	 * private Session session(){ return _session; }
	 */

	// Note: several callers (getRawSession, getRawSessionFactory, getTransaction) pass null as pc.
	// This is safe as long as the session already exists in the map. If lazy creation is needed
	// (line 151), null pc will NPE in createSession. In practice, these methods are called from
	// Lucee core after ORM init, so the session should always exist.
	private Session getSession(PageContext pc, Key datasSourceName) throws PageException {
		return getSessionAndConn(pc, datasSourceName).getSession(pc);
	}

	private SessionAndConn getSessionAndConn(PageContext pc, Key datasSourceName) throws PageException {
		SessionAndConn sac = sessions.get(datasSourceName);
		if (sac == null) {
			// lazy session creation — only open when the datasource is actually used
			SessionFactory factory = data.getFactory(datasSourceName);
			if (factory == null) {
				throw ExceptionUtil.createException(data, null, "There is no ORM configuration for the datasource [" + datasSourceName + "]", null);
			}
			DataSource ds = data.getDataSource(datasSourceName);
			sac = createSession(pc, factory, ds);
		}
		Session s = sac.getSession(pc);
		if (!s.isOpen() || !s.isConnected()) {
			// session is broken — close it and open a fresh one
			sac.close(pc);
			s = sac.getSession(pc);
		}
		return sac;
	}

    /**
     * Get the configured SessionFactoryData for this HibernateORMSession object
     *
     * @return SessionFactoryData used to create this session
     */
	public SessionFactoryData getSessionFactoryData() {
		return data;
	}

	SessionFactory getSessionFactory(Key datasSourceName) throws PageException {
		Session s = getSession(null, datasSourceName);
		return s.getSessionFactory();
	}

	void resetSession(PageContext pc, SessionFactory factory, Key dataSourceName, SessionFactoryData data) throws PageException {

		SessionAndConn sac = sessions.get(dataSourceName);
		if (sac != null) {
			sac.close(pc);
			createSession(pc, factory, sac.getDataSource());
			return;
		}
		DataSource ds = data.getDataSource(dataSourceName);
		createSession(pc, factory, ds);
	}

    /**
     * Create a new {@link org.hibernate.Session} for the given Datasource
     * <p>
     * Will set the Hibernate FlushMode on initialization.
     *
     * @param pc
     *            Lucee PageContext object.
     * @param factory
     *            The SessionFactory to open the session with.
     * @param ds
     *            A Lucee Datasource object
     *
     * @return The Hibernate Session.
     *
     * @throws PageException
     */
	SessionAndConn createSession(PageContext pc, SessionFactory factory, DataSource ds) throws PageException {
		SessionAndConn sac = new SessionAndConn(factory, ds);

		sessions.put(CommonUtil.toKey(ds.getName()), sac);
		sac.getSession(pc).setHibernateFlushMode(FlushMode.MANUAL);
		return sac;
	}

	@Override
	public ORMEngine getEngine() {
		return data.getEngine();
	}

	@Override
	public void flushAll(PageContext pc) {
		SessionAndConn sac;
		Session s;
		Iterator<SessionAndConn> it = sessions.values().iterator();
		while (it.hasNext()) {
			sac = it.next();
			if (sac.isOpen()) {
				try {
					s = sac.getSession(pc);
					s.flush();
				}
				catch (Exception e) {
					// Lucee bug: keeps session object after exception for future requests,
					// this session then fails to flush because the underlying datasource
					// is not defined in the current application.cfc.
					Log log = CommonUtil.getORMLog();
					if ( log != null ) log.log( Log.LEVEL_DEBUG, "hibernate", "flushAll: ignoring stale session flush failure", e );
				}
			}
		}
	}

    /**
     * Flush the session for the default datasource.
     *
     * @param pc
     *            Lucee PageContext object.
     */
	@Override
	public void flush(PageContext pc) throws PageException {
		flush(pc, null);
	}

    /**
     * Flush the session for the given datasource
     *
     * @param pc
     *            Lucee PageContext object.
     * @param datasource
     *            Datasource name
     */
	@Override
	public void flush(PageContext pc, String datasource) throws PageException {
		_flush(pc, CommonUtil.getDataSource(pc, datasource));
	}

	private void _flush(PageContext pc, DataSource datasource) throws PageException {
		Key dsn = CommonUtil.toKey(datasource.getName());

		try {
			getSession(pc, dsn).flush();
		}
		catch (Exception e) {
			throw CommonUtil.toPageException(e);
		}

	}

    /**
     * Delete an entity OR array of entities from the Hibernate session
     *
     * @param pc
     *            Lucee PageContext
     * @param obj
     *            Hibernate Entity object OR an Array of objects
     */
	@Override
	public void delete(PageContext pc, Object obj) throws PageException {
		if (CommonUtil.isArray(obj)) {

			// convert to a usable structure
			Map<Key, List<Component>> cfcs = new HashMap<Key, List<Component>>();
			{
				Array arr = CommonUtil.toArray(obj);
				Iterator<?> it = arr.valueIterator();
				Component cfc;

				Key dsn;
				List<Component> list;
				while (it.hasNext()) {
					cfc = HibernateCaster.toComponent(it.next());
					dsn = CommonUtil.toKey(CommonUtil.getDataSourceName(pc, cfc));
					list = cfcs.get(dsn);
					if (list == null) cfcs.put(dsn, list = new ArrayList<Component>());
					list.add(cfc);
				}
			}

			Iterator<Entry<Key, List<Component>>> it = cfcs.entrySet().iterator();
			while (it.hasNext()) {
				Entry<Key, List<Component>> e = it.next();
				Transaction trans = getSession(pc, e.getKey()).getTransaction();
				if (!trans.isActive()) trans.begin();
				else trans = null;

				try {
					Iterator<Component> _it = e.getValue().iterator();
					while (_it.hasNext()) {
						_delete(pc, _it.next(), e.getKey());
					}
				}
				catch (Exception ex) {
					if (trans != null) trans.rollback();
					throw CommonUtil.toPageException(ex);
				}
				if (trans != null) trans.commit();
			}
		}
		else _delete(pc, HibernateCaster.toComponent(obj), null);
	}

	public void _delete(PageContext pc, Component cfc, Key dsn) throws PageException {
		if (dsn == null) dsn = CommonUtil.toKey(CommonUtil.getDataSourceName(pc, cfc));
		data.checkExistent(pc, cfc);
		try {
			getSession(pc, dsn).remove(cfc);
		}
		catch (Exception e) {
			throw CommonUtil.toPageException(e);
		}
	}

    /**
     * Persist this entity to the datasource.
     *
     * @param pc
     *            Lucee PageContext object
     * @param obj
     *            Java entity object which maps to a persistent Component
     * @param forceInsert
     *            force an INSERT. If false, will try a {@link org.hibernate.Session#saveOrUpdate(String, Object)}
     */
	@Override
	public void save(PageContext pc, Object obj, boolean forceInsert) throws PageException {
		Component cfc = HibernateCaster.toComponent(obj);
		String name = HibernateCaster.getEntityName(cfc);
		Key dsn = CommonUtil.toKey(CommonUtil.getDataSourceName(pc, cfc));
		/*
		 * just a test Property[] props = cfc.getProperties(true,true, false,true); Cast caster =
		 * CFMLEngineFactory.getInstance().getCastUtil(); ComponentScope cs = cfc.getComponentScope();
		 * String type; Object val; for(Property p:props) { val=cs.get(p.getName(),null); if(val==null)
		 * continue; Object o = p.getMetaData(); if(!(o instanceof Struct)) continue; Struct meta = (Struct)
		 * o;
		 * 
		 * type=caster.toString(meta.get("ormtype",null),null); if(Util.isEmpty(type))
		 * type=caster.toString(meta.get("type",null)); if(!Util.isEmpty(type)) {
		 * val=HibernateCaster.toHibernateValue(pc,val,type); cs.setEL(p.getName(), val); } }
		 */
		try {
			Session session = getSession(pc, dsn);
			// Hibernate 7.x removed saveOrUpdate/update. The naive replacement
			// is merge(), but merge returns a NEW attached copy and leaves the
			// caller's reference detached — which breaks CFML semantics where
			// entityReload(sink) is called on the same reference after save.
			// persist() attaches the caller's reference for transient entities.
			// For already-attached entities it's a no-op (dirty-checking will
			// flush updates). Detached entities (id set, not in session) are
			// rare in practice — fall back to merge for them.
			boolean persisted = false;
			if (forceInsert) {
				// Pre-7.3 saveOrUpdate-with-forceInsert (and session.save) tolerated
				// empty/sentinel ids on entities backed by a generator — the generator
				// would assign a fresh id at insert. H7 silently drops unsaved-value=""
				// at ModelBinder.java:623, and persist() rejects any non-null id as
				// "Detached entity." For generated ids (UUID, sequence, IDENTITY —
				// anything except `assigned`), an empty-string or null id is the
				// "please assign me" sentinel — clear it explicitly so persist trusts us.
				SharedSessionContractImplementor sessionImpl = (SharedSessionContractImplementor) session;
				EntityPersister persister = ((SessionFactoryImplementor) session.getSessionFactory())
						.getMappingMetamodel().findEntityDescriptor(name);
				if (persister != null && persister.getGenerator() != null
						&& persister.getGenerator().generatesOnInsert()) {
					Object id = persister.getIdentifier(cfc, sessionImpl);
					if (id == null || "".equals(String.valueOf(id))) {
						persister.setIdentifier(cfc, null, sessionImpl);
					}
				}
				session.persist(name, cfc);
				persisted = true;
			} else if (session.contains(cfc)) {
				// already attached — dirty-checking handles updates at flush
			} else {
				// H7 removed saveOrUpdate. We replicate it via the same internals that
				// merge() uses, but WITHOUT the copy-to-new-instance step — the caller's
				// reference must remain the canonical managed entity so subsequent
				// entityReload(cfc) / refresh / dirty-check semantics keep working.
				//
				// persister.isTransient() returns:
				//   - TRUE  → entity is new, persist() is correct
				//   - FALSE → entity is detached, merge it
				//   - null  → undecidable (this is the common case for assigned-id with
				//             unsavedvalue="" — H7's HBM parser silently drops empty
				//             unsaved-value at ModelBinder.java:623, so the persister has
				//             no strategy and returns null). Issue a snapshot SELECT to
				//             disambiguate, then either persist (no row) or reattach
				//             (row exists) by injecting cfc into the persistence context
				//             as MANAGED with the loaded snapshot.
				SharedSessionContractImplementor sessionImpl = (SharedSessionContractImplementor) session;
				EntityPersister persister = ((SessionFactoryImplementor) session.getSessionFactory())
						.getMappingMetamodel().findEntityDescriptor(name);
				Boolean isTransient = persister == null ? null : persister.isTransient(cfc, sessionImpl);
				Object id = persister == null ? null : persister.getIdentifier(cfc, sessionImpl);
				boolean idLooksSet = id != null && !"".equals(String.valueOf(id));

				if (Boolean.FALSE.equals(isTransient)) {
					// definitely detached — merge writes through but caller's reference stays detached
					session.merge(name, cfc);
				} else if (isTransient == null && idLooksSet && persister != null) {
					Object[] snapshot = persister.getDatabaseSnapshot(id, sessionImpl);
					if (snapshot == null) {
						// row not in DB — INSERT, caller's reference attaches
						session.persist(name, cfc);
						persisted = true;
					} else {
						// row exists — reattach cfc as MANAGED with the loaded snapshot.
						// dirty-checking will issue UPDATE on flush against this snapshot.
						EntityKey key = sessionImpl.generateEntityKey(id, persister);
						Object dbVersion = null;
						if (persister.isVersioned()) {
							int vp = persister.getVersionPropertyIndex();
							if (vp >= 0 && vp < snapshot.length) dbVersion = snapshot[vp];
						}
						sessionImpl.getPersistenceContextInternal().addEntity(
								cfc, Status.MANAGED, snapshot, key, dbVersion,
								LockMode.NONE, true, persister, false);
					}
				} else {
					// transient (TRUE) or undecidable with no id — persist; fall back to merge
					// if Hibernate throws a known detached-entity exception immediately.
					try {
						session.persist(name, cfc);
						persisted = true;
					} catch (org.hibernate.PersistentObjectException | jakarta.persistence.EntityExistsException pe) {
						session.merge(name, cfc);
					}
				}
			}

			// Adobe-documented semantic: nativeId/identity-generated entities are
			// inserted immediately on entitySave so getId() works right after.
			// Pre-7.3 saveOrUpdate did this implicitly; JPA persist() defers the
			// insert when not in a transaction (AbstractSaveEventListener.delayIdentityInserts).
			// Drain the action queue's pending inserts only — narrower than session.flush(),
			// which would also write dirty updates/deletes/collections.
			if (persisted && hasOnExecutionGenerator(session, name)) {
				((org.hibernate.engine.spi.SessionImplementor) session).getActionQueue().executeInserts();
			}
		}
		catch (Exception e) {
			throw ExceptionUtil.createException(this, null, e);
		}
	}

	/**
	 * True if the entity uses an on-execution (post-insert) id generator like IDENTITY,
	 * where Hibernate must INSERT to obtain the id. Such entities require an immediate
	 * flush after persist() so {@code entity.getId()} returns the generated value.
	 */
	private static boolean hasOnExecutionGenerator(Session session, String entityName) {
		EntityPersister persister = ((SessionFactoryImplementor) session.getSessionFactory())
				.getMappingMetamodel().findEntityDescriptor(entityName);
		if (persister == null) return false;
		Generator gen = persister.getGenerator();
		return gen != null && gen.generatedOnExecution();
	}

    /**
     * Refresh (not reload) this entity in the (native) Hibernate session object.
     *
     * {@link org.hibernate.Session#refresh(Object) }
     */
	@Override
	public void reload(PageContext pc, Object obj) throws PageException {
		Component cfc = HibernateCaster.toComponent(obj);
		Key dsn = CommonUtil.toKey(CommonUtil.getDataSourceName(pc, cfc));
		data.checkExistent(pc, cfc);
		getSession(pc, dsn).refresh(cfc);
	}

	@Override
	public Component create(PageContext pc, String entityName) throws PageException {
		return data.getEngine().create(pc, this, entityName, true);
	}

    /**
     * Clear the Hibernate session for the default datasource.
     *
     * @param pc
     *            Lucee PageContext object
     */
	@Override
	public void clear(PageContext pc) throws PageException {
		clear(pc, null);
	}

    /**
     * Clear the Hibernate session for this datasource.
     *
     * @param pc
     *            Lucee PageContext object
     * @param datasource
     *            Lucee Datasource by which to find the session to clear.
     *
     * @see org.hibernate.Session#clear()
     */
	@Override
	public void clear(PageContext pc, String datasource) throws PageException {
		Key dsn = CommonUtil.toKey(CommonUtil.getDataSource(pc, datasource).getName());

		getSession(pc, dsn).clear();
		/*
		 * Iterator<Session> it = _sessions.values().iterator(); while(it.hasNext()){ it.next().clear(); }
		 */
	}

	@Override
	public void evictQueries(PageContext pc) throws PageException {
		evictQueries(pc, null, null);
	}

	@Override
	public void evictQueries(PageContext pc, String cacheName) throws PageException {
		evictQueries(pc, cacheName, null);
	}

	@Override
	public void evictQueries(PageContext pc, String cacheName, String datasource) throws PageException {
		Key dsn = CommonUtil.toKey(CommonUtil.getDataSource(pc, datasource).getName());
		SessionFactory factory = getSession(pc, dsn).getSessionFactory();

		if (Util.isEmpty(cacheName)) factory.getCache().evictDefaultQueryRegion();
		else factory.getCache().evictQueryRegion(cacheName);

		// String entityName = getEntityName(componentName);
		// String datasource = this.config.getDataSource(entityName);
		// this.config.getSessionFactory(datasource).getCache().evictEntityRegion(entityName);

		/*
		 * Iterator<Session> it = _sessions.values().iterator(); while(it.hasNext()){ SessionFactory f =
		 * it.next().getSessionFactory(); if(Util.isEmpty(cacheName))f.evictQueries(); else
		 * f.evictQueries(cacheName); }
		 */
	}

	@Override
	public void evictEntity(PageContext pc, String entityName) throws PageException {
		evictEntity(pc, entityName, null);
	}

	@Override
	public void evictEntity(PageContext pc, String entityName, String id) throws PageException {
		evictEntity(pc, entityName, (Object) id);
	}

	public void evictEntity(PageContext pc, String entityName, Object id) throws PageException {
		entityName = correctCaseEntityName(entityName);

		SessionFactory f = getSessionFactoryForEntity( pc, entityName );
		if (id == null) f.getCache().evictEntityData(entityName);
		else if (isCompositeIdStruct(id)) {
			// LDEV-2121: a struct holds the values of a composite primary key
			EntityPersister metaData = ((SessionFactoryImplementor) f).getMappingMetamodel().findEntityDescriptor(entityName);
			if (metaData == null) throw ExceptionUtil.createException(this, null, "Could not load meta information for entity [" + entityName + "]", null);
			f.getCache().evictEntityData(entityName, toCompositeId(pc, metaData, entityName, (Struct) id));
		}
		else f.getCache().evictEntityData(entityName, CommonUtil.toSerializable(id));
	}

	private static boolean isCompositeIdStruct(Object id) {
		return id instanceof Struct && !(id instanceof Component);
	}

	/**
	 * Converts a struct containing the values of a composite primary key into the identifier used by
	 * Hibernate for that entity.
	 */
	private Serializable toCompositeId(PageContext pc, EntityPersister metaData, String entityName, Struct sct) throws PageException {
		Type idType = metaData.getIdentifierType();
		if (!(idType instanceof CompositeType)) throw ExceptionUtil.createException(this, null,
				"Entity [" + entityName + "] does not have a composite primary key, the primary key can not be defined as a struct", null);
		CompositeType compositeType = (CompositeType) idType;
		String[] names = compositeType.getPropertyNames();
		Type[] types = compositeType.getSubtypes();
		HashMap<String, Object> id = new HashMap<String, Object>();
		Object value;
		for (int i = 0; i < names.length; i++) {
			value = sct.get(CommonUtil.createKey(names[i]), null);
			if (value == null) throw ExceptionUtil.createException(this, null, "Missing value for the primary key property [" + names[i] + "] of entity [" + entityName
					+ "], the composite primary key consists of the properties [" + String.join(", ", names) + "]", null);
			id.put(names[i], CommonUtil.castTo(pc, types[i].getReturnedClass(), value));
		}
		return id;
	}

	/**
	 * Look up which datasource owns the given entity and return that datasource's SessionFactory.
	 * Fixes LDEV-2092: evict methods must target the correct SessionFactory, not iterate all.
	 */
	private SessionFactory getSessionFactoryForEntity(PageContext pc, String entityName) throws PageException {
		CFCInfo info = data.getCFC(entityName, null);
		if (info != null) {
			Key dsn = CommonUtil.toKey(info.getDataSource().getName());
			return getSession(pc, dsn).getSessionFactory();
		}
		throw ExceptionUtil.createException(data, null, "Entity [" + entityName + "] not found", null);
	}

	private String correctCaseEntityName(String entityName) {
		Iterator<String> it = data.getEntityNames().iterator();
		String n;
		while (it.hasNext()) {
			n = it.next();
			if (n.equalsIgnoreCase(entityName)) return n;

		}
		return entityName;
	}

	@Override
	public void evictCollection(PageContext pc, String entityName, String collectionName) throws PageException {
		evictCollection(pc, entityName, collectionName, null);
	}

	@Override
	public void evictCollection(PageContext pc, String entityName, String collectionName, String id) throws PageException {
		String role = entityName + "." + collectionName;

		SessionFactory f = getSessionFactoryForEntity( pc, entityName );
		if (id == null) f.getCache().evictCollectionData(role);
		else f.getCache().evictCollectionData(role, CommonUtil.toSerializable(id));
	}

	@Override
	public Object executeQuery(PageContext pc, String dataSourceName, String hql, Array params, boolean unique, Struct queryOptions) throws PageException {
		return _executeQuery(pc, dataSourceName, hql, params, unique, queryOptions);
	}

	@Override
	public Object executeQuery(PageContext pc, String dataSourceName, String hql, Struct params, boolean unique, Struct queryOptions) throws PageException {
		return _executeQuery(pc, dataSourceName, hql, params, unique, queryOptions);
	}

	private Object _executeQuery(PageContext pc, String dataSourceName, String hql, Object params, boolean unique, Struct queryOptions) throws PageException {
		Key dsn;
		if (dataSourceName == null) dsn = CommonUtil.toKey(CommonUtil.getDefaultDataSource(pc).getName());
		else dsn = CommonUtil.toKey(dataSourceName);

		Session s = getSession(pc, dsn);
		try {
			return __executeQuery(pc, s, dsn, hql, params, unique, queryOptions);
		}
		catch (QueryException qe) {
			// argument scope is array and struct at the same time, by default it is handled
			// as struct, if this
			// fails try it as array
			if (params instanceof Argument) {
				try {
					return __executeQuery(pc, s, dsn, hql, CommonUtil.toArray((Argument) params), unique, queryOptions);
				}
				catch (Exception e) {
					Log log = CommonUtil.getORMLog();
					if ( log != null ) log.log( Log.LEVEL_DEBUG, "hibernate",
						"HQL query param fallback (struct->array) also failed for [" + hql + "]", e );
				}
			}
			throw qe;
		}

	}

	private Object __executeQuery(PageContext pc, Session session, Key dsn, String hql, Object params, boolean unique, Struct options) throws PageException {
		// Session session = getSession(pc,null);
		hql = hql.trim();
		boolean isParamArray = params != null && CommonUtil.isArray(params);
		if (isParamArray) hql = addIndexIfNecessary(hql);
		Query<?> query = session.createQuery(hql);
		// options
		if (options != null) {
			// maxresults
			Object obj = options.get("maxresults", null);
			if (obj != null) {
				int max = CommonUtil.toIntValue(obj, -1);
				if (max < 0)
					throw ExceptionUtil.createException(this, null, "Option [maxresults] has an invalid value [" + obj + "], value should be a number >= 0", null);
				query.setMaxResults(max);
			}
			// offset
			obj = options.get("offset", null);
			if (obj != null) {
				int off = CommonUtil.toIntValue(obj, -1);
				if (off < 0)
					throw ExceptionUtil.createException(this, null, "Option [offset] has an invalid value [" + obj + "], value should be a number >= 0", null);
				query.setFirstResult(off);
			}
			// readonly
			obj = options.get("readonly", null);
			if (obj != null) {
				Boolean ro = CommonUtil.toBoolean(obj, null);
				if (ro == null) throw ExceptionUtil.createException(this, null, "Option [readonly] has an invalid value [" + obj + "], value should be a boolean", null);
				query.setReadOnly(ro.booleanValue());
			}
			// timeout
			obj = options.get("timeout", null);
			if (obj != null) {
				int to;
				if (obj instanceof TimeSpan) to = (int) ((TimeSpan) obj).getSeconds();
				else to = CommonUtil.toIntValue(obj, -1);

				if (to < 0)
					throw ExceptionUtil.createException(this, null, "Option [timeout] has an invalid value [" + obj + "], value should be a number >= 0", null);
				query.setTimeout(to);
			}
		}

		// params
		// Stage 7 spike (Option A): bind without explicit Hibernate Type hints — trust H7.3
		// SQM type inference + JPA binding-side coercion. CFML entity properties always carry
		// ormtype declarations, so SQM has full slot-type information from the metamodel. If
		// specific tests (tests/session/hqlParams) reveal coercion gaps, restore targeted casts.
		if (params != null) {
			ParameterMetadata meta = query.getParameterMetadata();

			// struct (named params)
			if (CommonUtil.isStruct(params)) {
				Struct sct = CommonUtil.toStruct(params);
				// case-fix: CFML keys are case-insensitive, Hibernate names are case-sensitive.
				// Map struct keys to actual parameter names declared in the query.
				Struct names = CommonUtil.createStruct();
				for (String n : meta.getNamedParameterNames()) {
					names.setEL(n, n);
				}

				Iterator<Entry<Key, Object>> it = sct.entryIterator();
				while (it.hasNext()) {
					Entry<Key, Object> e = it.next();
					String name = (String) names.get(e.getKey(), null);
					if (name == null) continue; // unused param — ignored
					Object value = sct.get(e.getKey(), null);
					if (value instanceof Object[]) query.setParameterList(name, (Object[]) value);
					else if (value instanceof java.util.Collection) query.setParameterList(name, (java.util.Collection<?>) value);
					else query.setParameter(name, coerceForBind(value, meta.findQueryParameter(name), meta));
				}
			}

			// array (ordinal params)
			else if (isParamArray) {
				Array arr = CommonUtil.toArray(params);

				int ordinalCount = meta.getOrdinalParameterLabels().size();
				if (ordinalCount > arr.size()) throw ExceptionUtil.createException(this, null,
						"Parameter array is too small [" + arr.size() + "], need [" + ordinalCount + "] elements", null);

				Iterator<?> it = arr.valueIterator();
				int idx = 1;
				while (it.hasNext()) {
					Object value = it.next();
					if (value instanceof SQLItem) value = ((SQLItem) value).getValue();
					query.setParameter(idx, coerceForBind(value, meta.findQueryParameter(idx), meta));
					idx++;
				}
			}
		}

		// select
		String lcHQL = hql.toLowerCase();
		if (lcHQL.startsWith("select") || lcHQL.startsWith("from")) {
			if (unique) {
				return uniqueResult(query);
			}

			return query.list();
		}
		// update
		return Double.valueOf(query.executeUpdate());
	}

	/**
	 * H5 contract: callers (cborm dynamic finders, ColdBox controllers) routinely pass
	 * CFML-typed date strings as HQL parameters and rely on Lucee/Hibernate string-to-date
	 * autocoercion. H7's JdbcDateJavaType.wrap rejects String inputs outright with
	 * "argument [X] is not assignable to java.util.Date", so the previous trust-the-engine
	 * spike (Stage 7) leaves real-world apps broken at the bind site. When the parameter's
	 * inferred slot type is Date-shaped and the value is a String, coerce up front via
	 * Lucee's caster so SQM sees a value it can bind. Other types pass through unchanged.
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	private static Object coerceForBind(Object value, QueryParameter<?> qp, ParameterMetadata meta) throws PageException {
		if (!(value instanceof String) || qp == null) return value;
		Class<?> target = qp.getParameterType();
		if (target == null) {
			BindableType bt = meta.getInferredParameterType((QueryParameter) qp);
			if (bt != null) target = bt.getJavaType();
		}
		if (target != null && java.util.Date.class.isAssignableFrom(target)) {
			return CommonUtil.toDate(value, null);
		}
		return value;
	}

	private Object uniqueResult(Query<?> query) throws PageException {
		try {
			return query.uniqueResult();
		}
		catch (NonUniqueResultException e) {
			List list = query.list();
			if (list.size() > 0) return list.iterator().next();
			throw CommonUtil.toPageException(e);
		}
		catch (Exception e) {
			throw CommonUtil.toPageException(e);
		}
	}

	@Override
	public lucee.runtime.type.Query toQuery(PageContext pc, Object obj, String name) throws PageException {
		return HibernateCaster.toQuery(pc, this, obj, name);
	}

	@Override
	public void close(PageContext pc) throws PageException {
		close(pc, null);
	}

	@Override
	public void close(PageContext pc, String datasource) throws PageException {
		DataSource ds = CommonUtil.getDataSource(pc, datasource);
		Key dsn = CommonUtil.toKey(ds.getName());

		// close Session
		SessionAndConn sac = sessions.remove(dsn);
		if (sac != null && sac.isOpen()) sac.close(pc);

	}

	@Override
	public void closeAll(PageContext pc) throws PageException {
		data.deregisterSession( this );
		Exception first = null;
		for (SessionAndConn sac : sessions.values()) {
			try {
				if (sac.isOpen()) sac.close(pc);
			}
			catch (Exception e) {
				if (first == null) first = e;
			}
		}
		sessions.clear();
		if (first != null) throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(first);
	}

	/**
	 * Release connections from idle sessions and invalidate active ones.
	 *
	 * Called from {@link SessionFactoryData#reset()} during ORMReload() — must not throw.
	 *
	 * Idle sessions (no active transaction) are closed immediately to release their borrowed
	 * connection. Active sessions (mid-transaction) are marked as invalidated — the owning thread
	 * will roll back and close on its next ORM operation or at end of request. We do NOT close
	 * active sessions cross-thread because that could release a JDBC connection while the owning
	 * thread is mid-flush, causing connection pool corruption.
	 */
	void invalidateAll() {
		for (SessionAndConn sac : sessions.values()) {
			sac.invalidate();
		}
	}

	boolean hasOpenSessions() {
		for (SessionAndConn sac : sessions.values()) {
			if (sac.isOpen()) return true;
		}
		return false;
	}

	@Override
	public Component merge(PageContext pc, Object obj) throws PageException {
		Component cfc = HibernateCaster.toComponent(obj);
		CFCInfo info = data.checkExistent(pc, cfc);

		String name = HibernateCaster.getEntityName(cfc);

		return CommonUtil.toComponent(getSession(pc, CommonUtil.toKey(info.getDataSource().getName())).merge(name, cfc));
	}

	@Override
	public Component load(PageContext pc, String name, Struct filter) throws PageException {
		return (Component) load(pc, name, filter, null, null, true);
	}

	@Override
	public Array loadAsArray(PageContext pc, String name, Struct filter) throws PageException {
		return loadAsArray(pc, name, filter, null, null);
	}

	@Override
	public Array loadAsArray(PageContext pc, String name, String id, String order) throws PageException {
		return loadAsArray(pc, name, id);// order is ignored in this case ACF compatibility
	}

	@Override
	public Array loadAsArray(PageContext pc, String name, String id) throws PageException {
		Array arr = CommonUtil.createArray();
		Component c = load(pc, name, id);
		if (c != null) arr.append(c);
		return arr;
	}

	@Override
	public Array loadAsArray(PageContext pc, String name, Struct filter, Struct options) throws PageException {
		return loadAsArray(pc, name, filter, options, null);
	}

	@Override
	public Array loadAsArray(PageContext pc, String name, Struct filter, Struct options, String order) throws PageException {
		return CommonUtil.toArray(load(pc, name, filter, options, order, false));
	}

	@Override
	public Component load(PageContext pc, String cfcName, String id) throws PageException {
		return load(pc, cfcName, (Object) id);
	}

	public Component load(PageContext pc, String cfcName, Object id) throws PageException {
		// Component cfc = create(pc,cfcName);
		Component cfc = data.getEngine().create(pc, this, cfcName, false);
		Key dsn = CommonUtil.toKey(CommonUtil.getDataSourceName(pc, cfc));
		Session sess = getSession(pc, dsn);
		String name = HibernateCaster.getEntityName(cfc);
		Object obj = null;
		try {
			EntityPersister metaData = ((SessionFactoryImplementor) sess.getSessionFactory()).getMappingMetamodel().findEntityDescriptor(name);
			if (metaData == null) throw ExceptionUtil.createException(this, null, "Could not load meta information for entity [" + name + "]", null);
			Serializable oId;
			// LDEV-2121: a struct holds the values of a composite primary key
			if (isCompositeIdStruct(id)) oId = toCompositeId(pc, metaData, name, (Struct) id);
			else oId = CommonUtil.toSerializable(CommonUtil.castTo(pc, metaData.getIdentifierType().getReturnedClass(), id));
			obj = sess.find(name, oId);
		}
		catch (Exception e) {
			throw CommonUtil.toPageException(e);
		}

		return (Component) obj;
	}

	@Override
	public Component loadByExample(PageContext pc, Object obj) throws PageException {
		Object res = loadByExample(pc, obj, true);
		if (res == null) return null;
		return CommonUtil.toComponent(res);
	}

	@Override
	public Array loadByExampleAsArray(PageContext pc, Object obj) throws PageException {
		return CommonUtil.toArray(loadByExample(pc, obj, false));
	}

	private Object loadByExample(PageContext pc, Object obj, boolean unique) throws PageException {
		Component cfc = HibernateCaster.toComponent(obj);
		Key dsn = CommonUtil.toKey(CommonUtil.getDataSourceName(pc, cfc));
		ComponentScope scope = cfc.getComponentScope();
		String name = HibernateCaster.getEntityName(cfc);
		Session sess = getSession(pc, dsn);

		try {
			SessionFactoryImplementor sfi = (SessionFactoryImplementor) sess.getSessionFactory();
			EntityPersister metaData = sfi.getMappingMetamodel().findEntityDescriptor(name);
			String idName = metaData.getIdentifierPropertyName();
			Type idType = metaData.getIdentifierType();

			CriteriaBuilder cb = sess.getCriteriaBuilder();
			CriteriaQuery<Object> cq = cb.createQuery();
			EntityDomainType<?> entityType = sfi.getJpaMetamodel().entity(name);
			Root<?> root = cq.from(entityType);
			cq.select(root);

			List<Predicate> predicates = new ArrayList<>();

			// Match the identifier if it's set on the example CFC
			if (!Util.isEmpty(idName)) {
				Object idValue = scope.get(CommonUtil.createKey(idName), null);
				if (idValue != null) {
					predicates.add(cb.equal(root.get(idName), HibernateCaster.toSQL(idType, idValue, null)));
				}
			}

			// Manual query-by-example: equal predicate for every non-null property other than id/version.
			// Replaces Hibernate 5.x Example.create() (removed in 7.x).
			String[] propNames = metaData.getPropertyNames();
			for (String propName : propNames) {
				if (propName.equals(idName)) continue;
				Object value = scope.get(CommonUtil.createKey(propName), null);
				if (value == null) continue;
				if (!(value instanceof Component)) {
					Type propType = HibernateUtil.getPropertyType(metaData, propName, null);
					value = HibernateCaster.toSQL(propType, value, null);
				}
				predicates.add(cb.equal(root.get(propName), value));
			}

			if (!predicates.isEmpty()) cq.where(predicates.toArray(new Predicate[0]));

			SelectionQuery<Object> q = sess.createSelectionQuery(cq);
			return unique ? q.uniqueResult() : q.getResultList();
		}
		catch (Exception e) {
			throw CommonUtil.toPageException(e);
		}
	}

	private Object load(PageContext pc, String cfcName, Struct filter, Struct options, String order, boolean unique) throws PageException {
		Component cfc = data.getEngine().create(pc, this, cfcName, false);
		Key dsn = CommonUtil.toKey(CommonUtil.getDataSourceName(pc, cfc));
		Session sess = getSession(pc, dsn);

		String name = HibernateCaster.getEntityName(cfc);
		SessionFactoryImplementor sfi = (SessionFactoryImplementor) sess.getSessionFactory();
		EntityPersister metaData = null;

		try {
			CriteriaBuilder cb = sess.getCriteriaBuilder();
			CriteriaQuery<Object> cq = cb.createQuery();
			EntityDomainType<?> entityType = sfi.getJpaMetamodel().entity(name);
			Root<?> root = cq.from(entityType);
			cq.select(root);

			// filter
			if (filter != null && !filter.isEmpty()) {
				metaData = sfi.getMappingMetamodel().findEntityDescriptor(name);
				List<Predicate> predicates = new ArrayList<>();
				Iterator<Entry<Key, Object>> it = filter.entryIterator();
				while (it.hasNext()) {
					Entry<Key, Object> entry = it.next();
					String colName = HibernateUtil.validateColumnName(metaData, CommonUtil.toString(entry.getKey()));
					Type type = HibernateUtil.getPropertyType(metaData, colName, null);
					Object value = entry.getValue();
					if (!(value instanceof Component)) value = HibernateCaster.toSQL(type, value, null);
					predicates.add(value != null ? cb.equal(root.get(colName), value) : cb.isNull(root.get(colName)));
				}
				if (!predicates.isEmpty()) cq.where(predicates.toArray(new Predicate[0]));
			}

			// options
			boolean ignoreCase = false;
			int offset = 0;
			int max = -1;
			Boolean cacheable = null;
			int timeout = -1;
			if (options != null && !options.isEmpty()) {
				Boolean ignorecase = CommonUtil.toBoolean(options.get("ignorecase", null), null);
				if (ignorecase != null) ignoreCase = ignorecase.booleanValue();

				offset = CommonUtil.toIntValue(options.get("offset", null), 0);
				max = CommonUtil.toIntValue(options.get("maxresults", null), -1);
				cacheable = CommonUtil.toBoolean(options.get("cacheable", null), null);
				timeout = CommonUtil.toIntValue(options.get("timeout", null), -1);
			}

			// order
			if (!Util.isEmpty(order)) {
				if (metaData == null) metaData = sfi.getMappingMetamodel().findEntityDescriptor(name);

				String[] arr = CommonUtil.toStringArray(order, ",");
				CommonUtil.trimItems(arr);
				List<Order> orders = new ArrayList<>();
				for (int i = 0; i < arr.length; i++) {
					String[] parts = CommonUtil.toStringArray(arr[i], " \t\n\b\r");
					CommonUtil.trimItems(parts);
					String col = HibernateUtil.validateColumnName(metaData, parts[0]);
					boolean isDesc = false;
					if (parts.length > 1) {
						if (parts[1].equalsIgnoreCase("desc")) isDesc = true;
						else if (!parts[1].equalsIgnoreCase("asc")) {
							throw ExceptionUtil.createException((ORMSession) null, null, "Invalid order direction definition [" + parts[1] + "]", "valid values are [asc, desc]");
						}
					}
					Path<?> path = root.get(col);
					Expression<?> expr = ignoreCase && CharSequence.class.isAssignableFrom(path.getJavaType())
							? cb.lower(path.as(String.class))
							: path;
					orders.add(isDesc ? cb.desc(expr) : cb.asc(expr));
				}
				if (!orders.isEmpty()) cq.orderBy(orders);
			}

			SelectionQuery<Object> q = sess.createSelectionQuery(cq);
			if (offset > 0) q.setFirstResult(offset);
			if (max > -1) q.setMaxResults(max);
			if (cacheable != null) q.setCacheable(cacheable.booleanValue());
			if (timeout > -1) q.setTimeout(timeout);

			Object rtn = unique ? q.uniqueResult() : q.getResultList();
			return HibernateCaster.toCFML(rtn);
		}
		catch (Exception e) {
			throw CommonUtil.toPageException(e);
		}
	}

	@Override
	public Session getRawSession(String dsn) throws PageException {
		return getSession(null, CommonUtil.toKey(dsn));
	}

	@Override
	public SessionFactory getRawSessionFactory(String dsn) throws PageException {
		return getSession(null, CommonUtil.toKey(dsn)).getSessionFactory();
	}

	@Override
	public boolean isValid(DataSource ds) {
		SessionAndConn sac = sessions.get(CommonUtil.toKey(ds.getName()));
		return sac != null && sac.isOpen();
	}

	@Override
	public boolean isValid() {
		// With lazy session opening, sessions starts empty. Returning true here seems correct
		// (no sessions yet = valid) but causes Lucee to reuse sessions across apps that haven't
		// initialized ORM, breaking LDEV0613/LDEV1984. Needs investigation before changing.
		if (sessions.size() == 0) return false;
		Iterator<SessionAndConn> it = sessions.values().iterator();

		while (it.hasNext()) {
			if (!it.next().isOpen()) return false;
		}
		return true;
	}

	@Override
	public ORMTransaction getTransaction(String dsn, boolean autoManage) throws PageException {
		return new HibernateORMTransaction(getSession(null, CommonUtil.toKey(dsn)), autoManage);
	}

	@Override
	public String[] getEntityNames() {
		List<String> names = data.getEntityNames();
		return names.toArray(new String[names.size()]);
	}

	@Override
	public DataSource[] getDataSources() {
		return data.getDataSources();
	}

	private static String addIndexIfNecessary(String sql) {
		// if(namedParams.size()==0) return new Pair<String, List<Param>>(sql,params);
		StringBuilder sb = new StringBuilder();
		int sqlLen = sql.length();
		char c, quoteType = 0;
		boolean inQuotes = false;
		int qm = 0, _qm = 0;
		int index = 1;
		for (int i = 0; i < sqlLen; i++) {
			c = sql.charAt(i);

			if (c == '"' || c == '\'') {
				if (inQuotes) {
					if (c == quoteType) {
						inQuotes = false;
					}
				}
				else {
					quoteType = c;
					inQuotes = true;
				}
			}

			if (!inQuotes && c == '?') {
				// is the next a number?
				if (sqlLen > i + 1 && isInteger(sql.charAt(i + 1))) {
					return sql;
				}

				sb.append(c).append(index++);
			}
			else {
				sb.append(c);
			}
		}

		return sb.toString();
	}

	private static final boolean isInteger(char c) {
		return c >= '0' && c <= '9';
	}
}