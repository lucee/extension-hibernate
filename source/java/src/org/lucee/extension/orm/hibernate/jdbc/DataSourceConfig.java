package org.lucee.extension.orm.hibernate.jdbc;

import lucee.runtime.db.DataSource;

import org.hibernate.cfg.Configuration;

public class DataSourceConfig {

	public final DataSource ds;
	public final Configuration config;

	public DataSourceConfig(DataSource ds, Configuration config) {
		this.ds=ds;
		this.config=config;
	}
}
