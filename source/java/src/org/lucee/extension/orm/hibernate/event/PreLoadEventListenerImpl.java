package org.lucee.extension.orm.hibernate.event;

import lucee.runtime.Component;

import org.hibernate.event.PreLoadEvent;
import org.hibernate.event.PreLoadEventListener;
import org.lucee.extension.orm.hibernate.CommonUtil;

public class PreLoadEventListenerImpl extends EventListener implements PreLoadEventListener {

	private static final long serialVersionUID = 6470830422058063880L;

	public PreLoadEventListenerImpl(Component component) {
	    super(component, CommonUtil.PRE_LOAD, false);
	}

    @Override
	public void onPreLoad(PreLoadEvent event) {
    	invoke(CommonUtil.PRE_LOAD, event.getEntity());
    }

}
