package org.lucee.extension.orm.hibernate.util;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Properties;

import org.hibernate.MappingException;
import org.hibernate.boot.registry.BootstrapServiceRegistry;
import org.hibernate.boot.registry.BootstrapServiceRegistryBuilder;
import org.hibernate.boot.registry.classloading.internal.ClassLoaderServiceImpl;
import org.hibernate.boot.registry.classloading.internal.TcclLookupPrecedence;
import org.hibernate.cache.jcache.internal.JCacheRegionFactory;
import org.hibernate.cfg.AvailableSettings;
import org.hibernate.cfg.Configuration;
import org.hibernate.cfg.Environment;
import org.hibernate.engine.jdbc.connections.spi.ConnectionProvider;
import org.lucee.extension.orm.hibernate.Dialect;
import org.lucee.extension.orm.hibernate.SessionFactoryData;
import org.lucee.extension.orm.hibernate.event.EventListenerIntegrator;
import org.lucee.extension.orm.hibernate.jdbc.ConnectionProviderImpl;

import lucee.commons.io.log.Log;
import lucee.commons.io.res.Resource;
import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.db.DataSource;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMConfiguration;

public class ConfigurationBuilder {
    private HashMap<String, String> datasourceCreds = new HashMap<>();
    private EventListenerIntegrator eventListener;
    private ConnectionProvider connectionProvider;
    private Configuration configuration;
    private ORMConfiguration ormConf;
    private SessionFactoryData data;
    private DataSource datasource;
    private String xmlMappings;
    private boolean formatSQL;
    private Log log;

    /**
     * Build out Hibernate configuration using the application's {@code this.ormSettings}, datasource, and generated mappings.
     * Use the builder setter methods to configure log, mappings, datasource, credentials, data, and application name before calling.
     *
     * @return Hibernate Configuration object
     *
     * @throws SQLException
     * @throws IOException
     * @throws PageException
     */
    public Configuration build() throws SQLException, IOException, PageException {
        // LDEV-6390 follow-up: don't pin the Hibernate-extension bundle classloader.
        // new ClassLoaderServiceImpl() (no-args) calls ClassLoaderServiceImpl.class.getClassLoader()
        // which is the Felix BundleClassLoader. Pinning that loader means cached refs survive bundle
        // refresh but their wiring goes invalid → "bundle wiring no longer valid" on subsequent ops.
        // Match Hibernate's default instead (empty providedClassLoaders, TCCL fallback) so lookups
        // dynamically route through Lucee's EnvClassLoader → current OSGi wiring.
        BootstrapServiceRegistry bootstrapRegistry = new BootstrapServiceRegistryBuilder()
                .applyClassLoaderService(new CachingClassLoaderService(
                        new ClassLoaderServiceImpl(java.util.Collections.emptyList(), TcclLookupPrecedence.AFTER)))
                .applyIntegrator(this.eventListener).build();
        this.configuration = new Configuration(bootstrapRegistry);

        if (datasource != null) {
            String dialect = null;
            String tmpDialect = ORMConfigurationUtil.getDialect(ormConf, datasource.getName());
            if (!Util.isEmpty(tmpDialect))
                dialect = Dialect.getDialect(tmpDialect);
            if (dialect != null && !Util.isEmpty(dialect)) {
                configuration.setProperty(AvailableSettings.DIALECT, dialect);
            }

            String catalog = ORMConfigurationUtil.getCatalog(ormConf, datasource.getName());
            String schema = ORMConfigurationUtil.getSchema(ormConf, datasource.getName());

            if (!Util.isEmpty(catalog)) {
                configuration.setProperty(AvailableSettings.DEFAULT_CATALOG, catalog);
            }
            if (!Util.isEmpty(schema)) {
                configuration.setProperty(AvailableSettings.DEFAULT_SCHEMA, schema);
            }

            if (this.connectionProvider == null) {
                this.withConnectionProvider(new ConnectionProviderImpl(datasource, datasourceCreds.get("USERNAME"),
                        datasourceCreds.get("PASSWORD")));
            }

            addProperty(Environment.CONNECTION_PROVIDER, this.connectionProvider);
        }

        // Cache provider — JCache (JSR-107) via Caffeine. Replaces EHCache 2 (gone in
         // Hibernate 7). The legacy "EHCache" cacheProvider value is accepted as an
         // alias and routed to Caffeine; user-supplied ehcache.xml configs (ormSettings.cacheConfig)
         // are no longer honored — see h73-cache-provider-status.md.
        String cacheProvider = ormConf.getCacheProvider();
        if (!Util.isEmpty(cacheProvider) && "EHCache".equalsIgnoreCase(cacheProvider) && log != null) {
            log.log(Log.LEVEL_WARN, "hibernate",
                    "ormSettings.cacheProvider [EHCache] is a legacy alias and now routes to Caffeine via JCache; "
                            + "update your config to [JCache] to silence this warning. "
                            + "Custom ehcache.xml configs are no longer supported.");
        }

        // ormConfig — hibernate.cfg.xml-format file. Hibernate 7 dropped configure(Document); only
        // String / URL / File overloads remain. If the Lucee Resource is file-backed we pass directly;
        // otherwise (S3 / RAM / etc.) we materialize to a temp file so configure(File) works uniformly.
        Resource conf = ormConf.getOrmConfig();
        if (conf != null) {
            try {
                File configFile;
                if (conf instanceof File) {
                    configFile = (File) conf;
                }
                else {
                    CFMLEngine eng = CFMLEngineFactory.getInstance();
                    Resource temp = eng.getResourceUtil().getTempDirectory().getRealResource(
                            "hibernate-orm-config-" + System.nanoTime() + ".xml");
                    eng.getIOUtil().copy(conf, temp);
                    if (!(temp instanceof File)) throw new IOException("Lucee temp resource is not file-backed [" + temp.getClass().getName() + "]");
                    configFile = (File) temp;
                }
                configuration.configure(configFile);
            } catch (Exception e) {
                log.log(Log.LEVEL_ERROR, "hibernate", e);
            }
        }

        try {
            configuration.addInputStream(new ByteArrayInputStream(xmlMappings.getBytes("UTF-8")));
        } catch (MappingException me) {
            throw ExceptionUtil.createException(data, null, me);
        }

        // Disable Hibernate's built-in nullability check — our EventListenerIntegrator
        // handles it in onPreInsert/onPreUpdate AFTER entity event listeners have had
        // a chance to set missing values (e.g. preInsert setting a null password).
        configuration.setProperty(AvailableSettings.CHECK_NULLABILITY, "false");

        configuration.setProperty(AvailableSettings.FLUSH_BEFORE_COMPLETION, "false")

                .setProperty(AvailableSettings.ALLOW_UPDATE_OUTSIDE_TRANSACTION, "true")

                .setProperty(AvailableSettings.AUTO_CLOSE_SESSION, "false");

        // Enable Hibernate's current session context
        configuration.setProperty(AvailableSettings.CURRENT_SESSION_CONTEXT_CLASS, "thread")

                // SQL logging is handled by the JBoss Logging bridge, not stdout
                .setProperty(AvailableSettings.SHOW_SQL, "false")
                // Pretty-print SQL in the log (has a performance cost per statement)
                .setProperty(AvailableSettings.FORMAT_SQL, formatSQL ? "true" : "false")
                // Specifies whether secondary caching should be enabled
                .setProperty(AvailableSettings.USE_SECOND_LEVEL_CACHE,
                        ormConf.secondaryCacheEnabled() ? "true" : "false")
                .setProperty("hibernate.exposeTransactionAwareSessionFactory", "false");

        if (ormConf.secondaryCacheEnabled()) {
            // Hibernate's JCache adapter; Caffeine is the JSR-107 provider on the classpath.
            // Defaults (max 10000 entries, 120s TTL/TTI) live in classpath:reference.conf
            // under caffeine.jcache.default.
            addProperty(AvailableSettings.CACHE_REGION_FACTORY, JCacheRegionFactory.class);
            configuration.setProperty("hibernate.javax.cache.provider",
                    "com.github.benmanes.caffeine.jcache.spi.CaffeineCachingProvider");
            configuration.setProperty(AvailableSettings.USE_QUERY_CACHE, "true");
        }

        return configuration;
    }

