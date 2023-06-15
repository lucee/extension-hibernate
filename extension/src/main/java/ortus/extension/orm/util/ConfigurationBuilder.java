package ortus.extension.orm.util;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Properties;

import org.hibernate.MappingException;
import org.hibernate.boot.registry.BootstrapServiceRegistry;
import org.hibernate.boot.registry.BootstrapServiceRegistryBuilder;
import org.hibernate.cache.ehcache.internal.EhcacheRegionFactory;
import org.hibernate.cfg.AvailableSettings;
import org.hibernate.cfg.Configuration;
import org.hibernate.cfg.Environment;
import org.hibernate.engine.jdbc.connections.spi.ConnectionProvider;
import ortus.extension.orm.Dialect;
import ortus.extension.orm.SessionFactoryData;
import ortus.extension.orm.event.EventListenerIntegrator;
import ortus.extension.orm.jdbc.ConnectionProviderImpl;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import lucee.commons.io.log.Log;
import lucee.commons.io.res.Resource;
import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.db.DataSource;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMConfiguration;

public class ConfigurationBuilder {
    /**
     * Store username and password for the configured datasource
     */
    private HashMap<String, String> datasourceCreds = new HashMap<>();

    /**
     * The event listener which will proxy Hibernate's Java events to the eventHandler CFC.
     */
    private EventListenerIntegrator eventListener;

    /**
     * The connection provider Hibernate should use if it needs to aquire its own database connections
     */
    private ConnectionProvider connectionProvider;

    /**
     * Hibernate Configuration object
     */
    private Configuration configuration;

    /**
     * Application ORM configuration set in the Application.cfc's <code>this.ormSettings</code>.
     */
    private ORMConfiguration ormConf;

    /**
     * The extension {@link ortus.extension.orm.SessionFactoryData}
     */
    private SessionFactoryData data;

    /**
     * Application name, used as a unique key to identify a configuration set.
     */
    private String applicationName;

    /**
     * Datasource to operate on
     */
    private DataSource datasource;

    /**
     * Mapping XML document as a string
     */
    private String xmlMappings;

    /**
     * Lucee logger object, configured for the ORM log
     */
    private Log log;

    /**
     * Build out Hibernate configuration using the application's `this.ormSettings`, datasource, and generated mappings.
     *
     * @return Hibernate Configuration object
     *
     * @throws SQLException
     * @throws IOException
     * @throws PageException
     */
    public Configuration build() throws SQLException, IOException, PageException {
        BootstrapServiceRegistry bootstrapRegistry = new BootstrapServiceRegistryBuilder()
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

        // ormConfig
        Resource conf = ormConf.getOrmConfig();
        if (conf != null) {
            try {
                Document doc = CommonUtil.toDocument(conf, null);
                configuration.configure(doc);
            } catch (Exception e) {
                log.log(Log.LEVEL_ERROR, "hibernate", e);

            }
        }

        try {
            configuration.addInputStream(new ByteArrayInputStream(xmlMappings.getBytes("UTF-8")));
        } catch (MappingException me) {
            throw ExceptionUtil.createException(data, null, me);
        }

        configuration.setProperty(AvailableSettings.FLUSH_BEFORE_COMPLETION, "false")
                .setProperty(AvailableSettings.ALLOW_UPDATE_OUTSIDE_TRANSACTION, "true")
                .setProperty(AvailableSettings.AUTO_CLOSE_SESSION, "false")
                // Enable Hibernate's current session context
                .setProperty(AvailableSettings.CURRENT_SESSION_CONTEXT_CLASS, "thread")
                // Echo all executed SQL to stdout
                .setProperty(AvailableSettings.SHOW_SQL, Boolean.toString(ormConf.logSQL()))
                // formatting of SQL logged to the console
                .setProperty(AvailableSettings.FORMAT_SQL, Boolean.toString(ormConf.logSQL()))
                // Specifies whether secondary caching should be enabled
                .setProperty(AvailableSettings.USE_SECOND_LEVEL_CACHE, Boolean.toString(ormConf.secondaryCacheEnabled()))
                // Drop and re-create the database schema on startup
                .setProperty("hibernate.exposeTransactionAwareSessionFactory", "false")
                // .setProperty("hibernate.hbm2ddl.auto", "create")
                .setProperty(AvailableSettings.DEFAULT_ENTITY_MODE, "dynamic-map");

        if (ormConf.secondaryCacheEnabled()) {
            String cacheProvider = ormConf.getCacheProvider();

            if (cacheProvider != null ){
                if( cacheProvider.equalsIgnoreCase("ehcache") ){
                    Resource cacheConfig = buildEHCacheConfig();
                    configuration.setProperty(AvailableSettings.CACHE_PROVIDER_CONFIG, cacheConfig.getAbsolutePath());
                }

                addProperty(AvailableSettings.CACHE_REGION_FACTORY, getCacheRegionFactory(cacheProvider));
            }

            configuration.setProperty(AvailableSettings.USE_QUERY_CACHE, "true");
        }

        return configuration;
    }

