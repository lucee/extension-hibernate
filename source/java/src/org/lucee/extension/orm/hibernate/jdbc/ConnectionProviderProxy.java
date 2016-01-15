package org.lucee.extension.orm.hibernate.jdbc;

import java.sql.Connection;
import java.sql.SQLException;

import org.hibernate.engine.jdbc.connections.spi.ConnectionProvider;

public class ConnectionProviderProxy implements ConnectionProvider {

	public static ConnectionProvider provider;


	@Override
	public void closeConnection(Connection arg0) throws SQLException {
		provider.closeConnection(arg0);
	}

	@Override
	public Connection getConnection() throws SQLException {
		return provider.getConnection();
	}

	@Override
	public boolean supportsAggressiveRelease() {
		return provider.supportsAggressiveRelease();
	}

	@Override
	public boolean isUnwrappableAs(Class arg0) {
		return provider.isUnwrappableAs(arg0);
	}

	@Override
	public <T> T unwrap(Class<T> arg0) {
		return provider.unwrap(arg0);
	}

}
