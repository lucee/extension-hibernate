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

		});

	}

	private string function uri() {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "logging";
	}

	private string function getLogAfterMarker( required string marker ) {
		var logFile = expandPath( "{lucee-config}/logs/orm.log" );
		if ( !fileExists( logFile ) ) return "";
		var content = fileRead( logFile );
		var pos = content.findNoCase( arguments.marker );
		if ( pos == 0 ) return content;
		return content.mid( pos + len( arguments.marker ), len( content ) );
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
