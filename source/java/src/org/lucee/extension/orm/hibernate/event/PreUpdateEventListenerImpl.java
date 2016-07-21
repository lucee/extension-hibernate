package org.lucee.extension.orm.hibernate.event;

import lucee.runtime.Component;

import org.hibernate.event.PreUpdateEvent;
import org.hibernate.event.PreUpdateEventListener;
import org.lucee.extension.orm.hibernate.CommonUtil;

public class PreUpdateEventListenerImpl extends EventListener implements PreUpdateEventListener {
	
	private static final long serialVersionUID = -2340188926747682946L;

	public PreUpdateEventListenerImpl(Component component) {
	    super(component, CommonUtil.PRE_UPDATE, false);
	}
	
	@Override
	public boolean onPreUpdate(PreUpdateEvent event) {
		return preUpdate(event);
	}

}
