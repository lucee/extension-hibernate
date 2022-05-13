package org.lucee.extension.orm.hibernate;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.hibernate.Criteria;
import org.hibernate.FlushMode;
import org.hibernate.NonUniqueResultException;
import org.hibernate.QueryException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.criterion.Example;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;
import org.hibernate.engine.query.spi.HQLQueryPlan;
import org.hibernate.internal.SessionFactoryImpl;
import org.hibernate.metadata.ClassMetadata;
import org.hibernate.query.Query;
import org.hibernate.query.internal.ParameterMetadataImpl;
import org.hibernate.type.Type;

import lucee.commons.lang.types.RefBoolean;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.ComponentScope;
import lucee.runtime.PageContext;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.db.SQLItem;
import lucee.runtime.exp.PageException;
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
		private DatasourceConnection dc;
		private final DataSource d;
		private SessionFactory factory;

		/*
		 * public SessionAndConn(Session session, DatasourceConnection dc) { this.session = session; this.dc
		 * = dc; this.d = dc.getDatasource(); }
		 * 
		 * public SessionAndConn(Session session, DataSource d) { this.session = session; this.d = d; }
		 */

		public SessionAndConn(PageContext pc, SessionFactory factory, DataSource ds) throws PageException {
			this.d = ds;
			this.factory = factory;
			getSession(pc);
		}

		public Session getSession(PageContext pc) throws PageException {
			if (s == null || !s.isOpen()) s = factory.openSession();
			return s;
		}

		public Connection getConnection(PageContext pc) throws PageException {
			try {
				if (dc == null || dc.isClosed()) {
					connect(pc);
				}
			}
			catch (SQLException e) {
				throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
			}
			return dc.getConnection();
		}

		public void connect(PageContext pc) throws PageException {
			if (dc != null) CommonUtil.releaseDatasourceConnection(pc, dc, true);
			dc = CommonUtil.getDatasourceConnection(pc, d, null, null, true);
		}

		public void close(PageContext pc) throws PageException {
			if (s != null && s.isOpen()) {
				s.close();
				s = null;
			}

			if (dc != null) {
				CommonUtil.releaseDatasourceConnection(pc, dc, true);
				dc = null;
			}
		}

		public boolean isOpen() {
			return s != null && s.isOpen();
		}

		public DataSource getDataSource() {
			return d;
		}
	}

	private SessionFactoryData data;
	private Map<Key, SessionAndConn> sessions = new HashMap<Key, SessionAndConn>();

	public HibernateORMSession(PageContext pc, SessionFactoryData data) throws PageException {
		this.data = data;
		// this.dc=dc;
		DataSource[] sources = data.getDataSources();

		for (int i = 0; i < sources.length; i++) {
			createSession(pc, data.getFactory(CommonUtil.toKey(sources[i].getName())), sources[i]);
		}
	}

	/*
	 * private Session session(){ return _session; }
	 */

	private Session getSession(PageContext pc, Key datasSourceName) throws PageException {
		return getSessionAndConn(pc, datasSourceName).getSession(pc);
	}

	private SessionAndConn getSessionAndConn(PageContext pc, Key datasSourceName) throws PageException {
		SessionAndConn sac = sessions.get(datasSourceName);
		if (sac == null) {
			CFMLEngineFactory.getInstance().getExceptionUtil().similarKeyMessage(sessions.keySet().toArray(new Key[sessions.size()]), datasSourceName.getString(), "datasource",
					"datasources", null, true);
			throw ExceptionUtil.createException(data, null, "there is no Session for the datasource [" + datasSourceName + "]", null);
		}
		Session s = sac.getSession(pc);
		if (!s.isOpen() || !s.isConnected() || isClosed(s)) {
			if (pc == null) pc = CFMLEngineFactory.getInstance().getThreadPageContext();

			sac.connect(pc);
			s.reconnect(sac.getConnection(pc));

		}
		return sac;
	}

	private boolean isClosed(Session s) throws PageException {
		return !s.isConnected();
	}

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

	Session createSession(PageContext pc, SessionFactory factory, DataSource ds) throws PageException {
		SessionAndConn sac = new SessionAndConn(pc, factory, ds);

		sessions.put(CommonUtil.toKey(ds.getName()), sac);
		sac.getSession(pc).setFlushMode(FlushMode.MANUAL);
		return sac.getSession(pc);
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
				} // we do this because of a Bug in Lucee that keeps session object in case of an exception for future
					// request, this session then fail to flush, because the underlaying datasource is not defined in
					// the current application.cfc.
			}
		}
	}

	@Override
	public void flush(PageContext pc) throws PageException {
		flush(pc, null);
	}

	@Override
	public void flush(PageContext pc, String datasource) throws PageException {
		_flush(pc, CommonUtil.getDataSource(pc, datasource));
	}

	private void _flush(PageContext pc, DataSource datasource) throws PageException {
		Key dsn = CommonUtil.toKey(datasource.getName());

		try {
			getSession(pc, dsn).flush();
		}
		catch (Throwable t) {
			throw CommonUtil.toPageException(t);
		}

	}

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
				if (trans.isActive()) trans.begin();
				else trans = null;

				try {
					Iterator<Component> _it = e.getValue().iterator();
					while (_it.hasNext()) {
						_delete(pc, _it.next(), e.getKey());
					}
				}
				catch (Throwable t) {
					if (trans != null) trans.rollback();
					throw CommonUtil.toPageException(t);
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
			getSession(pc, dsn).delete(HibernateCaster.getEntityName(cfc), cfc);
		}
		catch (Throwable t) {
			throw CommonUtil.toPageException(t);
		}
	}

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
			if (forceInsert) session.save(name, cfc);
			else session.saveOrUpdate(name, cfc);
		}
		catch (Exception e) {
			throw ExceptionUtil.createException(this, null, e);
		}
	}

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

	@Override
	public void clear(PageContext pc) throws PageException {
		clear(pc, null);
	}

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
		entityName = correctCaseEntityName(entityName);

		Iterator<SessionAndConn> it = sessions.values().iterator();
		SessionAndConn sac;
		while (it.hasNext()) {
			sac = it.next();
			SessionFactory f = sac.getSession(pc).getSessionFactory();
			if (id == null) f.getCache().evictEntityRegion(entityName);
			else f.getCache().evictEntity(entityName, CommonUtil.toSerializable(id));
		}
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

		Iterator<SessionAndConn> it = sessions.values().iterator();
		SessionAndConn sac;
		while (it.hasNext()) {
			sac = it.next();
			SessionFactory f = sac.getSession(pc).getSessionFactory();
			if (id == null) f.getCache().evictCollectionRegion(role);
			else f.getCache().evictCollection(role, CommonUtil.toSerializable(id));
		}
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
				catch (Throwable t) {
					if (t instanceof ThreadDeath) throw (ThreadDeath) t;
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
					throw ExceptionUtil.createException(this, null, "option [maxresults] has an invalid value [" + obj + "], value should be a number bigger or equal to 0", null);
				query.setMaxResults(max);
			}
			// offset
			obj = options.get("offset", null);
			if (obj != null) {
				int off = CommonUtil.toIntValue(obj, -1);
				if (off < 0)
					throw ExceptionUtil.createException(this, null, "option [offset] has an invalid value [" + obj + "], value should be a number bigger or equal to 0", null);
				query.setFirstResult(off);
			}
			// readonly
			obj = options.get("readonly", null);
			if (obj != null) {
				Boolean ro = CommonUtil.toBoolean(obj, null);
				if (ro == null) throw ExceptionUtil.createException(this, null, "option [readonly] has an invalid value [" + obj + "], value should be a boolean value", null);
				query.setReadOnly(ro.booleanValue());
			}
			// timeout
			obj = options.get("timeout", null);
			if (obj != null) {
				int to;
				if (obj instanceof TimeSpan) to = (int) ((TimeSpan) obj).getSeconds();
				else to = CommonUtil.toIntValue(obj, -1);

				if (to < 0)
					throw ExceptionUtil.createException(this, null, "option [timeout] has an invalid value [" + obj + "], value should be a number bigger or equal to 0", null);
				query.setTimeout(to);
			}
		}

		// params
		if (params != null) {
			HQLQueryPlan plan = ((SessionFactoryImpl) session.getSessionFactory()).getQueryPlanCache().getHQLQueryPlan(hql, false, java.util.Collections.EMPTY_MAP);

			ParameterMetadataImpl meta = plan.getParameterMetadata();
			Type type;
			Object obj;

			// struct
			if (CommonUtil.isStruct(params)) {
				Struct sct = CommonUtil.toStruct(params);
				String name;
				// fix case-senstive
				Struct names = CommonUtil.createStruct();
				if (meta != null) {
					Iterator<String> it = meta.getNamedParameterNames().iterator();
					while (it.hasNext()) {
						name = it.next();
						names.setEL(name, name);
					}
				}

				RefBoolean isArray = CommonUtil.createRefBoolean();
				Iterator<Entry<Key, Object>> it = sct.entryIterator();
				Entry<Key, Object> e;
				while (it.hasNext()) {
					e = it.next();
					obj = sct.get(e.getKey(), null);
					if (meta != null) {
						name = (String) names.get(e.getKey(), null);
						if (name == null) continue; // param not needed will be ignored
						type = meta.getNamedParameterExpectedType(name);

						obj = HibernateCaster.toSQL(type, obj, isArray);
						if (isArray.toBooleanValue()) {
							if (obj instanceof Object[]) query.setParameterList(name, (Object[]) obj, type);
							else if (obj instanceof List) query.setParameterList(name, (List) obj, type);
							else query.setParameterList(name, CFMLEngineFactory.getInstance().getCastUtil().toList(obj), type);
						}
						else query.setParameter(name, obj, type);

					}
					else query.setParameter(e.getKey().getString(), obj);
				}
			}

			// array
			else if (isParamArray) {
				Array arr = CommonUtil.toArray(params);

				if (meta.getOrdinalParameterCount() > arr.size()) throw ExceptionUtil.createException(this, null,
						"parameter array is to small [" + arr.size() + "], need [" + meta.getOrdinalParameterCount() + "] elements", null);

				Iterator it = arr.valueIterator();
				int idx = 1;
				SQLItem item;
				RefBoolean isArray = null;

				while (it.hasNext()) {
					type = null;
					obj = it.next();
					if (obj instanceof SQLItem) {
						item = (SQLItem) obj;
						obj = item.getValue();
					}
					if (meta != null) {
						type = meta.getOrdinalParameterExpectedType(idx);
					}

					if (type != null) query.setParameter(idx, HibernateCaster.toSQL(type, obj, isArray), type);
					else query.setParameter(idx, obj);
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
		return new Double(query.executeUpdate());
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
		catch (Throwable t) {
			throw CommonUtil.toPageException(t);
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
		Iterator<SessionAndConn> it = sessions.values().iterator();
		SessionAndConn sac;
		while (it.hasNext()) {
			sac = it.next();
			if (sac.isOpen()) sac.close(pc);
		}
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
			ClassMetadata metaData = sess.getSessionFactory().getClassMetadata(name);
			if (metaData == null) throw ExceptionUtil.createException(this, null, "could not load meta information for entity [" + name + "]", null);
			Serializable oId = CommonUtil.toSerializable(CommonUtil.castTo(pc, metaData.getIdentifierType().getReturnedClass(), id));
			obj = sess.get(name, oId);
		}
		catch (Throwable t) {
			throw CommonUtil.toPageException(t);
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
		Object rtn = null;

		try {
			// trans.begin();

			ClassMetadata metaData = sess.getSessionFactory().getClassMetadata(name);
			String idName = metaData.getIdentifierPropertyName();
			Type idType = metaData.getIdentifierType();

			Criteria criteria = sess.createCriteria(name);
			if (!Util.isEmpty(idName)) {
				Object idValue = scope.get(CommonUtil.createKey(idName), null);
				if (idValue != null) {
					criteria.add(Restrictions.eq(idName, HibernateCaster.toSQL(idType, idValue, null)));
				}
			}
			criteria.add(Example.create(cfc));

			// execute

			if (!unique) {
				rtn = criteria.list();
			}
			else {
				// Map map=(Map) criteria.uniqueResult();
				rtn = criteria.uniqueResult();
			}
		}
		catch (Throwable t) {
			// trans.rollback();
			throw CommonUtil.toPageException(t);
		}
		// trans.commit();

		return rtn;
	}

	private Object load(PageContext pc, String cfcName, Struct filter, Struct options, String order, boolean unique) throws PageException {
		Component cfc = data.getEngine().create(pc, this, cfcName, false);
		Key dsn = CommonUtil.toKey(CommonUtil.getDataSourceName(pc, cfc));
		Session sess = getSession(pc, dsn);

		String name = HibernateCaster.getEntityName(cfc);
		ClassMetadata metaData = null;

		Object rtn;
		try {
			Criteria criteria = sess.createCriteria(name);

			// filter
			if (filter != null && !filter.isEmpty()) {
				metaData = sess.getSessionFactory().getClassMetadata(name);
				Object value;
				Entry<Key, Object> entry;
				Iterator<Entry<Key, Object>> it = filter.entryIterator();
				String colName;
				while (it.hasNext()) {
					entry = it.next();
					colName = HibernateUtil.validateColumnName(metaData, CommonUtil.toString(entry.getKey()));
					Type type = HibernateUtil.getPropertyType(metaData, colName, null);
					value = entry.getValue();
					if (!(value instanceof Component)) value = HibernateCaster.toSQL(type, value, null);

					if (value != null) criteria.add(Restrictions.eq(colName, value));
					else criteria.add(Restrictions.isNull(colName));
				}
			}

			// options
			boolean ignoreCase = false;
			if (options != null && !options.isEmpty()) {
				// ignorecase
				Boolean ignorecase = CommonUtil.toBoolean(options.get("ignorecase", null), null);
				if (ignorecase != null) ignoreCase = ignorecase.booleanValue();

				// offset
				int offset = CommonUtil.toIntValue(options.get("offset", null), 0);
				if (offset > 0) criteria.setFirstResult(offset);

				// maxResults
				int max = CommonUtil.toIntValue(options.get("maxresults", null), -1);
				if (max > -1) criteria.setMaxResults(max);

				// cacheable
				Boolean cacheable = CommonUtil.toBoolean(options.get("cacheable", null), null);
				if (cacheable != null) criteria.setCacheable(cacheable.booleanValue());

				// MUST cacheName ?

				// maxResults
				int timeout = CommonUtil.toIntValue(options.get("timeout", null), -1);
				if (timeout > -1) criteria.setTimeout(timeout);
			}

			// order
			if (!Util.isEmpty(order)) {
				if (metaData == null) metaData = sess.getSessionFactory().getClassMetadata(name);

				String[] arr = CommonUtil.toStringArray(order, ",");
				CommonUtil.trimItems(arr);
				String[] parts;
				String col;
				boolean isDesc;
				Order _order;
				// ColumnInfo ci;
				for (int i = 0; i < arr.length; i++) {
					parts = CommonUtil.toStringArray(arr[i], " \t\n\b\r");
					CommonUtil.trimItems(parts);
					col = parts[0];

					col = HibernateUtil.validateColumnName(metaData, col);
					isDesc = false;
					if (parts.length > 1) {
						if (parts[1].equalsIgnoreCase("desc")) isDesc = true;
						else if (!parts[1].equalsIgnoreCase("asc")) {
							throw ExceptionUtil.createException((ORMSession) null, null, "invalid order direction defintion [" + parts[1] + "]", "valid values are [asc, desc]");
						}

					}
					_order = isDesc ? Order.desc(col) : Order.asc(col);
					if (ignoreCase) _order.ignoreCase();

					criteria.addOrder(_order);

				}
			}

			// execute
			if (!unique) {
				rtn = HibernateCaster.toCFML(criteria.list());
			}
			else {
				rtn = HibernateCaster.toCFML(criteria.uniqueResult());
			}

		}
		catch (Throwable t) {
			throw CommonUtil.toPageException(t);
		}
		return rtn;
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