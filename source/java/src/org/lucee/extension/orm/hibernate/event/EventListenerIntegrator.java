package org.lucee.extension.orm.hibernate.event;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.hibernate.HibernateException;
import org.hibernate.boot.Metadata;
import org.hibernate.boot.spi.BootstrapContext;
import org.hibernate.engine.internal.Nullability;
import org.hibernate.engine.internal.Nullability.NullabilityCheckType;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.hibernate.event.service.spi.EventListenerRegistry;
import org.hibernate.event.spi.AutoFlushEvent;
import org.hibernate.event.spi.AutoFlushEventListener;
import org.hibernate.event.spi.ClearEvent;
import org.hibernate.event.spi.ClearEventListener;
import org.hibernate.event.spi.DeleteContext;
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
import org.lucee.extension.orm.hibernate.HibernateCaster;
import org.lucee.extension.orm.hibernate.mapping.CFConstants;
import org.lucee.extension.orm.hibernate.util.CommonUtil;

import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.component.Property;
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

	public static final Key PRE_INSERT    = CommonUtil.createKey( "preInsert" );
	public static final Key POST_INSERT   = CommonUtil.createKey( "postInsert" );
	public static final Key PRE_UPDATE    = CommonUtil.createKey( "preUpdate" );
	public static final Key POST_UPDATE   = CommonUtil.createKey( "postUpdate" );
	public static final Key PRE_DELETE    = CommonUtil.createKey( "preDelete" );
	public static final Key POST_DELETE   = CommonUtil.createKey( "postDelete" );
	public static final Key PRE_LOAD      = CommonUtil.createKey( "preLoad" );
	public static final Key POST_LOAD     = CommonUtil.createKey( "postLoad" );
	public static final Key ON_FLUSH      = CommonUtil.createKey( "onFlush" );
	public static final Key ON_AUTO_FLUSH = CommonUtil.createKey( "onAutoFlush" );
	public static final Key ON_CLEAR      = CommonUtil.createKey( "onClear" );
	public static final Key ON_DELETE     = CommonUtil.createKey( "onDelete" );
	public static final Key ON_DIRTY_CHECK = CommonUtil.createKey( "onDirtyCheck" );
	public static final Key ON_EVICT      = CommonUtil.createKey( "onEvict" );

	/**
	 * All entity/global event method keys we check for on components.
	 */
	private static final Key[] EVENT_METHODS = new Key[] {
		PRE_INSERT, POST_INSERT, PRE_UPDATE, POST_UPDATE,
		PRE_DELETE, POST_DELETE, PRE_LOAD, POST_LOAD,
		ON_FLUSH, ON_AUTO_FLUSH, ON_CLEAR, ON_DELETE,
		ON_DIRTY_CHECK, ON_EVICT
	};

	/**
	 * Cache of which event methods exist on each entity/component class, keyed by entity name.
	 * Populated on first event per entity; the CFC method set is fixed for the SessionFactory lifetime.
	 */
	private final ConcurrentHashMap<String, Set<Key>> entityMethodCache = new ConcurrentHashMap<>();

	/**
	 * The EventHandler CFC defined in the application's `this.ormSettings.eventHandler`.
	 */
	private Component GlobalEventListener;

	@Override
	public void integrate(Metadata metadata, BootstrapContext bootstrapContext, SessionFactoryImplementor sessionFactory) {
		EventListenerRegistry eventListenerRegistry = sessionFactory.getServiceRegistry().getService(EventListenerRegistry.class);

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


	@Override
	public boolean onPreInsert(PreInsertEvent event) {
		String[] propertyNames = event.getPersister().getEntityMetamodel().getPropertyNames();
		Struct state = entityStateToStruct(propertyNames, event.getState());
		Component entityCFC = CommonUtil.toComponent(event.getEntity(), null);

		// fire on entity first, then global (LDEV-4561)
		if (entityCFC != null) {
			_fireOnComponent(entityCFC, PRE_INSERT, state, event);
		}
		fireEventOnGlobalListener(PRE_INSERT, event.getEntity(), event, state);

		// Sync CFC property changes back to Hibernate state
		Object[] stateValues = event.getState();
		persistEntityChangesToState(stateValues, propertyNames, entityCFC);

		// Validate nullability after state sync
		new Nullability(event.getSession(), NullabilityCheckType.CREATE)
		    .checkNullability(stateValues, event.getPersister());

		return false;
	}

	@Override
	public void onPostInsert(PostInsertEvent event) {
		fireOnEntity(event.getEntity(), POST_INSERT, event, null);
		fireEventOnGlobalListener(POST_INSERT, event.getEntity(), event, null);
	}

	@Override
	public boolean onPreDelete(PreDeleteEvent event) {
		fireOnEntity(event.getEntity(), PRE_DELETE, event, null);
		fireEventOnGlobalListener(PRE_DELETE, event.getEntity(), event, null);
		return false;
	}

	@Override
	public void onPostDelete(PostDeleteEvent event) {
		fireOnEntity(event.getEntity(), POST_DELETE, event, null);
		fireEventOnGlobalListener(POST_DELETE, event.getEntity(), event, null);
	}

	@Override
	public boolean onPreUpdate(PreUpdateEvent event) {
		String[] propertyNames = event.getPersister().getEntityMetamodel().getPropertyNames();
		Struct oldState = entityStateToStruct(propertyNames, event.getOldState());
		Component entityCFC = CommonUtil.toComponent(event.getEntity(), null);

		// fire on entity first, then global (LDEV-4561)
		if (entityCFC != null) {
			_fireOnComponent(entityCFC, PRE_UPDATE, oldState, event);
		}
		fireEventOnGlobalListener(PRE_UPDATE, event.getEntity(), event, oldState);

		// Sync CFC property changes back to Hibernate state
		Object[] stateValues = event.getState();
		persistEntityChangesToState(stateValues, propertyNames, entityCFC);

		// Validate nullability after state sync
		new Nullability(event.getSession(), NullabilityCheckType.CREATE)
		    .checkNullability(stateValues, event.getPersister());

		return false;
	}

	@Override
	public void onPostUpdate(PostUpdateEvent event) {
		fireOnEntity(event.getEntity(), POST_UPDATE, event, null);
		fireEventOnGlobalListener(POST_UPDATE, event.getEntity(), event, null);
	}

	@Override
	public void onPreLoad(PreLoadEvent event) {
		fireOnEntity(event.getEntity(), PRE_LOAD, event, null);
		fireEventOnGlobalListener(PRE_LOAD, event.getEntity(), event, null);
	}

	@Override
	public void onPostLoad(PostLoadEvent event) {
		fireOnEntity(event.getEntity(), POST_LOAD, event, null);
		fireEventOnGlobalListener(POST_LOAD, event.getEntity(), event, null);
	}

	@Override
	public void onFlush(FlushEvent event) throws HibernateException {
		// Sadly, the FlushEvent does not allow / provide a method to retrieve the entity.
		Object entity = null;
		fireEventOnGlobalListener(ON_FLUSH, entity, event, null);
	}

	@Override
	public void onAutoFlush(AutoFlushEvent event) throws HibernateException {
		// Sadly, the AutoFlushEvent does not allow / provide a method to retrieve the entity.
		Object entity = null;
		fireEventOnGlobalListener(ON_AUTO_FLUSH, entity, event, null);
	}

	@Override
	public void onClear(ClearEvent event) {
		// Sadly, the ClearEvent does not allow / provide a method to retrieve the entity.
		Object entity = null;
		fireEventOnGlobalListener(ON_CLEAR, entity, event, null);
	}

	@Override
	public void onDelete(DeleteEvent event) throws HibernateException {
		Object entity = event.getObject();
		fireEventOnGlobalListener(ON_DELETE, entity, event, null);
	}

	@Override
	public void onDelete(DeleteEvent event, DeleteContext transientEntities) throws HibernateException {
		Object entity = event.getObject();
		// TODO: handle transientEntities
		fireEventOnGlobalListener(ON_DELETE, entity, event, null);
	}

	@Override
	public void onDirtyCheck(DirtyCheckEvent event) throws HibernateException {
		// Sadly, the DirtyCheckEvent does not allow / provide a method to retrieve the entity.
		Object entity = null;
		fireEventOnGlobalListener(ON_DIRTY_CHECK, entity, event, null);
	}

	@Override
	public void onEvict(EvictEvent event) throws HibernateException {
		Object entity = event.getObject();
		fireOnEntity(entity, ON_EVICT, event, null);
		fireEventOnGlobalListener(ON_EVICT, entity, event, null);
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
	public void fireEventOnGlobalListener(Key name, Object entity, Object event, Struct data) {
		if (GlobalEventListener == null) {
			return;
		}

		_fireOnComponent(getGlobalEventListener(), name, entity, data, event);
	}

	/**
	 * Fire the event listener UDF, if found, on the entity component.
	 */
	public void fireOnEntity(Object entity, Key name, Object event, Struct data) {
		Component listener = (entity instanceof Component) ? (Component) entity : CommonUtil.toComponent(entity, null);
		if (listener != null) {
			_fireOnComponent(listener, name, data, event);
		}
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
	/**
	 * Check if the given component has a method matching the given name, using a per-entity cache
	 * to avoid repeated ComponentImpl.get() → StaticScope._get() lookups on every event.
	 */
	private boolean componentHasMethod(Component comp, Collection.Key methodName) {
		String entityName = HibernateCaster.getEntityName(comp);
		Set<Key> methods = entityMethodCache.computeIfAbsent(entityName, k -> {
			Set<Key> found = new HashSet<>();
			for (Key candidate : EVENT_METHODS) {
				if (comp.get(candidate, null) instanceof UDF) found.add(candidate);
			}
			return found;
		});
		return methods.contains(methodName);
	}

	private void _fireOnComponent(Component cfc, Key name, Object... args) {
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
	/**
	 * Loop over the provided state properties and persist any entity changes to the state object.
	 * Used in onPreInsert and onPreUpdate to sync CFC property mutations back to Hibernate.
	 */
	private void persistEntityChangesToState(Object[] state, String[] stateProperties, Component entity) {
		try {
			Property[] cfcProperties = entity.getProperties(true, true, false, false);
			for (int n = 0; n < stateProperties.length; ++n) {
				final String currentProperty = stateProperties[n];
				Optional<Property> property = Arrays.stream(cfcProperties)
				    .filter(prop -> prop.getName().equalsIgnoreCase(currentProperty))
				    .filter(prop -> !isRelationshipField(prop))
				    .findFirst();
				if (property.isPresent()) {
					state[n] = HibernateCaster.toHibernateValue(entity, property.get());
				}
			}
		} catch (Exception e) {
			throw new RuntimeException(
			    String.format("Error populating event state for persistence in [%s] entity pre-event listener: %s", entity.getName(), e.getMessage()),
			    e);
		}
	}

	private boolean isRelationshipField(Property prop) {
		Object raw = prop.getMetaData();
		if (!(raw instanceof Struct)) return false;
		Struct meta = (Struct) raw;
		String fieldType = CommonUtil.toString(meta.get(CommonUtil.FIELDTYPE, null), null);
		return fieldType != null && CFConstants.Relationships.isRelationshipType(fieldType);
	}

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
