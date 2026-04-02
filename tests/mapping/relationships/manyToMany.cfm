<cfscript>
// setup
sid = createUUID();
cid = createUUID();

student = entityNew( "Student", { id: sid, name: "Alice" } );
course  = entityNew( "Course", { id: cid, title: "Maths" } );

student.setCourses( [ course ] );
entitySave( student );
entitySave( course );
ormFlush();

// reload and verify relationship
loaded = entityLoadByPK( "Student", sid );
if ( !isObject( loaded ) ) throw( message="student should be loaded" );

courses = loaded.getCourses();
if ( !isArray( courses ) ) throw( message="courses should be array" );
if ( arrayLen( courses ) != 1 ) throw( message="expected 1 course, got #arrayLen( courses )#" );
if ( courses[ 1 ].getTitle() != "Maths" ) throw( message="expected Maths, got #courses[ 1 ].getTitle()#" );

echo( "ok" );
</cfscript>
