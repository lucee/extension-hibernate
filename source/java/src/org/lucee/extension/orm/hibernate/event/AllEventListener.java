package org.lucee.extension.orm.hibernate.event;

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
import org.hibernate.persister.entity.EntityPersister;
import org.lucee.extension.orm.hibernate.CommonUtil;

import lucee.runtime.Component;

public class AllEventListener extends EventListener implements PreDeleteEventListener, PreInsertEventListener, PreLoadEventListener, PreUpdateEventListener,
PostDeleteEventListener, PostInsertEventListener, PostLoadEventListener, PostUpdateEventListener {
	
	private static final long serialVersionUID = 8969282190912098982L;



	public AllEventListener(Component component) {
	    super(component, null, true);
	}
	

	@Override
	public void onPostInsert(PostInsertEvent event) {
		invoke(CommonUtil.POST_INSERT, event.getEntity());
    }

    @Override
	public void onPostUpdate(PostUpdateEvent event) {
    	invoke(CommonUtil.POST_UPDATE, event.getEntity());
    }

    @Override
	public boolean onPreDelete(PreDeleteEvent event) {
    	invoke(CommonUtil.PRE_DELETE, event.getEntity());
		return false;
    }

    @Override
	public void onPostDelete(PostDeleteEvent event) {
    	invoke(CommonUtil.POST_DELETE, event.getEntity());
    }

    @Override
	public void onPreLoad(PreLoadEvent event) {
    	invoke(CommonUtil.PRE_LOAD, event.getEntity());
    }

    @Override
	public void onPostLoad(PostLoadEvent event) {
    	invoke(CommonUtil.POST_LOAD, event.getEntity());
    }

	@Override
	public boolean onPreUpdate(PreUpdateEvent event) {
		return preUpdate(event);
	}



	@Override
	public boolean onPreInsert(PreInsertEvent event) {
		invoke(CommonUtil.PRE_INSERT, event.getEntity());
		return false;
	}


	@Override
	public boolean requiresPostCommitHanding(EntityPersister arg0) {
		// TODO
		return false;
	}
}
