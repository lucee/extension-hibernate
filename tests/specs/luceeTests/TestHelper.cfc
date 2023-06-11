component{

    public component function init(){
        // Cache for all server time, cuz these validations are SLOOOOOW!
        // TODO: Move away from this super-ugly application scope (global data) in favor of... something better. 
        if ( !application.keyExists( "validDatasources" ) ){
            application.validDatasources = [];
            if ( isValidDatasource( "h2" ) ){
                application.validDatasources.append( "h2" );
            }
            if ( isValidDatasource( "mysql" ) ){
                application.validDatasources.append( "mysql" );
            }
            if ( isValidDatasource( "mssql" ) ){
                application.validDatasources.append( "mssql" );
            }
            if ( isValidDatasource( "postgres" ) ){
                application.validDatasources.append( "postgres" );
            }
        }
        return this;
    }

    public boolean function isValidDatasource( required string name ){
        return application.validDatasources.some( ( dsn ) => dsn == name );
    }

	public struct function getDatasource( required string datasource, 
        string dbFile="", 
        boolean verify=false, 
        boolean onlyConfig=false,
        string connectionString="",
        struct options={}
    ){

        switch ( arguments.datasource ){
            case "mssql":
                mssql = getSystemPropOrEnvVars( "SERVER, USERNAME, PASSWORD, PORT, DATABASE", "MSSQL_" );
                if ( structCount( msSql ) gt 0){
                    if ( arguments.onlyConfig )
                        return msSql;
                    return {
                        class: 'com.microsoft.sqlserver.jdbc.SQLServerDriver'
                        , bundleName: 'org.lucee.mssql'
                        , bundleVersion: '4.0.2206.100'
                        , connectionString: 'jdbc:sqlserver://#msSQL.SERVER#:#msSQL.PORT#;DATABASENAME=#msSQL.DATABASE#;sendStringParametersAsUnicode=true;SelectMethod=direct' & arguments.connectionString
                        , username: msSQL.username
                        , password: msSQL.password
                    }.append( arguments.options );
                }
                break;
            case "mysql":
                mysql = getSystemPropOrEnvVars( "SERVER, USERNAME, PASSWORD, PORT, DATABASE", "MYSQL_" );	
                if ( structCount( mySql ) gt 0 ){
                    if ( arguments.onlyConfig )
                        return mySql;
                    return {
                        class: 'com.mysql.cj.jdbc.Driver'
                        , bundleName: 'com.mysql.cj'
                        , bundleVersion: '8.0.19'
                        , connectionString: 'jdbc:mysql://#mySQL.server#:#mySQL.port#/#mySQL.database#?useUnicode=true&characterEncoding=UTF-8&useLegacyDatetimeCode=true&useSSL=false&allowPublicKeyRetrieval=true' & arguments.connectionString
                        , username: mySQL.username
                        , password: mySQL.password
                    }.append( arguments.options );
                }
                break;
            case "postgres":
                pgsql = getSystemPropOrEnvVars( "SERVER, USERNAME, PASSWORD, PORT, DATABASE", "POSTGRES_" );	
                if ( structCount( pgsql ) gt 0 ){
                    if ( arguments.onlyConfig )
                        return pgsql;
                    return {
                        class: 'org.postgresql.Driver'
                        , bundleName: 'org.postgresql.jdbc'
                        , bundleVersion: '42.2.20'
                        , connectionString: 'jdbc:postgresql://#pgsql.server#:#pgsql.port#/#pgsql.database#' & arguments.connectionString
                        , username: pgsql.username
                        , password: pgsql.password
                    }.append( arguments.options );
                }
                break;
            case "h2":
                if ( arguments.verify ){
                    tempDb = server._getTempDir("h2-verify");
                    if (! DirectoryExists( tempDb ) )
                        DirectoryCreate( tempDb );
                    arguments.dbFile = tempDb;
                }
                if ( Len( arguments.dbFile ) ){
                    return {
                        class: 'org.h2.Driver'
                        , bundleName: 'org.lucee.h2'
                        , bundleVersion: '2.1.214.0001L'
                        , connectionString: 'jdbc:h2:#arguments.dbFile#/db;MODE=MySQL' & arguments.connectionString
                    }.append( arguments.options );
                }
                break;
            case "mongoDB":
                mongoDB = getSystemPropOrEnvVars( "SERVER, PORT, DB", "MONGODB_" );
                mongoDBcreds = getSystemPropOrEnvVars( "USERNAME, PASSWORD", "MONGODB_" );
                if ( structCount( mongoDb ) eq 3 ){
                    if (structCount( mongoDBcreds ) eq 2 ){
                        StructAppend(mongoDB, mongoDBcreds)
                    } else {
                        // _getSystemPropOrEnvVars ignores empty variables
                        mongoDB.USERNAME="";
                        mongoDB.PASSWORD="";
                    }
                    return mongoDB;
                }
                break;
            case "oracle":
                oracle = getSystemPropOrEnvVars( "SERVER, USERNAME, PASSWORD, PORT, DATABASE", "ORACLE_" );	
                if ( structCount( oracle ) gt 0 ){
                    if ( arguments.onlyConfig )
                        return oracle;
                    return {
                        class: 'oracle.jdbc.OracleDriver'
                        , bundleName: 'org.lucee.oracle'
                        , bundleVersion: '19.17.0.0-ojdbc8'
                        , connectionString: 'jdbc:oracle:thin:@#oracle.server#:#oracle.port#/#oracle.database#' & arguments.connectionString
                        , username: oracle.username
                        , password: oracle.password
                    }.append( arguments.options );
                }
                break;
            default:
                break;
        }
        SystemOutput( "Warning datasource: [ #arguments.datasource# ] is not configured", true );
        return {};
    }

    public function getSystemPropOrEnvVars( string props="", string prefix="", boolean stripPrefix=true, boolean allowEmpty=false ) localmode=true{
        st = [=];
        keys = arguments.props.split( "," );
        n = arrayLen( keys ) ;
        loop list="environment,properties" item="src" {
            props = server.system[ src ];
            for (k in keys){
                k = prefix & trim( k );
                if ( !isNull( props[ k ] ) && Len( Trim( props[ k ] ) ) neq 0 ){
                    kk = k;
                    if ( arguments.stripPrefix )
                        kk = mid(k, len( arguments.prefix ) + 1 ); // i.e. return DATABASE for MSSQL_DATABASE
                    st[ kk ] = props[ k ];
                }
            }
            if ( structCount( st ) eq n )
                break;
            else 
                st = {};
        }
        if ( structCount( st ) eq n ){
            //systemOutput( st, true);
            return st; // all or nothing
        } else {
            return {};
        }
    };

    public function getTestPath(string calledName){
        return "/tests/specs/luceeTests/#calledName#";
    }
}