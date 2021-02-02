package org.lucee.extension.orm.hibernate.event;

import org.hibernate.event.spi.PreUpdateEvent;
import org.hibernate.event.spi.PreUpdateEventListener;
import org.lucee.extension.orm.hibernate.CommonUtil;

import lucee.runtime.Component;

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
