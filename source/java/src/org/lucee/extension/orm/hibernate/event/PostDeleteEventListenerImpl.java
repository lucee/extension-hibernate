package org.lucee.extension.orm.hibernate.event;

import org.hibernate.event.spi.PostDeleteEvent;
import org.hibernate.event.spi.PostDeleteEventListener;
import org.hibernate.persister.entity.EntityPersister;
import org.lucee.extension.orm.hibernate.CommonUtil;

import lucee.runtime.Component;

public class PostDeleteEventListenerImpl extends EventListener implements PostDeleteEventListener {

	private static final long serialVersionUID = -4882488527866603549L;

	public PostDeleteEventListenerImpl(Component component) {
		super(component, CommonUtil.POST_DELETE, false);
	}

	@Override
	public void onPostDelete(PostDeleteEvent event) {
		invoke(CommonUtil.POST_DELETE, event.getEntity());
	}

	@Override
	public boolean requiresPostCommitHanding(EntityPersister arg0) {
		// TODO Auto-generated method stub
		return false;
	}

}
