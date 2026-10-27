package org.lucee.extension.orm.hibernate.util;

import java.lang.reflect.Method;

import lucee.commons.io.res.Resource;
import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.listener.ApplicationContext;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.type.Struct;

// FUTURE update ORMConfiguration interface
public class ORMConfigurationUtil {

	private ORMConfigurationUtil() {}

	private static final Class[] CLASS_STRING = new Class[] { String.class };
	private static Method getDbCreate;
	private static Method getCatalog;
	private static Method getSchema;
	private static Method getSqlScript;
	private static Method getDialect;

	public static int getDbCreate(ORMConfiguration conf, String datasourceName) throws PageException {
		if (!Util.isEmpty(datasourceName) && !(datasourceName = datasourceName.trim().toLowerCase()).equals("__default__")) {
			CFMLEngine eng = CFMLEngineFactory.getInstance();
			// Lucee >= 5.3.2.16
			try {
				if (getDbCreate == null || getDbCreate.getDeclaringClass() != conf.getClass()) {
					getDbCreate = conf.getClass().getMethod("getDbCreate", CLASS_STRING);
				}
				return eng.getCastUtil().toIntValue(getDbCreate.invoke(conf, new Object[] { datasourceName }));
			}
			catch (NoSuchMethodException e) {
				// older Lucee version
			}
			catch (Exception e) {
				throw eng.getCastUtil().toPageException(e);
			}
		}
		return conf.getDbCreate();
	}

	public static String getCatalog(ORMConfiguration conf, String datasourceName) throws PageException {
		if (!Util.isEmpty(datasourceName) && !(datasourceName = datasourceName.trim().toLowerCase()).equals("__default__")) {
			CFMLEngine eng = CFMLEngineFactory.getInstance();
			// Lucee >= 5.3.2.16
			try {
				if (getCatalog == null || getCatalog.getDeclaringClass() != conf.getClass()) {
					getCatalog = conf.getClass().getMethod("getCatalog", CLASS_STRING);
				}
				return eng.getCastUtil().toString(getCatalog.invoke(conf, new Object[] { datasourceName }));
			}
			catch (NoSuchMethodException e) {
				// older Lucee version
			}
			catch (Exception e) {
				throw eng.getCastUtil().toPageException(e);
			}
		}
		return conf.getCatalog();
	}

	public static String getSchema(ORMConfiguration conf, String datasourceName) throws PageException {
		if (!Util.isEmpty(datasourceName) && !(datasourceName = datasourceName.trim().toLowerCase()).equals("__default__")) {
			CFMLEngine eng = CFMLEngineFactory.getInstance();
			// Lucee >= 5.3.2.16
			try {
				if (getSchema == null || getSchema.getDeclaringClass() != conf.getClass()) {
					getSchema = conf.getClass().getMethod("getSchema", CLASS_STRING);
				}
				return eng.getCastUtil().toString(getSchema.invoke(conf, new Object[] { datasourceName }));
			}
			catch (NoSuchMethodException e) {
				// older Lucee version
			}
			catch (Exception e) {
				throw eng.getCastUtil().toPageException(e);
			}
		}
		return conf.getSchema();
	}

	public static String getDialect(ORMConfiguration conf, String datasourceName) throws PageException {
		if (!Util.isEmpty(datasourceName) && !(datasourceName = datasourceName.trim().toLowerCase()).equals("__default__")) {
			CFMLEngine eng = CFMLEngineFactory.getInstance();
			// Lucee >= 5.3.2.16
			try {
				if (getDialect == null || getDialect.getDeclaringClass() != conf.getClass()) {
					getDialect = conf.getClass().getMethod("getDialect", CLASS_STRING);
				}
				return eng.getCastUtil().toString(getDialect.invoke(conf, new Object[] { datasourceName }));
			}
			catch (NoSuchMethodException e) {
				// older Lucee version
			}
			catch (Exception e) {
				throw eng.getCastUtil().toPageException(e);
			}
		}
		return conf.getDialect();
	}

	public static Resource getSqlScript(ORMConfiguration conf, String datasourceName) throws PageException {
		if (!Util.isEmpty(datasourceName) && !(datasourceName = datasourceName.trim().toLowerCase()).equals("__default__")) {
			CFMLEngine eng = CFMLEngineFactory.getInstance();
			// Lucee >= 5.3.2.16
			try {
				if (getSqlScript == null || getSqlScript.getDeclaringClass() != conf.getClass()) {
					getSqlScript = conf.getClass().getMethod("getSqlScript", CLASS_STRING);
				}
				return (Resource) getSqlScript.invoke(conf, new Object[] { datasourceName });
			}
			catch (NoSuchMethodException e) {
				// older Lucee version
			}
			catch (Exception e) {
				throw eng.getCastUtil().toPageException(e);
			}
		}
		return conf.getSqlScript();
	}

	private static final Key KEY_ORM_SETTINGS = CommonUtil.createKey("ormSettings");

	/**
	 * Reads the raw {@code this.ormSettings} struct from the current Application.cfc
	 * Component. Custom keys (those not in Lucee's standard ORMConfiguration set) survive
	 * here — {@link ORMConfiguration#toStruct()} only returns recognised keys.
	 *
	 * Uses reflection on {@code ModernApplicationContext.getComponent()}; returns null
	 * for ClassicApplicationContext, older Lucee versions, or applications without
	 * {@code this.ormSettings} configured.
	 *
	 * @param pc the page context for the current request
	 * @return the raw ormSettings struct, or null if unavailable
	 */
	public static Struct getOrmSettings(PageContext pc) {
		if (pc == null) return null;
		try {
			ApplicationContext ac = pc.getApplicationContext();
			Method getComponent = ac.getClass().getMethod("getComponent");
			Component appCFC = (Component) getComponent.invoke(ac);
			if (appCFC == null) return null;
			Object settings = appCFC.get(KEY_ORM_SETTINGS, null);
			if (settings instanceof Struct) return (Struct) settings;
		}
		catch (Exception e) {
			// ClassicApplicationContext / older Lucee / no ormSettings — caller falls back
		}
		return null;
	}

	public static void dump(ORMConfiguration ormConf, String name) throws PageException {

		System.err.println("---------------- " + name + " ---------------------");
		System.err.println("catalog: " + getCatalog(ormConf, name));
		System.err.println("dialect: " + getDialect(ormConf, name));
		System.err.println("schema: " + getSchema(ormConf, name));
		System.err.println("DbCreate: " + getDbCreate(ormConf, name));
		System.err.println("SqlScript: " + getSqlScript(ormConf, name));

		name = "susi";

		System.err.println("---------------- " + name + " ---------------------");
		System.err.println("catalog: " + getCatalog(ormConf, name));
		System.err.println("dialect: " + getDialect(ormConf, name));
		System.err.println("schema: " + getSchema(ormConf, name));
		System.err.println("DbCreate: " + getDbCreate(ormConf, name));
		System.err.println("SqlScript: " + getSqlScript(ormConf, name));

	}

}
