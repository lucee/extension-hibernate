package org.lucee.extension.orm.hibernate.tuplizer;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.hibernate.mapping.PersistentClass;
import org.hibernate.tuple.Instantiator;
import org.hibernate.tuple.entity.EntityMetamodel;
import org.lucee.extension.orm.hibernate.CommonUtil;
import org.lucee.extension.orm.hibernate.HibernateCaster;
import org.lucee.extension.orm.hibernate.HibernateORMEngine;
import org.lucee.extension.orm.hibernate.HibernateORMSession;
import org.lucee.extension.orm.hibernate.HibernatePageException;
import org.lucee.extension.orm.hibernate.HibernateUtil;

import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;

public class CFCInstantiator implements Instantiator {

	private String entityName;
	private Set<String> isInstanceEntityNames = new HashSet<String>();
	private EntityMetamodel entityMetamodel;

	public CFCInstantiator() {
		this.entityName = null;
	}

	/**
	 * Constructor of the class
	 * 
	 * @param entityMetamodel
	 * 
	 * @param mappingInfo
	 */
	public CFCInstantiator(EntityMetamodel entityMetamodel, PersistentClass mappingInfo) {
		this.entityName = mappingInfo.getEntityName();
		this.entityMetamodel = entityMetamodel;
		isInstanceEntityNames.add(entityName);
		if (mappingInfo.hasSubclasses()) {
			Iterator<PersistentClass> itr = mappingInfo.getSubclassClosureIterator();
			while (itr.hasNext()) {
				final PersistentClass subclassInfo = itr.next();
				isInstanceEntityNames.add(subclassInfo.getEntityName());
			}
		}
	}

	@Override
	public final Object instantiate(Serializable id) {
		return instantiate();
	}

	@Override
	public final Object instantiate() {
		try {
			PageContext pc = CommonUtil.pc();
			HibernateORMSession session = HibernateUtil.getORMSession(pc, true);
			HibernateORMEngine engine = (HibernateORMEngine) session.getEngine();
			Component c = engine.create(pc, session, entityName, true);
			c.setEntity(true);
			return c;// new CFCProxy(c);
		} catch (PageException pe) {
			throw new HibernatePageException(pe);
		}
	}

	@Override
	public final boolean isInstance(Object object) {
		Component cfc = CommonUtil.toComponent(object, null);
		if (cfc == null)
			return false;
		return isInstanceEntityNames.contains(HibernateCaster.getEntityName(cfc));
	}
}