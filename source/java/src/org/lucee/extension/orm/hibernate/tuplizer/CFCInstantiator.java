package org.lucee.extension.orm.hibernate.tuplizer;

import java.util.HashSet;
import java.util.Set;

import org.hibernate.HibernateException;
import org.hibernate.mapping.PersistentClass;
import org.hibernate.metamodel.spi.EntityInstantiator;
import org.lucee.extension.orm.hibernate.SessionFactoryData;
import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.HibernateCaster;
import org.lucee.extension.orm.hibernate.HibernatePageException;

import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;

public class CFCInstantiator implements EntityInstantiator {

	private static final Object[] EMPTY_ARGS = new Object[] {};

	private final String entityName;
	private final Set<String> isInstanceEntityNames = new HashSet<>();
	private final Component template;
	private final boolean hasInit;

	public CFCInstantiator(PersistentClass mappingInfo, SessionFactoryData data) {
		this.entityName = mappingInfo.getEntityName();
		isInstanceEntityNames.add(entityName);
		if (mappingInfo.hasSubclasses()) {
			for (PersistentClass subclass : mappingInfo.getSubclassClosure()) {
				isInstanceEntityNames.add(subclass.getEntityName());
			}
		}

		Component cfc = data.getEntityTemplate(entityName);
		if (cfc == null) {
			throw new HibernateException("Entity [" + entityName
					+ "] not registered in SessionFactoryData — CFCInstantiator cannot resolve its template.");
		}
		this.template = cfc;
		this.hasInit = template.contains(CommonUtil.pc(), CommonUtil.INIT);
	}

	@Override
	public Object instantiate() {
		try {
			Component cfc = (Component) template.duplicate(false);
			// Skip init() during SessionFactory build. H7.3 calls instantiate() from
			// UnsavedValueFactory.inferUnsavedIdentifierValue while building the metamodel;
			// if the entity's init() body touches a persistent property setter,
			// Lucee's UDFSetterProperty._call resolves ORMUtil.getSession() which
			// re-enters HibernateORMEngine.init() while we're still inside that call —
			// recursion deepens until JAXB's StackHelper.getCallerClassName overflows.
			// At runtime (post-build) the SF is cached and getSession() short-circuits,
			// so init() runs without recursing — only the build-time call needs gating.
			if (hasInit && SessionFactoryData.CURRENT_BUILDING.get() == null) {
				PageContext pc = CommonUtil.pc();
				cfc.call(pc, "init", EMPTY_ARGS);
			}
			cfc.setEntity(true);
			return cfc;
		} catch (PageException pe) {
			throw new HibernatePageException(pe);
		}
	}

	@Override
	public boolean isInstance(Object object) {
		Component cfc = CommonUtil.toComponent(object, null);
		if (cfc == null) return false;
		return isInstanceEntityNames.contains(HibernateCaster.getEntityName(cfc));
	}

	@Override
	public boolean isSameClass(Object object) {
		Component cfc = CommonUtil.toComponent(object, null);
		if (cfc == null) return false;
		return entityName.equals(HibernateCaster.getEntityName(cfc));
	}
}
