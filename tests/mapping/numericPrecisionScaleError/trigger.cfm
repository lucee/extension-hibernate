<cfscript>
// touching the entity forces ORM init / SF build, which is when Hibernate
// validates the column descriptors and rejects scale on a float type
entityNew( "FloatWithScale" );
echo( "ok" );
</cfscript>
