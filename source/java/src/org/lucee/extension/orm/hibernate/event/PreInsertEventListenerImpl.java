package org.lucee.extension.orm.hibernate.event;

import org.hibernate.event.spi.PreInsertEvent;
import org.hibernate.event.spi.PreInsertEventListener;
import org.lucee.extension.orm.hibernate.CommonUtil;

import lucee.runtime.Component;

public class PreInsertEventListenerImpl extends EventListener implements PreInsertEventListener {
	
	private static final long serialVersionUID = -808107633829478391L;

	public PreInsertEventListenerImpl(Component component) {
	    super(component, CommonUtil.PRE_INSERT, false);
	}
	
	@Override
	public boolean onPreInsert(PreInsertEvent event) {
		invoke(CommonUtil.PRE_INSERT, event.getEntity());
		return false;
	}

}
