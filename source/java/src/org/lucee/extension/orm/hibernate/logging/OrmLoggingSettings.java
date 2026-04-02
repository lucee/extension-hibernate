package org.lucee.extension.orm.hibernate.logging;

import java.lang.reflect.Method;

import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.listener.ApplicationContext;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.type.Struct;

import org.lucee.extension.orm.hibernate.util.CommonUtil;
import lucee.runtime.type.Collection.Key;

/**
 * Reads ORM logging settings from ormSettings in Application.cfc.
 *
 * Since Lucee's ORMConfiguration interface only exposes {@code logSQL()}, we read
 * the additional settings ({@code logParams}, {@code logCache}, {@code formatSQL})
 * directly from the Application.cfc component's {@code this.ormSettings} struct.
 */
public class OrmLoggingSettings {

	private static final Key	KEY_ORM_SETTINGS	= CommonUtil.createKey( "ormSettings" );
	private static final Key	KEY_LOG_SQL			= CommonUtil.createKey( "logSQL" );
	private static final Key	KEY_LOG_PARAMS		= CommonUtil.createKey( "logParams" );
	private static final Key	KEY_LOG_CACHE		= CommonUtil.createKey( "logCache" );
	private static final Key	KEY_FORMAT_SQL		= CommonUtil.createKey( "formatSQL" );
	private static final Key	KEY_LOG_VERBOSE		= CommonUtil.createKey( "logVerbose" );

	public final boolean		logSQL;
	public final boolean		logParams;
	public final boolean		logCache;
	public final boolean		formatSQL;
	public final boolean		logVerbose;

	private OrmLoggingSettings( boolean logSQL, boolean logParams, boolean logCache, boolean formatSQL,
	    boolean logVerbose ) {
		this.logSQL		= logSQL;
		this.logParams	= logParams;
		this.logCache	= logCache;
		this.formatSQL	= formatSQL;
		this.logVerbose	= logVerbose;
	}

	/**
	 * Read ORM logging settings from the current application context.
	 *
	 * Reads logSQL from the ORMConfiguration interface, and the extension-specific
	 * settings (logParams, logCache, formatSQL) from the raw ormSettings struct
	 * on the Application.cfc component.
	 */
	public static OrmLoggingSettings load( PageContext pc, ORMConfiguration ormConf ) {
		boolean	logSQL		= ormConf.logSQL();
		boolean	logParams	= false;
		boolean	logCache	= false;
		boolean	formatSQL	= false;
		boolean	logVerbose	= false;

		Struct ormSettings = getOrmSettingsStruct( pc );
		if ( ormSettings != null ) {
			logSQL		= CommonUtil.toBooleanValue( ormSettings.get( KEY_LOG_SQL, logSQL ), logSQL );
			logParams	= CommonUtil.toBooleanValue( ormSettings.get( KEY_LOG_PARAMS, false ), false );
			logCache	= CommonUtil.toBooleanValue( ormSettings.get( KEY_LOG_CACHE, false ), false );
			formatSQL	= CommonUtil.toBooleanValue( ormSettings.get( KEY_FORMAT_SQL, false ), false );
			logVerbose	= CommonUtil.toBooleanValue( ormSettings.get( KEY_LOG_VERBOSE, false ), false );
		}

		return new OrmLoggingSettings( logSQL, logParams, logCache, formatSQL, logVerbose );
	}

	/**
	 * Try to read the raw ormSettings struct from the Application.cfc component.
	 *
	 * Uses reflection to access ModernApplicationContext.getComponent(), then reads
	 * this.ormSettings from the component's scope. Returns null if anything fails
	 * (e.g. ClassicApplicationContext, older Lucee version, no ormSettings set).
	 */
	private static Struct getOrmSettingsStruct( PageContext pc ) {
		try {
			ApplicationContext ac = pc.getApplicationContext();
			Method getComponent = ac.getClass().getMethod( "getComponent" );
			Component appCFC = ( Component ) getComponent.invoke( ac );
			if ( appCFC == null )
				return null;
			Object settings = appCFC.get( KEY_ORM_SETTINGS, null );
			if ( settings instanceof Struct )
				return ( Struct ) settings;
		} catch ( Exception e ) {
			// ClassicApplicationContext or older Lucee version - fall back to defaults
		}
		return null;
	}

	@Override
	public String toString() {
		return String.format( "OrmLoggingSettings[logSQL=%s, logParams=%s, logCache=%s, formatSQL=%s, logVerbose=%s]",
		    logSQL, logParams, logCache, formatSQL, logVerbose );
	}
}
