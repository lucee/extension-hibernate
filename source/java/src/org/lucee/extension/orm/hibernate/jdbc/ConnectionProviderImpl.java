package org.lucee.extension.orm.hibernate.jdbc;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import org.hibernate.HibernateException;
import org.hibernate.connection.ConnectionProvider;
import org.lucee.extension.orm.hibernate.CommonUtil;

import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.PageContext;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.exp.PageException;
import lucee.runtime.util.DBUtil;

public class ConnectionProviderImpl implements ConnectionProvider {

	private final DBUtil dbu;
	private CFMLEngine engine;
	private String dsn;
	private String user;
	private String pass;
	private DataSource ds;

	public static Map<String, DataSource> dataSources = new HashMap<String, DataSource>();

	public ConnectionProviderImpl() {
		engine = CFMLEngineFactory.getInstance();
		dbu = engine.getDBUtil();
	}

	@Override
	public void configure(Properties props) throws HibernateException {
		String id = props.getProperty("lucee.datasource.id");
		if (!Util.isEmpty(id)) ds = dataSources.get(id);
		dsn = props.getProperty("lucee.datasource.name");
		user = props.getProperty("lucee.datasource.user");
		pass = props.getProperty("lucee.datasource.password");
	}

	@Override
	public Connection getConnection() throws SQLException {
		PageContext pc = engine.getThreadPageContext();
		DataSource datasource = ds != null ? ds : CommonUtil.getDataSource(pc, dsn, null);

		try {
			if (datasource != null) return dbu.getDatasourceConnection(pc, datasource, user, pass);
			return dbu.getDatasourceConnection(pc, dsn, user, pass);
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
	public void close() throws HibernateException {}

	@Override
	public boolean supportsAggressiveRelease() {
		// nope
		return false;
	}

}
