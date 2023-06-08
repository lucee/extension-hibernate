package org.lucee.extension.orm.hibernate;

import java.lang.reflect.Method;

import org.lucee.extension.orm.hibernate.SessionFactoryData;

import lucee.loader.engine.CFMLEngineFactory;
import lucee.runtime.Component;
import lucee.runtime.db.DataSource;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMSession;
import lucee.runtime.type.Collection.Key;

public class ExceptionUtil {

	private static Method setAdditional;

	/**
	 * Create a generic PageException with the given message. Utilizes Lucee's
	 * <code>lucee.runtime.op.ExceptonImpl</code> under the hood.
	 *
	 * @param message
	 *            Exception message
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
	 * @param message
	 *            Exception message
	 * @param detail
	 *            Exception detail string
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
		catch (Throwable t) {
			if (t instanceof ThreadDeath) throw (ThreadDeath) t;
		}
	}
	
	/**
	 * A java.lang.ThreadDeath must never be caught, so any catch(Throwable t) must go through this method in order to
	 * ensure that the throwable is not of type ThreadDeath
	 *
	 * @param t
	 *            the thrown Throwable
	 */
	public static void rethrowIfNecessary(Throwable t) {
		if (unwrap(t) instanceof ThreadDeath)
			throw (ThreadDeath) t; // never catch a ThreadDeath
	}

	private static Throwable unwrap(Throwable t) {
		if (t == null)
			return t;
		// if (t instanceof NativeException) return unwrap(((NativeException) t).getException());
		Throwable cause = t.getCause();
		if (cause != null && cause != t)
			return unwrap(cause);
		return t;
	}
}
