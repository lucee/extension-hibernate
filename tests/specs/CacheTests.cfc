/**
* Cache Tests
*/
component extends="testbox.system.BaseSpec"{

/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
	}

/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		xdescribe( "Ortus Redis Extension", function(){

			it( "can store and get simple values", function(){
				cachePut( "simple", "hello" );
				expect(	cacheGet( "simple" ) ).toBe( "hello" );
			});

			it( "can store and get complex values", function(){
				var data = {
					name 	: 'luis majano',
					dob 	: "09/19/1977",
					children : [ "alexia", "lucas" ]
				};
				cacheput( "complex", data );
				expect(	cacheGet( "complex") ).toBe( data );
			});

			it( "can clear cache entries", function(){
				cachePut( "simple", "hello" );
				cacheClear( "simple" );
				expect(	cacheIdExists( "simple" ) ).toBeFalse();

				cachePut( "simple", "hello" );
				cacheDelete( "simple" );
				expect(	cacheIdExists( "simple" ) ).toBeFalse();
			});

			it( "can do cache counts and all cache removals", function(){
				cacheRemoveAll();
				expect(	cacheCount() ).toBe( 0 );

				cacheput( "simple", 1 );
				expect(	cacheCount() ).toBe( 1 );
			});

			it( "can get all cache ids", function(){
				cacheRemoveAll();
				cachePut( "luis-test", "hello" );
				cachePut( "luis-test2", "hello" );
				cachePut( "luis-test3", "hello" );

				var results = cacheGetAllIds();
				expect(	results ).toBeArray()
					.toInclude( "luis-test" )
					.toInclude( "luis-test2" )
					.toInclude( "luis-test3" );
			});

			it( "can get cache item metadata", function(){
				cachePut( "timespan", "hello", createTimespan( 0, 0, 1, 0 ), createTimespan( 0, 0, 0, 30 ) );
				var md = cacheGetMetadata( "timespan" );
				expect(	md ).toBeStruct()
					.toHaveKey( "hitcount" );
				expect(	md.hitCount ).toBe( 1 );
				expect(	md.createdtime ).toBeDate();
				expect(	md.cache_custom ).toBeStruct()
					.notToBeEmpty();

				debug( md );
			});

			it( "can get all with filters", function(){
				cachePut( "luis-test", "hello test"  );
				cachePut( "luis-test2", "hello test 2" );
				cachePut( "luis-test3", "hello test 3" );

				var results = cacheGetAll( "luis-*" );
				expect( results ).toHaveKey( "lucee-cache-luis-test,lucee-cache-luis-test2,lucee-cache-luis-test3" );
			});

		});
	}

}