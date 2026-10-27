package org.lucee.extension.orm.hibernate.tuplizer.accessors;

import java.lang.reflect.Member;
import java.lang.reflect.Method;
import java.sql.Types;
import java.util.Map;

import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.metamodel.model.domain.internal.MapMember;
import org.hibernate.proxy.HibernateProxy;
import org.hibernate.proxy.LazyInitializer;
import org.hibernate.property.access.spi.Getter;
import org.hibernate.type.Type;
import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.HibernateCaster;
import org.lucee.extension.orm.hibernate.HibernateORMEngine;
import org.lucee.extension.orm.hibernate.HibernatePageException;
import org.lucee.extension.orm.hibernate.util.HibernateUtil;

import lucee.runtime.Component;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Collection.Key;

public class CFCGetter implements Getter {

	private Key key;
	private Type type;
	private String entityName;
	private final int sqlType;
	private final String typeName;
	private final Class<?> returnedClass;

	/**
	 * Constructor of the class
	 *
	 * @param key
     *            Persistent property name
	 * @param type
     *            Persistent property type
     * @param entityName
     *            Name of the Hibernate entity to retrieve the value from
	 */
	public CFCGetter(String key, Type type, String entityName) {
		this.key = CommonUtil.createKey(key);
		this.type = type;
		this.entityName = entityName;
		this.sqlType = type != null ? HibernateCaster.toSQLType(type.getName(), Types.OTHER) : Types.OTHER;
		this.typeName = type != null ? type.getName() : null;
		this.returnedClass = type != null ? type.getReturnedClass() : null;
	}

	@Override
	public Object get(Object trg) throws HibernateException {
		try {
			Component cfc = CommonUtil.toComponent(trg);
			Object rtn = cfc.getComponentScope().get(key, null);
			// LDEV-1992: don't trigger lazy init on uninitialized proxies — Hibernate
			// handles them natively during merge/flush
			if (rtn instanceof HibernateProxy) {
				LazyInitializer li = ((HibernateProxy) rtn).getHibernateLazyInitializer();
				if (li.isUninitialized()) return rtn;
			}
			// Hibernate 7's JavaType.cast() is strict — no String→TimeZone/Locale/Calendar
			// coercion. When the CFML value's class doesn't match the Hibernate type's
			// expected Java class, convert via toHibernateValue (knows "timezone"→TimeZone,
			// "locale"→Locale, "calendar"→Calendar, "big_integer"→BigInteger, etc.).
			// CFML uses empty string for "no value" on non-string fields — treat as null
			// (matches HibernateCaster's existing isStringSafeField rule).
			if (returnedClass != null && rtn != null && !returnedClass.isInstance(rtn)) {
				if (rtn instanceof String && ((String) rtn).isEmpty()) {
					rtn = null;
				} else {
					try {
						rtn = HibernateCaster.toHibernateValue(CommonUtil.pc(), rtn, typeName);
					} catch (PageException ignore) {
						// CFML default="" or similar that doesn't round-trip cleanly — pass null
						// rather than fail the persist (matches H5.x lenient behaviour)
						rtn = null;
					}
				}
			}
			return HibernateCaster.toSQL(this.sqlType, rtn, null);
		} catch (PageException pe) {
			throw new HibernatePageException(pe);
		}
	}

	public HibernateORMEngine getHibernateORMEngine() {
		try {
			// TODO better impl
			return HibernateUtil.getORMEngine(CommonUtil.pc());
		} catch (PageException e) {
			// engine not available in this context — caller handles null
		}

		return null;
	}

	@Override
	public Object getForInsert(Object trg, Map<Object, Object> map, SharedSessionContractImplementor ssci) {
		return get(trg);
	}

	@Override
	public Member getMember() {
		// Hibernate 7.x JPA metamodel build (AttributeFactory) requires the Member
		// to be Field, Method, or MapMember — anything else throws AssertionFailure
		// "Unexpected member type". CFCs aren't backed by a real Field/Method, so
		// hand back a MapMember (the dynamic-model virtual-member type Hibernate
		// uses for Map-mode entities).
		return new MapMember(key.getString(), type != null ? type.getReturnedClass() : Object.class);
	}

	@Override
	public Method getMethod() {
		return null;
	}

	@Override
	public String getMethodName() {
		return null;// MUST macht es sinn den namen zurueck zu geben?
	}

	@Override
	public Class<?> getReturnTypeClass() {
		return Object.class;
	}

	@Override
	public java.lang.reflect.Type getReturnType() {
		return Object.class;
	}

}