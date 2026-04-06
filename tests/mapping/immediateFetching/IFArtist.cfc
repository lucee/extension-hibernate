component persistent="true" table="IF_Artist" accessors="true" {

	property name="id"   fieldtype="id" ormtype="string";
	property name="name" ormtype="string";
	// immediate fetching: lazy=false + fetch=select
	// loads via separate SELECT immediately (not via JOIN)
	// Adobe docs warn this is vulnerable to N+1
	property name="artworks"
		fieldtype="one-to-many"
		cfc="IFArtwork"
		fkcolumn="artistId"
		type="array"
		lazy="false"
		fetch="select";

}
