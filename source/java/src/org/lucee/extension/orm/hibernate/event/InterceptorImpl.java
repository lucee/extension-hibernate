package org.lucee.extension.orm.hibernate.event;

import java.io.Serializable;
import java.util.Iterator;

import org.hibernate.CallbackException;
import org.hibernate.EmptyInterceptor;
import org.hibernate.EntityMode;
import org.hibernate.event.spi.AbstractEvent;
import org.hibernate.type.Type;
import org.lucee.extension.orm.hibernate.CommonUtil;
import org.lucee.extension.orm.hibernate.HibernateCaster;

import lucee.runtime.Component;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Collection;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.type.Struct;

public class InterceptorImpl extends EmptyInterceptor {

	private static final long serialVersionUID = 7992972603422833660L;

	private final EVComponent listener;
	private final boolean hasPreInsert;
	private final boolean hasPreUpdate;

	public InterceptorImpl(EVComponent listener) {
		this.listener = listener;
		if (listener != null) {
			Component cfc = listener.getComp();
			hasPreInsert = EVComponent.hasEventType(cfc, CommonUtil.PRE_INSERT);
			hasPreUpdate = EVComponent.hasEventType(cfc, CommonUtil.PRE_UPDATE);
		}
		else {
			hasPreInsert = false;
			hasPreUpdate = false;
		}
	}

	@Override
	public boolean onSave(Object entity, Serializable id, Object[] state, String[] propertyNames, Type[] types) {
		ThreadLocalStatus.setit(true);
		return on(entity, id, state, null, propertyNames, types, CommonUtil.PRE_INSERT, hasPreInsert);
		// return super.onSave(entity, id, state, propertyNames, types);
	}

	@Override
	public boolean onFlushDirty(Object entity, Serializable id, Object[] currentState, Object[] previousState, String[] propertyNames, Type[] types) {
		if (ThreadLocalStatus.getit()) {
			ThreadLocalStatus.setit(false);
			return super.onFlushDirty(entity, id, currentState, previousState, propertyNames, types);
		}
		return on(entity, id, currentState, toStruct(propertyNames, previousState), propertyNames, types, CommonUtil.PRE_UPDATE, hasPreUpdate);
	}

	public void invoke(Component caller, Key name, Object obj, AbstractEvent event, Struct data) {
	}

	public static void _invoke(Component cfc, Key name, Struct data, Object arg, AbstractEvent event) {
	}

	private boolean on(Object entity, Serializable id, Object[] state, Struct data, String[] propertyNames, Type[] types, Collection.Key eventType, boolean hasMethod) {

		Component cfc = CommonUtil.toComponent(entity, null);
		if (cfc != null && EVComponent.hasEventType(cfc, eventType)) {
			EVComponent.invoke(eventType, cfc, data, null);
			// EVComponent.invoke(eventType, cfc, data, null);
		}
		if (hasMethod) EVComponent.invoke(eventType, listener.getComp(), data, entity);

		boolean rtn = false;
		String prop;
		Object before, current;
		/*
		 * jira2049 ORMSession session = null; try {
		 * session=ORMUtil.getSession(ThreadLocalPageContext.get()); } catch (PageException pe) {}
		 */

		for (int i = 0; i < propertyNames.length; i++) {
			prop = propertyNames[i];
			before = state[i];
			current = CommonUtil.getPropertyValue(/* jira2049 session, */cfc, prop, null);

			if (before != current && (current == null || !CommonUtil.equalsComplexEL(before, current))) {
				try {
					state[i] = HibernateCaster.toSQL(types[i], current, null);
				}
				catch (PageException e) {
					state[i] = current;
				}
				rtn = true;
			}
		}
		return rtn;
	}

	private static Struct toStruct(String propertyNames[], Object state[]) {
		Struct sct = CommonUtil.createStruct();
		if (state != null && propertyNames != null) {
			for (int i = 0; i < propertyNames.length; i++) {
				sct.setEL(CommonUtil.createKey(propertyNames[i]), state[i]);
			}
		}
		return sct;
	}

	@Override
	public boolean onLoad(Object entity, Serializable id, Object[] state, String[] propertyNames, Type[] types) {
		return super.onLoad(entity, id, state, propertyNames, types);
	}

	@Override
	public void preFlush(Iterator entities) {
		super.preFlush(entities);
	}

	@Override
	public Object instantiate(String entityName, EntityMode entityMode, Serializable id) {
		return super.instantiate(entityName, entityMode, id);
	}

	@Override
	public void onCollectionRecreate(Object collection, Serializable key) throws CallbackException {
		super.onCollectionRecreate(collection, key);
	}

	@Override
	public void onCollectionRemove(Object collection, Serializable key) throws CallbackException {
		super.onCollectionRemove(collection, key);
	}

	@Override
	public void onCollectionUpdate(Object collection, Serializable key) throws CallbackException {
		super.onCollectionUpdate(collection, key);
	}

	@Override
	public void onDelete(Object entity, Serializable id, Object[] state, String[] propertyNames, Type[] types) {
		super.onDelete(entity, id, state, propertyNames, types);
	}

	@Override
	public String onPrepareStatement(String sql) {
		return super.onPrepareStatement(sql);
	}

	private static class ThreadLocalStatus extends ThreadLocal {

		@Override
		protected Object initialValue() {
			return Boolean.FALSE;
		}

		private static ThreadLocal<Boolean> insertDone = new ThreadLocal<Boolean>();

		public static boolean getit() {
			return insertDone.get();
		}

		public static void setit(boolean b) {
			insertDone.set(b);
		}

		/**
		 * release the pagecontext for the current thread
		 */
		public static void release() {// print.ds(Thread.currentThread().getName());
			insertDone.set(Boolean.FALSE);
		}

	}
}
