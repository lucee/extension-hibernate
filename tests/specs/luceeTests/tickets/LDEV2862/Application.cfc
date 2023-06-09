component {
    this.name = "LDEV-2862";
    this.ormEnabled = "true";
    this.ormSettings = {
        dbCreate = "dropcreate"
    }

    this.datasource = server.helpers.getDatasource("h2", expandPath( "./db/LDEV2862") );

    public function onRequestStart() {
        query result="test"{
            echo("INSERT INTO test(A) VALUES( 'testA' )");
        }
        query result="test2"{
            echo("INSERT INTO test2(B) VALUES( 'testB' )");
        }
        query {
            echo("INSERT INTO okok(testid, id) VALUES( #test.GENERATEDKEY#, #test2.GENERATEDKEY# )");
        }
    }
}