package org.lucee.extension.orm.hibernate.logging;

import lucee.runtime.PageContext;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.type.Struct;

import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.util.ORMConfigurationUtil;
import lucee.runtime.type.Collection.Key;

/**
 * Reads ORM logging settings from ormSettings in Application.cfc.
 *
 * Since Lucee's ORMConfiguration interface only exposes {@code logSQL()}, we read
 * the additional settings ({@code logParams}, {@code logCache}, {@code formatSQL})
 * directly from the Application.cfc component's {@code this.ormSettings} struct.
 */
public class OrmLoggingSettings {

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

		Struct ormSettings = ORMConfigurationUtil.getOrmSettings( pc );
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
	 * Check if the raw dbcreate string from this.ormSettings was silently defaulted to "none"
	 * by the Lucee loader (6.2 doesn't support create/create-drop/validate).
	 *
	 * @return a warning message if there's a mismatch, or null if everything is fine.
	 */
	public static String checkDbCreate( PageContext pc, int resolvedDbCreate ) {
		Struct ormSettings = ORMConfigurationUtil.getOrmSettings( pc );
		if ( ormSettings == null ) return null;

		Key KEY_DB_CREATE = CommonUtil.createKey( "dbcreate" );
		String raw = CommonUtil.toString( ormSettings.get( KEY_DB_CREATE, null ), null );
		if ( raw == null || raw.trim().isEmpty() ) return null;

		raw = raw.trim().toLowerCase();
		// These are the values that all Lucee versions understand
		if ( "none".equals( raw ) || "update".equals( raw ) || "dropcreate".equals( raw ) || "drop-create".equals( raw ) )
			return null;

		// If the resolved value is NONE but the raw value isn't one of the known strings,
		// the loader silently defaulted it
		if ( resolvedDbCreate == 0 )
			return "Unsupported dbcreate value [" + raw + "] for this Lucee version, defaulting to [none]";

		return null;
	}

	@Override
	public String toString() {
		return String.format( "OrmLoggingSettings[logSQL=%s, logParams=%s, logCache=%s, formatSQL=%s, logVerbose=%s]",
		    logSQL, logParams, logCache, formatSQL, logVerbose );
	}
}
