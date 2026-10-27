package org.lucee.extension.orm.hibernate.logging;

import lucee.commons.io.log.Log;

/**
 * Per-request ORM logging configuration.
 *
 * The ormSettings flags (logSQL, logParams, logCache) control which Hibernate logging categories
 * are enabled (the muzzle). The Lucee orm log level controls what severity actually gets written
 * (the pipe). Both filters must pass for a message to appear in orm.log.
 *
 * Uses a ThreadLocal so each request carries its own application's logging config.
 * Set via {@link #configure} when the ORM session is initialized, read by
 * {@link LuceeJBossLogger#isEnabled}.
 */
public class LoggerLevelManager {

	private static final String	CAT_SQL		= "org.hibernate.SQL";
	// H7 moved logging categories under org.hibernate.orm.* (SubSystemLogging.BASE).
	// Param binding is org.hibernate.orm.jdbc.bind (JdbcBindingLogging),
	// L2 cache is org.hibernate.orm.cache (SecondLevelCacheLogger).
	private static final String	CAT_PARAMS	= "org.hibernate.orm.jdbc.bind";
	private static final String	CAT_CACHE	= "org.hibernate.orm.cache";

	private static final ThreadLocal<LoggingConfig> currentConfig = new ThreadLocal<>();

	/**
	 * Per-request logging flags.
	 */
	private static class LoggingConfig {
		final boolean	logSQL;
		final boolean	logParams;
		final boolean	logCache;
		final boolean	logVerbose;
		final Log		luceeLog;

		LoggingConfig( boolean logSQL, boolean logParams, boolean logCache, boolean logVerbose, Log luceeLog ) {
			this.logSQL		= logSQL;
			this.logParams	= logParams;
			this.logCache	= logCache;
			this.logVerbose	= logVerbose;
			this.luceeLog	= luceeLog;
		}
	}

	/**
	 * Set the logging config for the current request thread.
	 *
	 * @param luceeLog   The Lucee Log instance (orm log).
	 * @param logSQL     Enable SQL statement logging.
	 * @param logParams  Enable parameter binding logging (implies logSQL).
	 * @param logCache   Enable cache activity logging.
	 * @param logVerbose Enable all other Hibernate logging (startup, mapping, session lifecycle).
	 */
	public static void configure( Log luceeLog, boolean logSQL, boolean logParams, boolean logCache,
	    boolean logVerbose ) {
		// logParams without logSQL is useless
		if ( logParams )
			logSQL = true;
		currentConfig.set( new LoggingConfig( logSQL, logParams, logCache, logVerbose, luceeLog ) );
	}

	/**
	 * Check if a message is enabled for the named Hibernate category.
	 * Returns false if no config is set (no active ORM request on this thread).
	 */
	public static boolean isEnabled( String name ) {
		LoggingConfig config = currentConfig.get();
		if ( config == null || config.luceeLog == null )
			return false;
		return isCategoryEnabled( config, name );
	}

	/**
	 * Get the Lucee Log instance for the current request.
	 */
	public static Log getLuceeLog() {
		LoggingConfig config = currentConfig.get();
		return config != null ? config.luceeLog : null;
	}

	/**
	 * Check if a category is enabled based on the boolean flags.
	 */
	private static boolean isCategoryEnabled( LoggingConfig config, String name ) {
		if ( name.startsWith( CAT_PARAMS ) )
			return config.logParams;
		if ( name.equals( CAT_SQL ) )
			return config.logSQL;
		if ( name.startsWith( CAT_CACHE ) )
			return config.logCache;
		// All other Hibernate categories (startup, mapping, session lifecycle, etc.)
		// require logVerbose. The extension's own logging bypasses this (direct log.log() calls).
		return config.logVerbose;
	}
}
