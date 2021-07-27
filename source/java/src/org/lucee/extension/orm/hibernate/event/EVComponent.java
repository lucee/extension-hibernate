package org.lucee.extension.orm.hibernate.event;

import org.hibernate.event.spi.AbstractEvent;
import org.hibernate.event.spi.AutoFlushEvent;
import org.hibernate.event.spi.ClearEvent;
import org.hibernate.event.spi.DeleteEvent;
import org.hibernate.event.spi.DirtyCheckEvent;
import org.hibernate.event.spi.EvictEvent;
import org.hibernate.event.spi.FlushEvent;
import org.hibernate.event.spi.PostDeleteEvent;
import org.hibernate.event.spi.PostInsertEvent;
import org.hibernate.event.spi.PostLoadEvent;
import org.hibernate.event.spi.PostUpdateEvent;
import org.hibernate.event.spi.PreDeleteEvent;
import org.hibernate.event.spi.PreInsertEvent;
import org.hibernate.event.spi.PreLoadEvent;
import org.hibernate.event.spi.PreUpdateEvent;
import org.lucee.extension.orm.hibernate.CommonUtil;
import org.lucee.extension.orm.hibernate.HibernateUtil;

import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.component.Property;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Collection;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.type.Struct;
import lucee.runtime.type.UDF;

public class EVComponent {

	final private Component comp;
	final private boolean hasPreInsert;
	final private boolean hasPostInsert;
	final private boolean hasPreDelete;
	final private boolean hasPostDelete;
	final private boolean hasPreUpdate;
	final private boolean hasPostUpdate;
	final private boolean hasPreLoad;
	final private boolean hasPostLoad;
	final private boolean hasFlush;
	final private boolean hasAutoFlush;
	final private boolean hasClear;
	final private boolean hasDelete;
	final private boolean hasDirtyCheck;
	final private boolean hasEvict;

	public static EVComponent newInstance(Component comp) {
		boolean hasPreInsert = hasEventType(comp, CommonUtil.PRE_INSERT);
		boolean hasPostInsert = hasEventType(comp, CommonUtil.POST_INSERT);
		boolean hasPreDelete = hasEventType(comp, CommonUtil.PRE_DELETE);
		boolean hasPostDelete = hasEventType(comp, CommonUtil.POST_DELETE);
		boolean hasPreUpdate = hasEventType(comp, CommonUtil.PRE_UPDATE);
		boolean hasPostUpdate = hasEventType(comp, CommonUtil.POST_UPDATE);
		boolean hasPreLoad = hasEventType(comp, CommonUtil.PRE_LOAD);
		boolean hasPostLoad = hasEventType(comp, CommonUtil.POST_LOAD);
		boolean hasFlush = hasEventType(comp, CommonUtil.ON_FLUSH);
		boolean hasAutoFlush = hasEventType(comp, CommonUtil.ON_AUTO_FLUSH);
		boolean hasClear = hasEventType(comp, CommonUtil.ON_CLEAR);
		boolean hasDelete = hasEventType(comp, CommonUtil.ON_DELETE);
		boolean hasDirtyCheck = hasEventType(comp, CommonUtil.ON_DIRTY_CHECK);
		boolean hasEvict = hasEventType(comp, CommonUtil.ON_EVICT);

		if (!hasPreInsert && !hasPostInsert && !hasPreDelete && !hasPostDelete && !hasPreUpdate && !hasPostUpdate && !hasPreLoad && !hasPostLoad && !hasFlush && !hasAutoFlush
				&& !hasClear && !hasDelete && !hasDirtyCheck && !hasEvict)
			return null;

		return new EVComponent(comp, hasPreInsert, hasPostInsert, hasPreDelete, hasPostDelete, hasPreUpdate, hasPostUpdate, hasPreLoad, hasPostLoad, hasFlush, hasAutoFlush,
				hasClear, hasDelete, hasDirtyCheck, hasEvict);
	}

	private EVComponent(Component comp, boolean hasPreInsert, boolean hasPostInsert, boolean hasPreDelete, boolean hasPostDelete, boolean hasPreUpdate, boolean hasPostUpdate,
			boolean hasPreLoad, boolean hasPostLoad, boolean hasFlush, boolean hasAutoFlush, boolean hasClear, boolean hasDelete, boolean hasDirtyCheck, boolean hasEvict) {
		this.comp = comp;
		this.hasPreInsert = hasPreInsert;
		this.hasPostInsert = hasPostInsert;
		this.hasPreDelete = hasPreDelete;
		this.hasPostDelete = hasPostDelete;
		this.hasPreUpdate = hasPreUpdate;
		this.hasPostUpdate = hasPostUpdate;
		this.hasPreLoad = hasPreLoad;
		this.hasPostLoad = hasPostLoad;
		this.hasFlush = hasFlush;
		this.hasAutoFlush = hasAutoFlush;
		this.hasClear = hasClear;
		this.hasDelete = hasDelete;
		this.hasDirtyCheck = hasDirtyCheck;
		this.hasEvict = hasEvict;
	}

