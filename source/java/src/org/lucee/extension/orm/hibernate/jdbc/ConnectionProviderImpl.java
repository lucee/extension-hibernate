package org.opencfmlfoundation.extension.orm.hibernate.jdbc;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.Properties;

import org.hibernate.HibernateException;
import org.hibernate.cfg.Environment;
import org.hibernate.connection.ConnectionProvider;

import railo.loader.engine.CFMLEngine;
import railo.loader.engine.CFMLEngineFactory;
import railo.loader.util.Util;
import railo.runtime.PageContext;
import railo.runtime.db.DatasourceConnection;
import railo.runtime.exp.PageException;
import railo.runtime.util.DBUtil;

public class ConnectionProviderImpl implements ConnectionProvider {
	
	private final DBUtil dbu;
	private CFMLEngine engine;
	private String dsn;
	private String user;
	private String pass;
	private String id;

	public ConnectionProviderImpl(){
		
		System.out.println("ConnectionProviderImpl<init>");
		engine = CFMLEngineFactory.getInstance();
		dbu=engine.getDBUtil();
	}

	@Override
	public void configure(Properties props) throws HibernateException {
		System.out.println("ConnectionProviderImpl.config");
		
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
	public void close() throws HibernateException {
		System.out.println("ConnectionProviderImpl.close");
	}

	@Override
	public boolean supportsAggressiveRelease() {
		// nope
		return false;
	}

}
