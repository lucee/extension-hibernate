package org.lucee.extension.orm.hibernate.event;

import org.hibernate.event.PostLoadEvent;
import org.hibernate.event.PostLoadEventListener;
import org.lucee.extension.orm.hibernate.CommonUtil;

import lucee.runtime.Component;

public class PostLoadEventListenerImpl extends EventListener implements PostLoadEventListener {

    private static final long serialVersionUID = -3211504876360671598L;

    public PostLoadEventListenerImpl(Component component) {
	super(component, CommonUtil.POST_LOAD, false);
    }

    @Override
    public void onPostLoad(PostLoadEvent event) {
	invoke(CommonUtil.POST_LOAD, event.getEntity());
    }

}
