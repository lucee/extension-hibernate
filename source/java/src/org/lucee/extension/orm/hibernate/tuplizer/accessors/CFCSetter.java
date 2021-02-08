package org.lucee.extension.orm.hibernate.tuplizer.accessors;

import java.lang.reflect.Method;

import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.hibernate.property.access.spi.Setter;
import org.hibernate.type.Type;
import org.lucee.extension.orm.hibernate.CommonUtil;
import org.lucee.extension.orm.hibernate.HibernatePageException;

import lucee.runtime.Component;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Collection.Key;

public final class CFCSetter implements Setter {

	private Key key;
	private Type type;
	private Object entityName;

	/**
	 * Constructor of the class
	 * 
	 * @param key
	 * @param string
	 * @param type
	 */
	public CFCSetter(String key, Type type, String entityName) {
		this.key = CommonUtil.createKey(key);
		this.type = type;
		this.entityName = entityName;
	}

	@Override
	public String getMethodName() {
		return null;
	}

	@Override
	public Method getMethod() {
		return null;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void set(Object trg, Object value, SessionFactoryImplementor factory) throws HibernateException {
		try {
			Component cfc = CommonUtil.toComponent(trg);
			cfc.getComponentScope().set(key, value);
		} catch (PageException pe) {
			throw new HibernatePageException(pe);
		}
	}
}