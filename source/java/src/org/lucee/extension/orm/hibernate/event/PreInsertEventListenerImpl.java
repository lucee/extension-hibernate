package org.lucee.extension.orm.hibernate.event;

import lucee.runtime.Component;

import org.hibernate.event.PreInsertEvent;
import org.hibernate.event.PreInsertEventListener;
import org.lucee.extension.orm.hibernate.CommonUtil;

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
