package org.opencfmlfoundation.extension.orm.hibernate.tuplizer.proxy;

import java.io.Serializable;

import org.hibernate.engine.SessionImplementor;
import org.hibernate.proxy.AbstractLazyInitializer;
import org.opencfmlfoundation.extension.orm.hibernate.CommonUtil;
import org.opencfmlfoundation.extension.orm.hibernate.HibernatePageException;

import railo.runtime.Component;
import railo.runtime.exp.PageException;

/**
 * Lazy initializer for "dynamic-map" entity representations.
 * SLOW
 */
public class CFCLazyInitializer extends AbstractLazyInitializer implements Serializable {

	
	CFCLazyInitializer(String entityName, Serializable id, SessionImplementor session) {
		super(entityName, id, session);
		
	}

	public Component getCFC() {
		try {
			return CommonUtil.toComponent(getImplementation());
		} catch (PageException pe) {
			throw new HibernatePageException(pe);
		}
	}

	@Override
	public Class getPersistentClass() {
		throw new UnsupportedOperationException("dynamic-map entity representation");
	}
	
	
	
}