	public void onPreInsert(Component caller, PreInsertEvent event) {
		if (hasPreInsert) invoke(caller, CommonUtil.PRE_INSERT, event.getEntity(), event, null);
	}

	public void onPostInsert(Component caller, PostInsertEvent event) {
		if (hasPostInsert) invoke(caller, CommonUtil.POST_INSERT, event.getEntity(), event, null);
	}

	public void onPreDelete(Component caller, PreDeleteEvent event) {
		if (hasPreDelete) invoke(caller, CommonUtil.PRE_DELETE, event.getEntity(), event, null);
	}

	public void onPostDelete(Component caller, PostDeleteEvent event) {
		if (hasPostDelete) invoke(caller, CommonUtil.POST_DELETE, event.getEntity(), event, null);
	}

	public void onPreUpdate(Component caller, PreUpdateEvent event) {
		if (!hasPreUpdate) return;

		Struct oldData = CommonUtil.createStruct();
		Property[] properties = HibernateUtil.getProperties(comp, HibernateUtil.FIELDTYPE_COLUMN, null);
		Object[] data = event.getOldState();

		if (data != null && properties != null && data.length == properties.length) {
			for (int i = 0; i < data.length; i++) {
				oldData.setEL(CommonUtil.createKey(properties[i].getName()), data[i]);
			}
		}
		invoke(caller, CommonUtil.PRE_UPDATE, event.getEntity(), event, oldData);

	}

	public void onPostUpdate(Component caller, PostUpdateEvent event) {
		if (hasPostUpdate) invoke(caller, CommonUtil.POST_UPDATE, event.getEntity(), event, null);
	}

	public void onPreLoad(Component caller, PreLoadEvent event) {
		if (hasPreLoad) invoke(caller, CommonUtil.PRE_LOAD, event.getEntity(), event, null);

	}

	public void onPostLoad(Component caller, PostLoadEvent event) {
		if (hasPostLoad) invoke(caller, CommonUtil.POST_LOAD, event.getEntity(), event, null);
	}

	public void onFlush(FlushEvent event) {
		if (hasFlush) invoke(null, CommonUtil.ON_FLUSH, null, event, null);
	}

	public void onAutoFlush(AutoFlushEvent event) {
		if (hasAutoFlush) invoke(null, CommonUtil.ON_AUTO_FLUSH, null, event, null);
	}

	public void onClear(ClearEvent event) {
		if (hasClear) invoke(null, CommonUtil.ON_CLEAR, null, event, null);
	}

	public void onDelete(DeleteEvent event) {
		if (hasDelete) invoke(null, CommonUtil.ON_DELETE, null, event, null);
	}

	public void onDirtyCheck(DirtyCheckEvent event) {
		if (hasDirtyCheck) invoke(null, CommonUtil.ON_DIRTY_CHECK, null, event, null);
	}

	public void onEvict(EvictEvent event) {
		if (hasEvict) invoke(null, CommonUtil.ON_EVICT, null, event, null);
	}

	private void invoke(Component caller, Key name, Object obj, AbstractEvent event, Struct data) {
		_invoke(caller == null ? comp : caller, name, data, caller == null ? obj : null, event);
	}

	private static void _invoke(Component cfc, Key name, Struct data, Object arg, AbstractEvent event) {
		if (cfc == null) return;
		CFMLEngine engine = CFMLEngineFactory.getInstance();
		try {
			PageContext pc = engine.getThreadPageContext();
			Object[] args;
			if (data == null) {
				args = arg != null ? new Object[] { arg, event } : new Object[] { event };
			}
			else {
				args = arg != null ? new Object[] { arg, data, event } : new Object[] { data, event };
			}
			cfc.call(pc, name, args);
		}
		catch (PageException pe) {
			throw engine.getCastUtil().toPageRuntimeException(pe);
		}
	}

	private static boolean hasEventType(Component comp, Collection.Key eventType) {
		return comp.get(eventType, null) instanceof UDF;
	}
}