    public ConfigurationBuilder withSessionFactoryData(SessionFactoryData data) {
        this.data = data;
        return this;
    }

    public ConfigurationBuilder withEventListener(EventListenerIntegrator eventListener) {
        this.eventListener = eventListener;
        return this;
    }

    public ConfigurationBuilder withORMConfig(ORMConfiguration ormConf) {
        this.ormConf = ormConf;
        return this;
    }

    public ConfigurationBuilder withLog(Log log) {
        this.log = log;
        return this;
    }

    public ConfigurationBuilder withDatasource(DataSource datasource) {
        this.datasource = datasource;
        return this;
    }

    public ConfigurationBuilder withDatasourceCreds(String user, String pass) {
        this.datasourceCreds.put("USERNAME", user);
        this.datasourceCreds.put("PASSWORD", pass);
        return this;
    }

    public ConfigurationBuilder withXMLMappings(String xmlMappings) {
        this.xmlMappings = xmlMappings;
        return this;
    }

    public ConfigurationBuilder withFormatSQL(boolean formatSQL) {
        this.formatSQL = formatSQL;
        return this;
    }

    public ConfigurationBuilder withConnectionProvider(ConnectionProvider connectionProvider) {
        this.connectionProvider = connectionProvider;
        return this;
    }

    /**
     * Set a complex property on the provided Hibernate Configuration object.
     *
     * @param configuration
     *            Hibernate configuration on which to add a property
     * @param name
     *            New setting / property name
     * @param value
     *            Any value or object, like a {@link ConnectionProviderImpl} instance
     */
    private void addProperty(String name, Object value) {
        Properties props = new Properties();
        props.put(name, value);
        configuration.addProperties(props);
    }

}
