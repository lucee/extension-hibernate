package org.opencfmlfoundation.extension.orm.hibernate.event;

import org.hibernate.event.PreUpdateEvent;
import org.hibernate.event.PreUpdateEventListener;
import org.opencfmlfoundation.extension.orm.hibernate.CommonUtil;

import railo.runtime.Component;

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