    private Class<?> getCacheRegionFactory(String cacheProvider) throws PageException{
        String unsupportedCacheProvider = "Unsupported ORM configuration: cache provider " + cacheProvider + " is no longer supported in Hibernate 4+.";
        switch (cacheProvider.toLowerCase()) {
            case "jbosscache":
                throw ExceptionUtil.createException(unsupportedCacheProvider);
            case "hashtable":
                throw ExceptionUtil.createException(unsupportedCacheProvider);
            case "swarmcache":
                throw ExceptionUtil.createException(unsupportedCacheProvider);
            case "OSCache":
                throw ExceptionUtil.createException(unsupportedCacheProvider);
            case "infinispan":
                // https://mvnrepository.com/artifact/org.infinispan/infinispan-hibernate-cache-spi
            case "ehcache":
            default:
                return EhcacheRegionFactory.class;
        }
    }

    private Resource buildEHCacheConfig() throws IOException, PageException {
        Resource cacheConfig;
        Resource cc = ormConf.getCacheConfig();
        CFMLEngine eng = CFMLEngineFactory.getInstance();
        String varName = eng.getCastUtil().toVariableName(applicationName, applicationName);
        String xml;
        if (cc == null || !cc.isFile()) {
            cacheConfig = eng.getResourceUtil().getTempDirectory().getRealResource("ehcache/" + varName + ".xml");
            xml = createEHConfigXML(varName);
        }
        // we need to change or set the name
        else {
            String b64 = varName + eng.getSystemUtil().hash64b(CommonUtil.toString(cc, (Charset) null));
            cacheConfig = eng.getResourceUtil().getTempDirectory().getRealResource("ehcache/" + b64 + ".xml");
            Document doc = CommonUtil.toDocument(cc, null);
            Element root = doc.getDocumentElement();
            root.setAttribute("name", b64);

            xml = XMLUtil.toString(root);
        }
        if (!cacheConfig.isFile()) {
            cacheConfig.getParentResource().mkdirs();
            eng.getIOUtil().write(cacheConfig, xml, false, null);
        }
        return cacheConfig;
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

    public ConfigurationBuilder withApplicationName(String applicationName) {
        this.applicationName = applicationName;
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

    /**
     * Generate an XML-format ehcache config file for the given cache name
     * <p>
     * TODO: Add support for diskSpoolBufferSizeMB and clearOnFlush, added in ACF 9.0.1
     *
     * @param cacheName
     *            Name of the cache
     *
     * @return XML string with formatting and line breaks
     */
    private String createEHConfigXML(String cacheName) {
        return new StringBuilder().append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>").append("<ehcache")
                .append("    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"")
                .append("    xsi:noNamespaceSchemaLocation=\"ehcache.xsd\"")
                .append("    updateCheck=\"true\" name=\"" + cacheName + "\">")
                .append("    <diskStore path=\"java.io.tmpdir\"/>").append("    <defaultCache")
                .append("            maxElementsInMemory=\"10000\"").append("            eternal=\"false\"")
                .append("            timeToIdleSeconds=\"120\"").append("            timeToLiveSeconds=\"120\"")
                .append("            maxElementsOnDisk=\"10000000\"")
                .append("            diskExpiryThreadIntervalSeconds=\"120\"")
                .append("            memoryStoreEvictionPolicy=\"LRU\">")
                .append("        <persistence strategy=\"localTempSwap\"/>").append("    </defaultCache>")
                .append("</ehcache>").toString();
    }
}
