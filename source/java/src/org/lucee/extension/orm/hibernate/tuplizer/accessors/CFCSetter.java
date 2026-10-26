package org.lucee.extension.orm.hibernate.tuplizer.accessors;

import java.lang.reflect.Method;

import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.hibernate.property.access.spi.Setter;
import org.hibernate.type.Type;
import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.HibernatePageException;

import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.component.Property;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.type.Struct;
import lucee.runtime.type.scope.Variables;

public final class CFCSetter implements Setter {

	private static final String EXPRESSION_DEFAULT_CLASS = "lucee.runtime.component.ExpressionDefault";
	private static final Key KEY_DEFAULT = CommonUtil.createKey( "default" );

	private Key key;
	private Type type;
	private Object entityName;

	/**
	 * Constructor of the class
	 * 
	 * @param key
     *            String name of the persistent property
	 * @param type
     *            Hibernate Type of this persistent property
     * @param entityName
     *            String name of the Hibernate entity this property is defined on
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
			if ( value == null ) {
				Object defaultValue = getPropertyDefault( cfc );
				if ( defaultValue != null ) {
					value = defaultValue;
				}
			}
			cfc.getComponentScope().set(key, value);
		} catch (PageException pe) {
			throw new HibernatePageException(pe);
		}
	}

	/**
	 * Look up the default value for this property from the CFC metadata.
	 */
	private Object getPropertyDefault( Component cfc ) throws PageException {
		Property[] props = cfc.getProperties( true, false, false, false );
		String keyStr = key.getString();
		for ( Property prop : props ) {
			if ( keyStr.equalsIgnoreCase( prop.getName() ) ) {
				String literal = prop.getDefault();
				if ( literal != null ) return literal;
				return evaluateExpressionDefault( cfc, prop );
			}
		}
		return null;
	}

	/**
	 * LDEV-6303: a default given as an expression (default="#now()#") has no static value,
	 * {@link Property#getDefault()} returns null for it. The metadata holds the source of the
	 * expression, it is evaluated here in the context of the component.
	 */
	private static Object evaluateExpressionDefault( Component cfc, Property prop ) throws PageException {
		Object meta = prop.getMetaData();
		if ( !( meta instanceof Struct ) ) return null;
		Object def = ( ( Struct ) meta ).get( KEY_DEFAULT, null );
		if ( def == null || !EXPRESSION_DEFAULT_CLASS.equals( def.getClass().getName() ) ) return null;

		PageContext pc = CommonUtil.pc();
		if ( pc == null ) return null;
		Variables before = pc.variablesScope();
		pc.setVariablesScope( cfc.getComponentScope() );
		try {
			return pc.evaluate( def.toString() );
		} finally {
			pc.setVariablesScope( before );
		}
	}
}