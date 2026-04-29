component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		admin action="getLogSettings" type="server" password="#request.SERVERADMINPASSWORD#" returnVariable="local.logsBefore";
		for ( var row in logsBefore ) {
			if ( row.name == "orm" ) systemOutput( "ORM LOG BEFORE: level=#row.level#", true );
		}

		configureOrmLog();

		admin action="getLogSettings" type="server" password="#request.SERVERADMINPASSWORD#" returnVariable="local.logsAfter";
		for ( var row in logsAfter ) {
			if ( row.name == "orm" ) systemOutput( "ORM LOG AFTER: level=#row.level#", true );
		}
	}

	function afterAll() {
		resetOrmLog();
	}

	function run( testResults, testBox ) {

		describe( "ORM logging (LDEV-6159)", function() {

			it( "logSQL=true logs SQL statements", function() {
				var marker = "MARKER_SQL_TRUE_#createUUID()#";
				var result = _InternalRequest(
					template: "#uri()#/index.cfm",
					url: { logSQL: true, logParams: false, marker: marker }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = getLogAfterMarker( marker );
				systemOutput( "LOG SQL TRUE: [#logContent#]", true );
				expect( lCase( logContent ) ).toInclude( "insert" );
			});

			it( "logSQL=false does not log SQL statements", function() {
				var marker = "MARKER_SQL_FALSE_#createUUID()#";
				var result = _InternalRequest(
					template: "#uri()#/index.cfm",
					url: { logSQL: false, logParams: false, marker: marker }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = getLogAfterMarker( marker );
				systemOutput( "LOG SQL FALSE: [#logContent#]", true );
				expect( lCase( logContent ) ).notToInclude( "insert" );
			});

			it( "logParams=true logs bound parameter values", function() {
				var marker = "MARKER_PARAMS_TRUE_#createUUID()#";
				var result = _InternalRequest(
					template: "#uri()#/index.cfm",
					url: { logSQL: true, logParams: true, marker: marker }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = getLogAfterMarker( marker );
				systemOutput( "LOG PARAMS TRUE: [#logContent#]", true );
				expect( logContent ).toInclude( "Toyota" );
			});

			it( "logParams=false does not log bound parameter values", function() {
				var marker = "MARKER_PARAMS_FALSE_#createUUID()#";
				var result = _InternalRequest(
					template: "#uri()#/index.cfm",
					url: { logSQL: true, logParams: false, marker: marker }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = getLogAfterMarker( marker );
				systemOutput( "LOG PARAMS FALSE: [#logContent#]", true );
				expect( logContent ).notToInclude( "Toyota" );
			});

			it( "formatSQL=true pretty-prints SQL with line breaks", function() {
				var marker = "MARKER_FORMAT_TRUE_#createUUID()#";
				var result = _InternalRequest(
					template: "#uri()#/index.cfm",
					url: { logSQL: true, logParams: false, formatSQL: true, marker: marker }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = getLogAfterMarker( marker );
				systemOutput( "LOG FORMAT TRUE: [#logContent#]", true );
				// formatted SQL contains "insert" spread across multiple log lines
				expect( lCase( logContent ) ).toInclude( "insert" );
				// formatted SQL indents columns — look for leading whitespace before column keywords
				expect( logContent ).toMatch( "(?m)^\s+(values|into)" );
			});

			it( "formatSQL=false keeps SQL on single lines", function() {
				var marker = "MARKER_FORMAT_FALSE_#createUUID()#";
				var result = _InternalRequest(
					template: "#uri()#/index.cfm",
					url: { logSQL: true, logParams: false, formatSQL: false, marker: marker }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = getLogAfterMarker( marker );
				systemOutput( "LOG FORMAT FALSE: [#logContent#]", true );
				expect( lCase( logContent ) ).toInclude( "insert" );
				// unformatted SQL should NOT have indented keywords
				expect( logContent ).notToMatch( "(?m)^\s+(values|into)" );
			});

			it( "logVerbose=true logs Hibernate internals", function() {
				var marker = "MARKER_VERBOSE_TRUE_#createUUID()#";
				var result = _InternalRequest(
					template: "#uri()#/index.cfm",
					url: { logSQL: false, logParams: false, logVerbose: true, marker: marker }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = lCase( getLogAfterMarker( marker ) );
				systemOutput( "LOG VERBOSE TRUE: [#logContent#]", true );
				// verbose logging should include session/entity lifecycle keywords
				expect(
					logContent contains "flush" ||
					logContent contains "dirty" ||
					logContent contains "session" ||
					logContent contains "entity" ||
					logContent contains "schema" ||
					logContent contains "auto-flushing"
				).toBeTrue();
			});

			it( "logVerbose=false does not log Hibernate internals", function() {
				var marker = "MARKER_VERBOSE_FALSE_#createUUID()#";
				var result = _InternalRequest(
					template: "#uri()#/index.cfm",
					url: { logSQL: false, logParams: false, logVerbose: false, marker: marker }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = lCase( getLogAfterMarker( marker ) );
				systemOutput( "LOG VERBOSE FALSE: [#logContent#]", true );
				// with all logging off, only the marker itself should be in the log
				expect( logContent ).notToInclude( "auto-flushing" );
				expect( logContent ).notToInclude( "dirty checking" );
			});

			it( "dual-gate: logSQL=true with ERROR log level produces no output", function() {
				try {
					// temporarily set orm log to ERROR — the level gate should block everything
					configImport( type: "server", password: request.SERVERADMINPASSWORD, data: {
						loggers: {
							orm: {
								appender: "resource",
								appenderArguments: { path: "{lucee-config}/logs/orm.log" },
								level: "error",
								layout: "classic"
							}
						}
					});

					// can't use markers — cflog at INFO would be blocked by ERROR level
					// instead, capture log length before and check only new content
					var offsetBefore = getLogLength();
					var result = _InternalRequest(
						template: "#uri()#/index.cfm",
						url: { logSQL: true, logParams: true, marker: "DUALGATE_IGNORED" }
					);
					expect( trim( result.filecontent ) ).toBe( "ok" );
					var logContent = getLogContentSince( offsetBefore );
					systemOutput( "LOG DUALGATE: [#logContent#]", true );
					// SQL is logged at DEBUG/TRACE — ERROR level should block it
					expect( lCase( logContent ) ).notToInclude( "insert" );
					expect( logContent ).notToInclude( "Toyota" );
				} finally {
					// restore TRACE level for subsequent tests
					configureOrmLog();
				}
			});

		});

		describe( "ORM cache logging", function() {

			it( "logCache=true logs L2 cache activity", function() {
				var marker = "MARKER_CACHE_TRUE_#createUUID()#";
				var result = _InternalRequest(
					template: "#logCacheUri()#/index.cfm",
					url: { logCache: true, marker: marker }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = lCase( getLogAfterMarker( marker ) );
				systemOutput( "LOG CACHE TRUE: [#logContent#]", true );
				expect(
					logContent contains "cache" ||
					logContent contains "region" ||
					logContent contains "put" ||
					logContent contains "hit" ||
					logContent contains "miss"
				).toBeTrue();
			});

			it( "logCache=false does not log cache activity", function() {
				var marker = "MARKER_CACHE_FALSE_#createUUID()#";
				var result = _InternalRequest(
					template: "#logCacheUri()#/index.cfm",
					url: { logCache: false, marker: marker }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = lCase( getLogAfterMarker( marker ) );
				systemOutput( "LOG CACHE FALSE: [#logContent#]", true );
				// with logCache off, no cache keywords should appear
				expect( logContent ).notToInclude( "caching" );
				expect( logContent ).notToInclude( "region" );
			});

		});

		describe( "savemapping", function() {

			it( "savemapping=true writes .hbm.xml alongside entity CFC", function() {
				var result = _InternalRequest(
					template: "#savemappingUri()#/index.cfm"
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

		describe( "this.logs application-level log override", function() {

			it( title="app this.logs=TRACE overrides server ERROR — SQL appears", skip=notHasThisLogs(), body=function() {
				try {
					// set server orm log to ERROR
					configImport( type: "server", password: request.SERVERADMINPASSWORD, data: {
						loggers: {
							orm: {
								appender: "resource",
								appenderArguments: { path: "{lucee-config}/logs/orm.log" },
								level: "error",
								layout: "classic"
							}
						}
					});

					var marker = "MARKER_APPLOG_TRACE_#createUUID()#";
					var result = _InternalRequest(
						template: "#appLogLevelUri( 'appOverrideTrace' )#/index.cfm",
						url: { marker: marker }
					);
					expect( trim( result.filecontent ) ).toBe( "ok" );
					var logContent = lCase( getLogAfterMarker( marker ) );
					systemOutput( "LOG APP TRACE OVERRIDE: [#logContent#]", true );
					// app this.logs TRACE overrides server ERROR — SQL appears
					expect( logContent ).toInclude( "insert" );
				} finally {
					configureOrmLog();
				}
			});

			it( title="app this.logs=TRACE works with no server orm log", skip=notHasThisLogs(), body=function() {
				try {
					// remove the server orm log entirely
					admin
						action="removeLogSetting"
						type="server"
						password="#request.SERVERADMINPASSWORD#"
						name="orm";

					var marker = "MARKER_APPLOG_NOSERVER_#createUUID()#";
					var result = _InternalRequest(
						template: "#appLogLevelUri( 'appOverrideTrace' )#/index.cfm",
						url: { marker: marker }
					);
					expect( trim( result.filecontent ) ).toBe( "ok" );
					var logContent = lCase( getLogAfterMarker( marker ) );
					systemOutput( "LOG APP NO SERVER: [#logContent#]", true );
					// app defines orm log via this.logs — should work without server log
					expect( logContent ).toInclude( "insert" );
				} finally {
					configureOrmLog();
				}
			});

			it( title="app this.logs=ERROR overrides server TRACE — SQL blocked", skip=notHasThisLogs(), body=function() {
				// server is at TRACE (restored by beforeAll / previous finally)
				// app sets orm log to ERROR via this.logs — app wins, blocks SQL
				// can't use markers — this.logs ERROR blocks cflog at INFO too
				var offsetBefore = getLogLength();
				var result = _InternalRequest(
					template: "#appLogLevelUri( 'appOverrideError' )#/index.cfm",
					url: { marker: "APPLOG_ERROR_IGNORED" }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = lCase( getLogContentSince( offsetBefore ) );
				systemOutput( "LOG APP ERROR OVERRIDE: [#logContent#]", true );
				// app this.logs ERROR overrides server TRACE — SQL blocked
				expect( logContent ).notToInclude( "insert" );
			});

		});

		describe( "ORM lifecycle logging", function() {

			it( "cold start logs ORM initializing and initialized", function() {
				var offsetBefore = getLogLength();
				var appId = createUUID();
				var result = _InternalRequest(
					template: "#lifecycleUri()#/index.cfm",
					url: { appId: appId }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = getLogContentSince( offsetBefore );
				systemOutput( "LOG LIFECYCLE COLD: [#logContent#]", true );
				expect( lCase( logContent ) ).toInclude( "orm initializing for application [" );
				expect( lCase( logContent ) ).toInclude( "orm initialized [" );
				expect( lCase( logContent ) ).toInclude( "] entities" );
				expect( lCase( logContent ) ).toInclude( "dbcreate [" );
				expect( lCase( logContent ) ).toInclude( "ormloggingsettings[" );
				// cold start should NOT contain ormReload message
				expect( lCase( logContent ) ).notToInclude( "ormreload()" );
			});

			it( "ormReload logs reload trigger and init messages", function() {
				var offsetBefore = getLogLength();
				var appId = createUUID();
				// first request: cold start
				_InternalRequest(
					template: "#lifecycleUri()#/index.cfm",
					url: { appId: appId }
				);
				// second request: same app, calls ormReload()
				var offsetBeforeReload = getLogLength();
				var result = _InternalRequest(
					template: "#lifecycleUri()#/reload.cfm",
					url: { appId: appId }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
				var logContent = getLogContentSince( offsetBeforeReload );
				systemOutput( "LOG LIFECYCLE RELOAD: [#logContent#]", true );
				expect( lCase( logContent ) ).toInclude( "ormreload() for application [" );
				expect( lCase( logContent ) ).toInclude( "orm initializing for application [" );
				expect( lCase( logContent ) ).toInclude( "orm initialized [" );
			});

		});

		describe( "Per-request logging config refresh", function() {

			it( "second request without ormReload picks up new logSQL setting", function() {
				var appId = createUUID();

				// Request 1: logSQL=true → cold start initialises SF, marker A then INSERT logged
				var markerOn = "MARKER_PERSIST_ON_#createUUID()#";
				var resultOn = _InternalRequest(
					template: "#lifecycleUri()#/index.cfm",
					url: { appId: appId, logSQL: true, marker: markerOn }
				);
				expect( trim( resultOn.filecontent ) ).toBe( "ok" );
				var logOn = lCase( getLogAfterMarker( markerOn ) );
				systemOutput( "LOG PERSIST ON: [#logOn#]", true );
				expect( logOn ).toInclude( "insert" );

				// Request 2: same appId (SF reused, no ormReload), logSQL=false this time
				// Bug pre-fix: ThreadLocal still has logSQL=true from request 1, so INSERT is logged anyway
				// Post-fix: HibernateORMSession constructor reconfigures per request, INSERT not logged
				var markerOff = "MARKER_PERSIST_OFF_#createUUID()#";
				var resultOff = _InternalRequest(
					template: "#lifecycleUri()#/index.cfm",
					url: { appId: appId, logSQL: false, marker: markerOff }
				);
				expect( trim( resultOff.filecontent ) ).toBe( "ok" );
				var logOff = lCase( getLogAfterMarker( markerOff ) );
				systemOutput( "LOG PERSIST OFF: [#logOff#]", true );
				expect( logOff ).notToInclude( "insert" );
			});

		});

		describe( "Per-application logging isolation", function() {

			it( "app with logSQL=true logs SQL, app with logSQL=false does not", function() {
				// app with logging ON
				var markerOn = "MARKER_ISO_ON_#createUUID()#";
				var resultOn = _InternalRequest(
					template: "#isolationUri( 'appLogsOn' )#/index.cfm",
					url: { marker: markerOn }
				);
				expect( trim( resultOn.filecontent ) ).toBe( "ok" );
				var logOn = lCase( getLogAfterMarker( markerOn ) );
				systemOutput( "LOG ISO ON: [#logOn#]", true );

				// app with logging OFF
				var markerOff = "MARKER_ISO_OFF_#createUUID()#";
				var resultOff = _InternalRequest(
					template: "#isolationUri( 'appLogsOff' )#/index.cfm",
					url: { marker: markerOff }
				);
				expect( trim( resultOff.filecontent ) ).toBe( "ok" );
				var logOff = lCase( getLogAfterMarker( markerOff ) );
				systemOutput( "LOG ISO OFF: [#logOff#]", true );

				// ON app should have SQL
				expect( logOn ).toInclude( "insert" );
				// OFF app should NOT have SQL
				expect( logOff ).notToInclude( "insert" );
			});

		});

	}

	private boolean function notHasThisLogs() {
		return !server.checkVersionGTE( server.lucee.version, 7, 0, 0, 115 );
	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "logging";
	}

	private string function logCacheUri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "logCache";
	}

	private string function savemappingUri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "savemapping";
	}

	private string function lifecycleUri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "lifecycle";
	}

	private string function isolationUri( required string app ) {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "isolation/" & arguments.app;
	}

	private string function appLogLevelUri( required string app ) {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "appLogLevel/" & arguments.app;
	}

	private string function getLogAfterMarker( required string marker ) {
		var logFile = expandPath( "{lucee-config}/logs/orm.log" );
		if ( !fileExists( logFile ) ) return "";
		var content = fileRead( logFile );
		var pos = content.findNoCase( arguments.marker );
		if ( pos == 0 ) return "";
		return content.mid( pos + len( arguments.marker ), len( content ) );
	}

	private string function getLogContentSince( required numeric offset ) {
		var logFile = expandPath( "{lucee-config}/logs/orm.log" );
		if ( !fileExists( logFile ) ) return "";
		var content = fileRead( logFile );
		if ( len( content ) <= arguments.offset ) return "";
		return content.mid( arguments.offset + 1, len( content ) );
	}

	private numeric function getLogLength() {
		var logFile = expandPath( "{lucee-config}/logs/orm.log" );
		if ( !fileExists( logFile ) ) return 0;
		return len( fileRead( logFile ) );
	}

	private void function configureOrmLog() {
		configImport( type: "server", password: request.SERVERADMINPASSWORD, data: {
			loggers: {
				orm: {
					appender: "resource",
					appenderArguments: { path: "{lucee-config}/logs/orm.log" },
					level: "trace",
					layout: "classic"
				}
			}
		});
	}

	private void function resetOrmLog() {
		return; // short circuit for now
		configImport( type: "server", password: request.SERVERADMINPASSWORD, data: {
			loggers: {
				orm: {
					appender: "resource",
					appenderArguments: { path: "{lucee-config}/logs/orm.log" },
					level: "error",
					layout: "classic"
				}
			}
		});
	}

}
