package org.lucee.extension.orm.hibernate.event;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.hibernate.HibernateException;
import org.hibernate.boot.Metadata;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.hibernate.event.service.spi.EventListenerRegistry;
import org.hibernate.event.spi.AbstractEvent;
import org.hibernate.event.spi.AutoFlushEvent;
import org.hibernate.event.spi.AutoFlushEventListener;
import org.hibernate.event.spi.ClearEvent;
import org.hibernate.event.spi.ClearEventListener;
import org.hibernate.event.spi.DeleteEvent;
import org.hibernate.event.spi.DeleteEventListener;
import org.hibernate.event.spi.DirtyCheckEvent;
import org.hibernate.event.spi.DirtyCheckEventListener;
import org.hibernate.event.spi.EventType;
import org.hibernate.event.spi.EvictEvent;
import org.hibernate.event.spi.EvictEventListener;
import org.hibernate.event.spi.FlushEvent;
import org.hibernate.event.spi.FlushEventListener;
import org.hibernate.event.spi.PostDeleteEvent;
import org.hibernate.event.spi.PostDeleteEventListener;
import org.hibernate.event.spi.PreInsertEvent;
import org.hibernate.event.spi.PreInsertEventListener;
import org.hibernate.event.spi.PostInsertEvent;
import org.hibernate.event.spi.PostInsertEventListener;
import org.hibernate.event.spi.PostLoadEvent;
import org.hibernate.event.spi.PostLoadEventListener;
import org.hibernate.event.spi.PreUpdateEvent;
import org.hibernate.event.spi.PreUpdateEventListener;
import org.hibernate.event.spi.PostUpdateEvent;
import org.hibernate.event.spi.PostUpdateEventListener;
import org.hibernate.event.spi.PreDeleteEvent;
import org.hibernate.event.spi.PreDeleteEventListener;
import org.hibernate.event.spi.PreLoadEvent;
import org.hibernate.event.spi.PreLoadEventListener;
import org.hibernate.integrator.spi.Integrator;
import org.hibernate.persister.entity.EntityPersister;
import org.hibernate.service.spi.SessionFactoryServiceRegistry;
import org.lucee.extension.orm.hibernate.CommonUtil;

import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Collection;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.type.Struct;
import lucee.runtime.type.UDF;

/**
 * Integrate Hibernate events with the EventHandler and component listener UDFs.
 *
 * For example, a <code>postInsert()</code> method in a <code>User</code> entity will be invoked prior to the entity's
 * insertion into the database. This same method will also be invoked on the EventHandler component, if configured.
 */
