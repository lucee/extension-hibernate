package org.lucee.extension.orm.hibernate.jdbc;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.Properties;

import org.hibernate.HibernateException;
import org.hibernate.cfg.Environment;
import org.hibernate.engine.jdbc.connections.spi.ConnectionProvider;

import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.PageContext;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.exp.PageException;
import lucee.runtime.util.DBUtil;

public class ConnectionProviderImpl implements ConnectionProvider {
	
	private final DBUtil dbu;
	private CFMLEngine engine;
	private String dsn;
	private String user;
	private String pass;
	private String id;

	public ConnectionProviderImpl(){
		engine = CFMLEngineFactory.getInstance();
		dbu=engine.getDBUtil();
	}

	public void configure(Properties props) throws HibernateException {
		dsn=props.getProperty("hibernate.connection.datasource_name");
		id = props.getProperty("hibernate.connection.datasource_id");
		user=props.getProperty(Environment.USER);
		pass=props.getProperty(Environment.PASS);
		
		
		
		System.out.println("dsn:"+dsn);
	}

	@Override
	public Connection getConnection() throws SQLException {
		try {
			PageContext pc = engine.getThreadPageContext();
			return dbu.getDatasourceConnection(pc, dsn, user, pass);
		} catch (PageException pe) {
			throw engine.getExceptionUtil().createPageRuntimeException(pe);
		}
	}

	@Override
	public void closeConnection(Connection conn) throws SQLException {
		if(conn instanceof DatasourceConnection)
			dbu.releaseDatasourceConnection(engine.getThreadConfig(), (DatasourceConnection)conn, false);
		System.out.println("ConnectionProviderImpl.closeconn:"+conn.getClass().getName());
	}

	@Override
	public boolean supportsAggressiveRelease() {
		// nope
		return false;
	}

	@Override
	public boolean isUnwrappableAs(Class arg0) {
		// TODO
		return false;
	}

	@Override
	public <T> T unwrap(Class<T> arg0) {
		// TODO
		return null;
	}

}
