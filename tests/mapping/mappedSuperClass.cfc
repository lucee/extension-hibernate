component extends="org.lucee.cfml.test.LuceeTestCase" labels="orm" {

	function beforeAll() {
		// Need WARN-or-lower for the LDEV-6340 bug message to land in orm.log;
		// default server level may be ERROR. logging.cfc uses the same pattern.
		configImport( type: "server", password: request.SERVERADMINPASSWORD, data: {
			loggers: {
				orm: {
					appender         : "resource",
					appenderArguments: { path: "{lucee-config}/logs/orm.log" },
					level            : "trace",
					layout           : "classic"
				}
			}
		});
	}

	function run( testResults, testBox ) {

		describe( "mappedSuperClass — LDEV-6340 log noise", function() {

			it( "User extends mappedSuperClass BaseEntity — entity ops work and log stays clean", function() {
				var appId = createUUID();
				var offsetBefore = getLogLength();

				var result = _InternalRequest(
					template: "#uri( "basic" )#/index.cfm",
					url     : { appId: appId }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );

				var logContent = getLogContentSince( offsetBefore );
				systemOutput( "LDEV-6340 LOG: [#logContent#]", true );

				expect( logContent ).notToInclude( "failed to resolve parent entity" );
				expect( logContent ).notToInclude( "Entity [BaseEntity] does not exist" );
			});

		});

		describe( "mappedSuperClass — property inheritance shapes", function() {

			it( "parent declares @Id — child inherits the id field", function() {
				var result = _InternalRequest(
					template: "#uri( "parentId" )#/index.cfm",
					url     : { appId: createUUID() }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "multi-level chain — child inherits properties from grand-mappedSuperClass", function() {
				var result = _InternalRequest(
					template: "#uri( "multiLevel" )#/index.cfm",
					url     : { appId: createUUID() }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "mappedSuperClass + real entity TPH inheritance — Car gets mappedSuperClass props two levels up", function() {
				var result = _InternalRequest(
					template: "#uri( "mixedInheritance" )#/index.cfm",
					url     : { appId: createUUID() }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

			it( "child redeclares parent property with different column + length — child wins", function() {
				var result = _InternalRequest(
					template: "#uri( "attrOverride" )#/index.cfm",
					url     : { appId: createUUID() }
				);
				expect( trim( result.filecontent ) ).toBe( "ok" );
			});

		});

	}

	private string function uri( required string scenario ) {
		return getDirectoryFromPath( contractPath( getCurrentTemplatePath() ) ) & "mappedSuperClass/" & arguments.scenario;
	}

	private numeric function getLogLength() {
		var logFile = expandPath( "{lucee-config}/logs/orm.log" );
		if ( !fileExists( logFile ) ) return 0;
		return len( fileRead( logFile ) );
	}

	private string function getLogContentSince( required numeric offset ) {
		var logFile = expandPath( "{lucee-config}/logs/orm.log" );
		if ( !fileExists( logFile ) ) return "";
		var content = fileRead( logFile );
		if ( len( content ) <= arguments.offset ) return "";
		return content.mid( arguments.offset + 1, len( content ) );
	}

}