public class EventListenerIntegrator implements Integrator, PreInsertEventListener, PostInsertEventListener,
		PreDeleteEventListener, PostDeleteEventListener, DeleteEventListener, PreUpdateEventListener,
		PostUpdateEventListener, PreLoadEventListener, PostLoadEventListener, FlushEventListener,
		AutoFlushEventListener, ClearEventListener, DirtyCheckEventListener, EvictEventListener {

	private static final long serialVersionUID = -5954121166467541422L;

	/**
	 * The EventHandler CFC defined in the application's `this.ormSettings.eventHandler`.
	 */
	private Component GlobalEventListener;
	private Map<String, Component> eventListeners = new ConcurrentHashMap<>();

	@Override
	public void integrate(Metadata metadata, SessionFactoryImplementor sessionFactory, SessionFactoryServiceRegistry serviceRegistry) {
		EventListenerRegistry eventListenerRegistry = serviceRegistry.getService(EventListenerRegistry.class);

		eventListenerRegistry.prependListeners(EventType.PRE_INSERT, this);
		eventListenerRegistry.prependListeners(EventType.POST_INSERT, this);

		eventListenerRegistry.prependListeners(EventType.PRE_DELETE, this);
		eventListenerRegistry.prependListeners(EventType.POST_DELETE, this);
		eventListenerRegistry.prependListeners(EventType.DELETE, this);

		eventListenerRegistry.prependListeners(EventType.PRE_UPDATE, this);
		eventListenerRegistry.prependListeners(EventType.POST_UPDATE, this);

		eventListenerRegistry.prependListeners(EventType.PRE_LOAD, this);
		eventListenerRegistry.prependListeners(EventType.POST_LOAD, this);

		eventListenerRegistry.prependListeners(EventType.AUTO_FLUSH, this);
		eventListenerRegistry.prependListeners(EventType.FLUSH, this);

		eventListenerRegistry.prependListeners(EventType.EVICT, this);
		eventListenerRegistry.prependListeners(EventType.CLEAR, this);

		eventListenerRegistry.prependListeners(EventType.DIRTY_CHECK, this);
	}

	@Override
	public void disintegrate(SessionFactoryImplementor sessionFactory, SessionFactoryServiceRegistry serviceRegistry) {

	}

	/**
	 * Set the "Global" EventHandler to fire on all events in the application.
	 *
	 * @param GlobalEventListener
	 *            Instantiated Lucee Component object.
	 */
	public void setGlobalEventListener(Component GlobalEventListener) {
		this.GlobalEventListener = GlobalEventListener;
	}

	/**
	 * Add this component to the list of listeners to be notified for an entity event.
	 * <p>
	 * Note this listener will ONLY fire for events related to itself. i.e. Car.preInsert will be run for Car entity
	 * preInsert events - not for User entity preInsert events.
	 *
	 * @param cfc
	 *            Instantiated Lucee Component object.
	 */
	public void appendEventListenerCFC(Component cfc) {
		this.eventListeners.put(cfc.getAbsName(), cfc);
	}

	@Override
	public boolean requiresPostCommitHanding(EntityPersister arg0) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean onPreInsert(PreInsertEvent event) {
		Struct state = entityStateToStruct(event.getPersister().getPropertyNames(), event.getState());
		fireEventOnGlobalListener(CommonUtil.PRE_INSERT, event.getEntity(), event, state);

		// fire on entity
		Component listener = getEventListener(event.getEntity());
		if (listener != null) {
			fireEventOnEntityListener(listener, CommonUtil.PRE_INSERT, event, state);
		}

		return false;
	}

	@Override
	public void onPostInsert(PostInsertEvent event) {
		fireEventOnGlobalListener(CommonUtil.POST_INSERT, event.getEntity(), event, null);

		// fire on entity
		Component listener = getEventListener(event.getEntity());
		if (listener != null) {
			fireEventOnEntityListener(listener, CommonUtil.POST_INSERT, event, null);
		}
	}

	// PreDeleteEventListener
	@Override
	public boolean onPreDelete(PreDeleteEvent event) {
		fireEventOnGlobalListener(CommonUtil.PRE_DELETE, event.getEntity(), event, null);

		Component listener = getEventListener(event.getEntity());
		if (listener != null) {
			fireEventOnEntityListener(listener, CommonUtil.PRE_DELETE, event, null);
		}
		return false;
	}

	// PostDeleteEventListener
	@Override
	public void onPostDelete(PostDeleteEvent event) {
		fireEventOnGlobalListener(CommonUtil.POST_DELETE, event.getEntity(), event, null);

		Component listener = getEventListener(event.getEntity());
		if (listener != null) {
			fireEventOnEntityListener(listener, CommonUtil.POST_DELETE, event, null);
		}
	}

	// PreUpdateEventListener
	@Override
	public boolean onPreUpdate(PreUpdateEvent event) {
		Struct oldState = entityStateToStruct(event.getPersister().getPropertyNames(), event.getOldState());
		fireEventOnGlobalListener(CommonUtil.PRE_UPDATE, event.getEntity(), event, oldState);

		Component listener = getEventListener(event.getEntity());
		if (listener != null) {
			fireEventOnEntityListener(listener, CommonUtil.PRE_UPDATE, event, oldState);
		}
		return false;
	}

	// PostUpdateEventListener
	@Override
	public void onPostUpdate(PostUpdateEvent event) {
		fireEventOnGlobalListener(CommonUtil.POST_UPDATE, event.getEntity(), event, null);

		Component listener = getEventListener(event.getEntity());
		if (listener != null) {
			fireEventOnEntityListener(listener, CommonUtil.POST_UPDATE, event, null);
		}
	}

	// PreLoadEventListener
	@Override
	public void onPreLoad(PreLoadEvent event) {
		fireEventOnGlobalListener(CommonUtil.PRE_LOAD, event.getEntity(), event, null);

		Component listener = getEventListener(event.getEntity());
		if (listener != null) {
			fireEventOnEntityListener(listener, CommonUtil.PRE_LOAD, event, null);
		}
	}

	// PostLoadEventListener
	@Override
	public void onPostLoad(PostLoadEvent event) {
		fireEventOnGlobalListener(CommonUtil.POST_LOAD, event.getEntity(), event, null);

		Component listener = getEventListener(event.getEntity());
		if (listener != null) {
			fireEventOnEntityListener(listener, CommonUtil.POST_LOAD, event, null);
		}
	}

	@Override
	public void onFlush(FlushEvent event) throws HibernateException {
		// Sadly, the FlushEvent does not allow / provide a method to retrieve the entity.
		Object entity = null;
		fireEventOnGlobalListener(CommonUtil.ON_FLUSH, entity, event, null);
	}

	@Override
	public void onAutoFlush(AutoFlushEvent event) throws HibernateException {
		// Sadly, the AutoFlushEvent does not allow / provide a method to retrieve the entity.
		Object entity = null;
		fireEventOnGlobalListener(CommonUtil.ON_AUTO_FLUSH, entity, event, null);
	}

	@Override
	public void onClear(ClearEvent event) {
		// Sadly, the ClearEvent does not allow / provide a method to retrieve the entity.
		Object entity = null;
		fireEventOnGlobalListener(CommonUtil.ON_CLEAR, entity, event, null);
	}

	@Override
	public void onDelete(DeleteEvent event) throws HibernateException {
		Object entity = event.getObject();
		fireEventOnGlobalListener(CommonUtil.ON_DELETE, entity, event, null);
	}

	@Override
	public void onDelete(DeleteEvent event, Set transientEntities) throws HibernateException {
		Object entity = event.getObject();
		// TODO: handle transientEntities
		fireEventOnGlobalListener(CommonUtil.ON_DELETE, entity, event, null);
	}

	@Override
	public void onDirtyCheck(DirtyCheckEvent event) throws HibernateException {
		// Sadly, the DirtyCheckEvent does not allow / provide a method to retrieve the entity.
		Object entity = null;
		fireEventOnGlobalListener(CommonUtil.ON_DIRTY_CHECK, entity, event, null);
	}

	@Override
	public void onEvict(EvictEvent event) throws HibernateException {
		// Sadly, the EvictEvent does not allow / provide a method to retrieve the entity.
		Object entity = null;
		fireEventOnGlobalListener(CommonUtil.ON_EVICT, entity, event, null);
	}

	/**
	 * Retrieve the configured "Global" event listener.
	 *
	 * i.e., the Component configured in `this.ormSettings.eventHandler`.
	 *
	 * @return The configured Component to use as this application's event handler.
	 */
	public Component getGlobalEventListener() {
		return GlobalEventListener;
	}

	/**
	 * Fire the event listener UDF on the configured global EventHandler listener.
	 * <p>
	 * If no global event handler is configured, will exit.
	 *
	 * @param name
	 *            event type name to fire, for example "preInsert" or "preDelete"
	 * @param entity
	 *            the entity from event.getEntity()
	 * @param event
	 *            the Hibernate event object.
	 * @param data
	 *            A struct of data to pass to the event
	 */
	public void fireEventOnGlobalListener(Key name, Object entity, AbstractEvent event, Struct data) {
		if (GlobalEventListener == null) {
			return;
		}

		_fireOnComponent(getGlobalEventListener(), name, entity, data, event);
	}

	/**
	 * Fire the event listener UDF, if found, on the entity component
	 *
	 * @param listener
	 *            the Lucee Component on which to fire this listener method
	 * @param name
	 *            event type name to fire, for example "preInsert" or "preDelete"
	 * @param event
	 *            the Hibernate event object.
	 * @param data
	 *            A struct of data to pass to the event
	 */
	public void fireEventOnEntityListener(Component listener, Key name, AbstractEvent event, Struct data) {
		_fireOnComponent(listener, name, data, event);
	}

	/**
	 * See if the given component has a method matching the given name.
	 *
	 * @param comp
	 *            Lucee Component to look on, for example events.EventHandler.
	 * @param methodName
	 *            Method name to look for, for example "preInsert"
	 *
	 * @return true if method found
	 */
	public static boolean componentHasMethod(Component comp, Collection.Key methodName) {
		return comp.get(methodName, null) instanceof UDF;
	}

	private static void _fireOnComponent(Component cfc, Key name, Object... args) {
		if (!componentHasMethod(cfc, name)) {
			return;
		}
		CFMLEngine engine = CFMLEngineFactory.getInstance();
		try {
			PageContext pc = engine.getThreadPageContext();
			cfc.call(pc, name, args);
		} catch (PageException pe) {
			throw engine.getCastUtil().toPageRuntimeException(pe);
		}
	}

	private Component getEventListener(Object entity) {
		if (eventListeners.size() == 0)
			return null;
		Component caller = CommonUtil.toComponent(entity, null);
		if (caller != null) {
			Component eventListener = eventListeners.get(caller.getAbsName());
			if (eventListener != null)
				return eventListener;
		}
		return null;
	}

	/**
	 * Merge the provided arrays of properties and values into a CFML-friendly struct.
	 *
	 * @param properties
	 *            Array of property names, usually retrieved from <code>event.getPersister().getPropertyNames()</code>
	 * @param values
	 *            Array of property values, either retrieved from <code>event.getPersister().getPropertyValues()</code>,
	 *            <code>event.getState()</code> or <code>event.getOldState()</code>
	 *
	 * @return A struct
	 */
	private static Struct entityStateToStruct(String[] properties, Object[] values) {
		Struct entityState = CommonUtil.createStruct();

		if (values != null && properties != null && values.length == properties.length) {
			for (int i = 0; i < values.length; i++) {
				entityState.setEL(CommonUtil.createKey(properties[i]), values[i]);
		}

	}
		return entityState;
	}
}
