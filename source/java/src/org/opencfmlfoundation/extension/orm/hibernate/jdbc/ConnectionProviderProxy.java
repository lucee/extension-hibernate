package org.opencfmlfoundation.extension.orm.hibernate.jdbc;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

import org.hibernate.HibernateException;
import org.hibernate.connection.ConnectionProvider;

public class ConnectionProviderProxy implements ConnectionProvider {

	public static ConnectionProvider provider;

	@Override
	public void close() throws HibernateException {
		provider.close();
	}

	@Override
	public void closeConnection(Connection arg0) throws SQLException {
		provider.closeConnection(arg0);
	}

	@Override
	public void configure(Properties arg0) throws HibernateException {
		provider.configure(arg0);
	}

	@Override
	public Connection getConnection() throws SQLException {
		return provider.getConnection();
	}

	@Override
	public boolean supportsAggressiveRelease() {
		return provider.supportsAggressiveRelease();
	}

}
