package org.lucee.extension.orm.hibernate.util;

import org.lucee.extension.orm.hibernate.SessionFactoryData;

import java.lang.reflect.Method;

import lucee.loader.engine.CFMLEngineFactory;
import lucee.runtime.Component;
import lucee.runtime.db.DataSource;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMSession;
import lucee.runtime.type.Collection.Key;

public class ExceptionUtil {

	private ExceptionUtil() {}

	private static Method setAdditional;

	/**
	 * Create a generic PageException with the given message. Utilizes Lucee's
	 * <code>lucee.runtime.op.ExceptonImpl</code> under the hood.
	 *
	 * @param message Exception message
	 *
	 * @return A PageException object
	 */
	public static PageException createException(String message) {
		return CFMLEngineFactory.getInstance().getExceptionUtil().createApplicationException(message);
	}

	/**
	 * Create a generic PageException with the given message and detail. Utilizes Lucee's
	 * <code>lucee.runtime.op.ExceptonImpl</code> under the hood.
	 *
	 * @param message Exception message
	 * @param detail Exception detail string
	 *
	 * @return A PageException object
	 */
	public static PageException createException(String message, String detail) {
		return CFMLEngineFactory.getInstance().getExceptionUtil().createApplicationException(message, detail);
	}

	public static PageException createException(SessionFactoryData data, Component cfc, String msg, String detail) {

		PageException pe = createException((ORMSession) null, cfc, msg, detail);
		if (data != null) setAddional(pe, data);
		return pe;
	}

	public static PageException createException(SessionFactoryData data, Component cfc, Throwable t) {
		PageException pe = createException((ORMSession) null, cfc, t);
		if (data != null) setAddional(pe, data);
		return pe;
	}

	public static PageException createException(ORMSession session, Component cfc, Throwable t) {
		return CFMLEngineFactory.getInstance().getORMUtil().createException(session, cfc, t);
	}

	public static PageException createException(ORMSession session, Component cfc, String message, String detail) {
		return CFMLEngineFactory.getInstance().getORMUtil().createException(session, cfc, message, detail);
	}

	private static void setAddional(PageException pe, SessionFactoryData data) {
		setAdditional(pe, CommonUtil.createKey("Entities"), CFMLEngineFactory.getInstance().getListUtil().toListEL(data.getEntityNames(), ", "));
		setAddional(pe, data.getDataSources());
	}

	private static void setAddional(PageException pe, DataSource... sources) {
		if (sources != null && sources.length > 0) {
			StringBuilder sb = new StringBuilder();
			for (int i = 0; i < sources.length; i++) {
				if (i > 0) sb.append(", ");
				sb.append(sources[i].getName());
			}
			setAdditional(pe, CommonUtil.createKey("_Datasource"), sb.toString());
		}
	}

	public static void setAdditional(PageException pe, Key name, Object value) {
		try {
			if (setAdditional == null || setAdditional.getDeclaringClass() != pe.getClass()) {
				setAdditional = pe.getClass().getMethod("setAdditional", new Class[] { Key.class, Object.class });
			}
			setAdditional.invoke(pe, new Object[] { name, value });
		}
		catch (Exception e) {
			// reflection failure — additional info won't be attached but not critical
		}
	}

	public static PageException toPageException( Throwable t ) {
		Throwable original = t;

		// unwrap JPA PersistenceException to get to the Hibernate/JDBC cause
		// With a real Hibernate transaction (LDEV-6206), exceptions are wrapped in
		// jakarta.persistence.PersistenceException (e.g. OptimisticLockException)
		// before reaching us
		if ( t instanceof jakarta.persistence.PersistenceException && t.getCause() != null ) {
			t = t.getCause();
		}

		PageException pe;
		if ( t instanceof org.hibernate.HibernateException ) {
			org.hibernate.HibernateException he = ( org.hibernate.HibernateException ) t;
			Throwable cause = he.getCause();
			if ( cause != null ) {
				// use the root DB exception for the message, create a proper DatabaseException
				pe = CFMLEngineFactory.getInstance().getExceptionUtil()
					.createDatabaseException( cause.getMessage() );
				try {
					pe.initCause( original );
				}
				catch ( IllegalStateException ise ) {
					// cause already set
				}
			}
			else {
				pe = CFMLEngineFactory.getInstance().getExceptionUtil()
					.createDatabaseException( he.getMessage() );
				try {
					pe.initCause( original );
				}
				catch ( IllegalStateException ise ) {
					// cause already set
				}
			}
			setAdditional( pe, CommonUtil.createKey( "hibernate exception" ), t );
		}
		else if ( t instanceof java.sql.SQLException ) {
			pe = CFMLEngineFactory.getInstance().getExceptionUtil()
				.createDatabaseException( t.getMessage() );
			try {
				pe.initCause( original );
			}
			catch ( IllegalStateException ise ) {
				// cause already set
			}
		}
		else {
			pe = CFMLEngineFactory.getInstance().getCastUtil().toPageException( t );
		}

		if ( t instanceof org.hibernate.JDBCException ) {
			org.hibernate.JDBCException je = ( org.hibernate.JDBCException ) t;
			setAdditional( pe, CommonUtil.createKey( "sql" ), je.getSQL() );
		}
		if ( t instanceof org.hibernate.exception.ConstraintViolationException ) {
			org.hibernate.exception.ConstraintViolationException cve = ( org.hibernate.exception.ConstraintViolationException ) t;
			if ( cve.getConstraintName() != null && !cve.getConstraintName().isEmpty() ) {
				setAdditional( pe, CommonUtil.createKey( "constraint name" ), cve.getConstraintName() );
			}
		}
		return pe;
	}

}
