package org.lucee.extension.orm.hibernate.jdbc;

import java.sql.Connection;
import java.sql.SQLException;

import org.hibernate.engine.jdbc.connections.spi.ConnectionProvider;

import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.runtime.PageContext;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.exp.PageException;
import lucee.runtime.util.DBUtil;

public class ConnectionProviderImpl implements ConnectionProvider {

	private final DBUtil dbu;
	private CFMLEngine engine;
	private final DataSource ds;
	private final String user;
	private final String pass;

	public ConnectionProviderImpl(DataSource ds, String user, String pass) {
		engine = CFMLEngineFactory.getInstance();
		dbu = engine.getDBUtil();
		this.ds = ds;
		this.user = user;
		this.pass = pass;
	}

	@Override
	public Connection getConnection() throws SQLException {
		PageContext pc = engine.getThreadPageContext();

		try {
			return dbu.getDatasourceConnection(pc, ds, user, pass);
		}
		catch (PageException pe) {
			throw engine.getExceptionUtil().createPageRuntimeException(pe);
		}
	}

	@Override
	public void closeConnection(Connection conn) throws SQLException {
		if (conn instanceof DatasourceConnection) dbu.releaseDatasourceConnection(engine.getThreadConfig(), (DatasourceConnection) conn, false);
	}

	@Override
	public boolean supportsAggressiveRelease() {
		// nope
		return false;
	}

	@Override
	public boolean isUnwrappableAs(Class arg0) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public <T> T unwrap(Class<T> arg0) {
		// TODO Auto-generated method stub
		return null;
	}

}
