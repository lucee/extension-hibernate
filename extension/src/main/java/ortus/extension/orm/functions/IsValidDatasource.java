package ortus.extension.orm.functions;

import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.engine.CFMLEngine;
import lucee.runtime.ext.function.BIF;
import lucee.runtime.util.Cast;
import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DataSourceManager;
import lucee.runtime.db.DatasourceConnection;

public class IsValidDatasource extends BIF {

    public static Boolean call( PageContext pc, String name ) throws PageException {
        DataSource d = pc.getDataSource( name );
        DataSourceManager manager = pc.getDataSourceManager();

        try {
            DatasourceConnection conn = manager.getConnection( pc, d, d.getUsername(), d.getPassword() );
            manager.releaseConnection( pc, conn );
            return true;
        } catch ( PageException e ) {
            return false;
        }
    }

    @Override
    public Object invoke( PageContext pc, Object[] args ) throws PageException {
        CFMLEngine engine = CFMLEngineFactory.getInstance();
        Cast cast = engine.getCastUtil();

        if ( args.length == 1 )
            return call( pc, cast.toString( args[ 0 ] ) );

        throw engine.getExceptionUtil().createFunctionException( pc, "isValidDatasource", 1, 1, args.length );
    }
}
