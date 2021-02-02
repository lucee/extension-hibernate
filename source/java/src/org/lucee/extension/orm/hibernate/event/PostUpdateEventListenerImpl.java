package org.lucee.extension.orm.hibernate.event;

import org.hibernate.event.spi.PostUpdateEvent;
import org.hibernate.event.spi.PostUpdateEventListener;
import org.hibernate.persister.entity.EntityPersister;
import org.lucee.extension.orm.hibernate.CommonUtil;

import lucee.runtime.Component;

public class PostUpdateEventListenerImpl extends EventListener implements PostUpdateEventListener {

	private static final long serialVersionUID = -6636253331286381298L;

	public PostUpdateEventListenerImpl(Component component) {
		super(component, CommonUtil.POST_UPDATE, false);
	}

	@Override
	public void onPostUpdate(PostUpdateEvent event) {
		invoke(CommonUtil.POST_UPDATE, event.getEntity());
	}

	@Override
	public boolean requiresPostCommitHanding(EntityPersister arg0) {
		// TODO Auto-generated method stub
		return false;
	}

}
