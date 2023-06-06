package com.ortussolutions.hibernate;

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.hibernate.boot.MetadataSources;
import org.hibernate.boot.registry.StandardServiceRegistryBuilder;
import org.hibernate.cfg.AvailableSettings;
import org.hibernate.cfg.Configuration;
import org.hibernate.service.ServiceRegistry;
import org.hibernate.tool.hbm2ddl.SchemaExport;
import org.hibernate.tool.hbm2ddl.SchemaExport.Action;
import org.hibernate.tool.hbm2ddl.SchemaUpdate;
import org.hibernate.tool.schema.TargetType;
import com.ortussolutions.hibernate.util.CommonUtil;
import com.ortussolutions.hibernate.util.ExceptionUtil;
import com.ortussolutions.hibernate.util.HibernateUtil;
import com.ortussolutions.hibernate.util.ORMConfigurationUtil;

import lucee.commons.io.log.Log;
import lucee.commons.io.res.Resource;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.type.Collection.Key;

public class HibernateSessionFactory {

    /**
     * Generate the database schema based on the configured settings (dropcreate, update, etc.)
     *
     * @param log
     *            Lucee logger object
     * @param configuration
     *            Hibernate configuration
     * @param ds
     *            Datasource
     * @param user
     *            Datasource username
     * @param pass
     *            Datasource password
     * @param data
     *            Session factory data container
     *
     * @throws PageException
     * @throws SQLException
     * @throws IOException
     */
    public static void schemaExport(Log log, Configuration configuration, DataSource ds, String user, String pass,
            SessionFactoryData data) throws PageException, SQLException, IOException {
        ORMConfiguration ormConf = data.getORMConfiguration();

        ServiceRegistry serviceRegistry = new StandardServiceRegistryBuilder()
                .applySettings(configuration.getProperties()).build();

        MetadataSources metadata = new MetadataSources(serviceRegistry);
        EnumSet<TargetType> enumSet = EnumSet.of(TargetType.DATABASE);

        if (ORMConfiguration.DBCREATE_NONE == ormConf.getDbCreate()) {
            configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "none");
            return;
        } else if (ORMConfiguration.DBCREATE_DROP_CREATE == ormConf.getDbCreate()) {
            configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "create");
            SchemaExport export = new SchemaExport();
            export.setHaltOnError(true);
            export.execute(enumSet, Action.BOTH, metadata.buildMetadata());
            HibernateSessionFactory.printError(log, data, export.getExceptions(), false);
            executeSQLScript(ormConf, ds, user, pass);
        } else if (/* ORMConfiguration.DBCREATE_CREATE */3 == ormConf.getDbCreate()) {
            configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "create-only");
            SchemaExport export = new SchemaExport();
            export.setHaltOnError(true);
            export.execute(enumSet, Action.CREATE, metadata.buildMetadata());
            HibernateSessionFactory.printError(log, data, export.getExceptions(), false);
            executeSQLScript(ormConf, ds, user, pass);
        } else if (/* ORMConfiguration.DBCREATE_CREATE_DROP */4 == ormConf.getDbCreate()) {
            configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "create-drop");
            SchemaExport export = new SchemaExport();
            export.setHaltOnError(true);
            export.execute(enumSet, Action.BOTH, metadata.buildMetadata());
            HibernateSessionFactory.printError(log, data, export.getExceptions(), false);
            executeSQLScript(ormConf, ds, user, pass);
        } else if (ORMConfiguration.DBCREATE_UPDATE == ormConf.getDbCreate()) {
            configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "update");
            SchemaUpdate update = new SchemaUpdate();
            update.setHaltOnError(true);
            update.execute(enumSet, metadata.buildMetadata());
            HibernateSessionFactory.printError(log, data, update.getExceptions(), false);
        }
    }

    private static void printError(Log log, SessionFactoryData data, List<Exception> exceptions, boolean throwException)
            throws PageException {
        if (exceptions == null || exceptions.size() == 0)
            return;
        Iterator<Exception> it = exceptions.iterator();
        if (!throwException || exceptions.size() > 1) {
            while (it.hasNext()) {
                log.log(Log.LEVEL_ERROR, "hibernate", it.next());
            }
        }
        if (!throwException)
            return;

        it = exceptions.iterator();
        while (it.hasNext()) {
            throw ExceptionUtil.createException(data, null, it.next());
        }
    }

    private static void executeSQLScript(ORMConfiguration ormConf, DataSource ds, String user, String pass)
            throws SQLException, IOException, PageException {
        Resource sqlScript = ORMConfigurationUtil.getSqlScript(ormConf, ds.getName());
        if (sqlScript != null && sqlScript.isFile()) {
            BufferedReader br = CommonUtil.toBufferedReader(sqlScript, (Charset) null);
            String line;
            StringBuilder sql = new StringBuilder();
            String str;
            Statement stat = null;
            PageContext pc = CFMLEngineFactory.getInstance().getThreadPageContext();
            DatasourceConnection dc = CommonUtil.getDatasourceConnection(pc, ds, user, pass, true);
            try {

                stat = dc.getConnection().createStatement();
                while ((line = br.readLine()) != null) {
                    line = line.trim();
                    if (line.startsWith("//") || line.startsWith("--"))
                        continue;
                    if (line.endsWith(";")) {
                        sql.append(line.substring(0, line.length() - 1));
                        str = sql.toString().trim();
                        if (str.length() > 0)
                            stat.execute(str);
                        sql = new StringBuilder();
                    } else {
                        sql.append(line).append(" ");
                    }
                }
                str = sql.toString().trim();
                if (str.length() > 0) {
                    stat.execute(str);
                }
            } finally {
                CFMLEngineFactory.getInstance().getDBUtil().closeSilent(stat);
                CommonUtil.releaseDatasourceConnection(pc, dc, true);
            }
        }
    }

    /**
     * Generate and return the hibernate XML mapping files for each configured datasource. Most applications will only
     * use a single datasource, but additional ones can be set at the entity (component) level.
     *
     * @param data
     *
     * @return a Map of XML mappings per datasource key.
     */
    public static Map<Key, String> assembleMappingsByDatasource(SessionFactoryData data) {
        Map<Key, String> mappings = new HashMap<Key, String>();
        Iterator<Entry<Key, Map<String, CFCInfo>>> it = data.getCFCs().entrySet().iterator();
        while (it.hasNext()) {
            Entry<Key, Map<String, CFCInfo>> e = it.next();

            Set<String> done = new HashSet<String>();
            StringBuilder mapping = new StringBuilder();
            mapping.append(HBMCreator.getXMLOpen());
            mapping.append("<hibernate-mapping>");
            Iterator<Entry<String, CFCInfo>> _it = e.getValue().entrySet().iterator();
            _it.forEachRemaining(entry -> {
                mapping.append(assembleMappingForCFC(entry.getKey(), entry.getValue(), done, data));
            });
            mapping.append("</hibernate-mapping>");
            mappings.put(e.getKey(), mapping.toString());
        }
        return mappings;
    }

    /**
     * Retrieve an XML mapping string which defines the Hibernate entity mapping for this entity (component) and all
     * subcomponents. (Sub entities, if you will.)
     *
     * @param key
     *            The entity name
     * @param value
     *            The CFCInfo object containing the component and XML mapping
     * @param done
     *            Collection of pre-generated items - helps avoid duplicate mapping generation
     * @param data
     *            Session factory data object of state for the current session factory
     *
     * @return A string of XML for the hibernate mapping. Does NOT include the opening xml tag or doctype, since this
     *         must only repeat once per file, whereas this function iterates recursively over the component and its
     *         children.
     */
    private static String assembleMappingForCFC(String key, CFCInfo value, Set<String> done, SessionFactoryData data) {
        if (done.contains(key))
            return "";
        CFCInfo v;
        StringBuilder mappings = new StringBuilder();
        String ext = value.getCFC().getExtends();
        if (!Util.isEmpty(ext)) {
            try {
                Component parent = data.getEntityByCFCName(ext, false);
                ext = HibernateCaster.getEntityName(parent);
            } catch (Throwable t) {
                if (t instanceof ThreadDeath)
                    throw (ThreadDeath) t;
            }

            ext = HibernateUtil.sanitizeEntityName(CommonUtil.last(ext, ".").trim());
            if (!done.contains(ext)) {
                v = data.getCFC(ext, null);
                if (v != null) {
                    mappings.append(HBMCreator.stripXMLOpenClose(assembleMappingForCFC(ext, v, done, data)));
                }
            }
        }

        mappings.append(HBMCreator.stripXMLOpenClose(value.getXML()));
        done.add(key);
        return mappings.toString();
    }
}
