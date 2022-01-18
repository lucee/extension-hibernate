package org.lucee.extension.orm.hibernate.event;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.hibernate.HibernateException;
import org.hibernate.boot.Metadata;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.hibernate.event.service.spi.EventListenerRegistry;
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
import org.hibernate.event.spi.PostInsertEvent;
import org.hibernate.event.spi.PostInsertEventListener;
import org.hibernate.event.spi.PostLoadEvent;
import org.hibernate.event.spi.PostLoadEventListener;
import org.hibernate.event.spi.PostUpdateEvent;
import org.hibernate.event.spi.PostUpdateEventListener;
import org.hibernate.event.spi.PreDeleteEvent;
import org.hibernate.event.spi.PreDeleteEventListener;
import org.hibernate.event.spi.PreInsertEvent;
import org.hibernate.event.spi.PreInsertEventListener;
import org.hibernate.event.spi.PreLoadEvent;
import org.hibernate.event.spi.PreLoadEventListener;
import org.hibernate.event.spi.PreUpdateEvent;
import org.hibernate.event.spi.PreUpdateEventListener;
import org.hibernate.integrator.spi.Integrator;
import org.hibernate.persister.entity.EntityPersister;
import org.hibernate.service.spi.SessionFactoryServiceRegistry;
import org.lucee.extension.orm.hibernate.CommonUtil;

import lucee.runtime.Component;

public class EventListenerIntegrator implements Integrator, PreInsertEventListener, PostInsertEventListener, PreDeleteEventListener, PostDeleteEventListener,
		PreUpdateEventListener, PostUpdateEventListener, PreLoadEventListener, PostLoadEventListener, FlushEventListener, AutoFlushEventListener, ClearEventListener,
		DeleteEventListener, DirtyCheckEventListener, EvictEventListener {

	private static final long serialVersionUID = -5954121166467541422L;

	private EVComponent allEventListener;
	private Map<String, EVComponent> eventListeners = new ConcurrentHashMap<>();

	@Override
	public void integrate(Metadata metadata, SessionFactoryImplementor sessionFactory, SessionFactoryServiceRegistry serviceRegistry) {
		EventListenerRegistry eventListenerRegistry = serviceRegistry.getService(EventListenerRegistry.class);

		eventListenerRegistry.getEventListenerGroup(EventType.PRE_INSERT).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.POST_INSERT).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.PRE_DELETE).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.POST_DELETE).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.PRE_UPDATE).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.POST_UPDATE).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.PRE_LOAD).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.POST_LOAD).appendListener(this);

		// NEW events added in 5.4
		eventListenerRegistry.getEventListenerGroup(EventType.AUTO_FLUSH ).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.CLEAR ).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.DIRTY_CHECK ).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.FLUSH ).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.EVICT ).appendListener(this);
		eventListenerRegistry.getEventListenerGroup(EventType.DELETE ).appendListener(this);

	}

	@Override
	public void disintegrate(SessionFactoryImplementor sessionFactory, SessionFactoryServiceRegistry serviceRegistry) {

	}

	public void setAllEventListener(Component allEventListener) {
		this.allEventListener = EVComponent.newInstance(allEventListener);
	}

	public void setEventListene(Component cfc) {
		EVComponent evc = EVComponent.newInstance(cfc);
		if (evc != null) this.eventListeners.put(cfc.getAbsName(), evc);// TODO correct string?
	}

	@Override
	public boolean requiresPostCommitHanding(EntityPersister arg0) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean onPreInsert(PreInsertEvent event) {
		if (allEventListener != null) allEventListener.onPreInsert(null, event);
		EVC2Caller evcc = getEventListener(event.getEntity());
		if (evcc != null) evcc.evc.onPreInsert(evcc.caller, event);
		return false;
	}

	@Override
	public void onPostInsert(PostInsertEvent event) {
		if (allEventListener != null) allEventListener.onPostInsert(null, event);
		EVC2Caller evcc = getEventListener(event.getEntity());
		if (evcc != null) evcc.evc.onPostInsert(evcc.caller, event);
	}

	// PreDeleteEventListener
	@Override
	public boolean onPreDelete(PreDeleteEvent event) {
		if (allEventListener != null) allEventListener.onPreDelete(null, event);
		EVC2Caller evcc = getEventListener(event.getEntity());
		if (evcc != null) evcc.evc.onPreDelete(evcc.caller, event);
		return false;
	}

	// PostDeleteEventListener
	@Override
	public void onPostDelete(PostDeleteEvent event) {
		if (allEventListener != null) allEventListener.onPostDelete(null, event);
		EVC2Caller evcc = getEventListener(event.getEntity());
		if (evcc != null) evcc.evc.onPostDelete(evcc.caller, event);
	}

	// PreUpdateEventListener
	@Override
	public boolean onPreUpdate(PreUpdateEvent event) {
		if (allEventListener != null) allEventListener.onPreUpdate(null, event);
		EVC2Caller evcc = getEventListener(event.getEntity());
		if (evcc != null) evcc.evc.onPreUpdate(evcc.caller, event);
		return false;
	}

	// PostUpdateEventListener
	@Override
	public void onPostUpdate(PostUpdateEvent event) {
		if (allEventListener != null) allEventListener.onPostUpdate(null, event);
		EVC2Caller evcc = getEventListener(event.getEntity());
		if (evcc != null) evcc.evc.onPostUpdate(evcc.caller, event);
	}

	// PreLoadEventListener
	@Override
	public void onPreLoad(PreLoadEvent event) {
		if (allEventListener != null) allEventListener.onPreLoad(null, event);
		EVC2Caller evcc = getEventListener(event.getEntity());
		if (evcc != null) evcc.evc.onPreLoad(evcc.caller, event);
	}

	// PostLoadEventListener
	@Override
	public void onPostLoad(PostLoadEvent event) {
		if (allEventListener != null) allEventListener.onPostLoad(null, event);
		EVC2Caller evcc = getEventListener(event.getEntity());
		if (evcc != null) evcc.evc.onPostLoad(evcc.caller, event);
	}

	@Override
	public void onFlush(FlushEvent event) throws HibernateException {
		if (allEventListener != null) allEventListener.onFlush(event);
	}

	@Override
	public void onAutoFlush(AutoFlushEvent event) throws HibernateException {
		if (allEventListener != null) allEventListener.onAutoFlush(event);
	}

	@Override
	public void onClear(ClearEvent event) {
		if (allEventListener != null) allEventListener.onClear(event);
	}

	@Override
	public void onDelete(DeleteEvent event) throws HibernateException {
		if (allEventListener != null) allEventListener.onDelete(event);
	}

	@Override
	public void onDelete(DeleteEvent event, Set set) throws HibernateException {
		if (allEventListener != null) allEventListener.onDelete(event);
	}

	@Override
	public void onDirtyCheck(DirtyCheckEvent event) throws HibernateException {
		if (allEventListener != null) allEventListener.onDirtyCheck(event);
	}

	@Override
	public void onEvict(EvictEvent event) throws HibernateException {
		if (allEventListener != null) allEventListener.onEvict(event);
	}

	private EVC2Caller getEventListener(Object entity) {
		if (eventListeners.size() == 0) return null;
		Component caller = CommonUtil.toComponent(entity, null);
		if (caller != null) {
			EVComponent evc = eventListeners.get(caller.getAbsName());
			if (evc != null) return new EVC2Caller(evc, caller);
		}
		return null;
	}

	private static class EVC2Caller {
		private EVComponent evc;
		private Component caller;

		public EVC2Caller(EVComponent evc, Component caller) {
			this.evc = evc;
			this.caller = caller;
		}

	}
}
