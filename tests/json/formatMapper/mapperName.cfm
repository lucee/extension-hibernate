<cfscript>
	factory = ormGetSessionFactory();
	mapper = factory.getSessionFactoryOptions().getJsonFormatMapper();
	echo( mapper.getClass().getName() );
</cfscript>
