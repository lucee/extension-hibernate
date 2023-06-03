package org.lucee.extension.orm.hibernate;

import java.io.BufferedReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
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
import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.util.ExceptionUtil;
import org.lucee.extension.orm.hibernate.util.HibernateUtil;
import org.lucee.extension.orm.hibernate.util.ORMConfigurationUtil;

import lucee.commons.io.log.Log;
import lucee.commons.io.res.Resource;
import lucee.commons.io.res.filter.ResourceFilter;
import lucee.loader.engine.CFMLEngine;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.InterfacePage;
import lucee.runtime.Mapping;
import lucee.runtime.Page;
import lucee.runtime.PageContext;
import lucee.runtime.PageSource;
import lucee.runtime.config.Config;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.exp.PageException;
import lucee.runtime.listener.ApplicationContext;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.util.TemplateUtil;

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
            printError(log, data, export.getExceptions(), false);
            executeSQLScript(ormConf, ds, user, pass);
        } else if (/* ORMConfiguration.DBCREATE_CREATE */3 == ormConf.getDbCreate()) {
            configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "create-only");
            SchemaExport export = new SchemaExport();
            export.setHaltOnError(true);
            export.execute(enumSet, Action.CREATE, metadata.buildMetadata());
            printError(log, data, export.getExceptions(), false);
            executeSQLScript(ormConf, ds, user, pass);
        } else if (/* ORMConfiguration.DBCREATE_CREATE_DROP */4 == ormConf.getDbCreate()) {
            configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "create-drop");
            SchemaExport export = new SchemaExport();
            export.setHaltOnError(true);
            export.execute(enumSet, Action.BOTH, metadata.buildMetadata());
            printError(log, data, export.getExceptions(), false);
            executeSQLScript(ormConf, ds, user, pass);
        } else if (ORMConfiguration.DBCREATE_UPDATE == ormConf.getDbCreate()) {
            configuration.setProperty(AvailableSettings.HBM2DDL_AUTO, "update");
            SchemaUpdate update = new SchemaUpdate();
            update.setHaltOnError(true);
            update.execute(enumSet, metadata.buildMetadata());
            printError(log, data, update.getExceptions(), false);
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

            ext = HibernateUtil.id(CommonUtil.last(ext, ".").trim());
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

    /**
     * Load and return persistent entities using the ORM configuration
     *
     * @param pc
     *            Lucee PageContext object
     * @param engine
     *            ORM engine
     * @param ormConf
     *            ORM configuration object.
     *
     * @throws PageException
     */
    public static List<Component> loadComponents(PageContext pc, HibernateORMEngine engine, ORMConfiguration ormConf)
            throws PageException {
        CFMLEngine en = CFMLEngineFactory.getInstance();

        ResourceFilter filter = en.getResourceUtil().getExtensionResourceFilter("cfc", true);
        List<Component> components = new ArrayList<Component>();
        loadComponents(pc, engine, components, ormConf.getCfcLocations(), filter, ormConf);
        return components;
    }

    /**
     * Load persistent entities from the given directory
     *
     * @param pc
     *            Lucee PageContext object
     * @param engine
     *            ORM engine
     * @param components
     *            The current list of components. Any discovered components will be appended to this list.
     * @param res
     *            The directory to search for Components.
     * @param filter
     *            The file filter - probably just a Lucee-fied ".cfc" filter
     * @param ormConf
     *            ORM configuration object.
     *
     * @throws PageException
     */
    private static void loadComponents(PageContext pc, HibernateORMEngine engine, List<Component> components,
            Resource[] reses, ResourceFilter filter, ORMConfiguration ormConf) throws PageException {
        Mapping[] mappings = createFileMappings(pc, reses);
        ApplicationContext ac = pc.getApplicationContext();
        Mapping[] existing = ac.getComponentMappings();
        if (existing == null)
            existing = new Mapping[0];
        try {
            Mapping[] tmp = new Mapping[existing.length + 1];
            for (int i = 1; i < tmp.length; i++) {
                tmp[i] = existing[i - 1];
            }
            ac.setComponentMappings(tmp);
            for (int i = 0; i < reses.length; i++) {
                if (reses[i] != null && reses[i].isDirectory()) {
                    tmp[0] = mappings[i];
                    ac.setComponentMappings(tmp);
                    loadComponents(pc, engine, mappings[i], components, reses[i], filter, ormConf);
                }
            }
        } finally {
            ac.setComponentMappings(existing);
        }
    }

    /**
     * Load persistent entities from the given cfclocation Mapping directory
     *
     * @param pc
     *            Lucee PageContext object
     * @param engine
     *            ORM engine
     * @param cfclocation
     *            Lucee {@link lucee.runtime.Mapping} pointing to a directory where .cfc Components are located.
     * @param components
     *            The current list of components. Any discovered components will be appended to this list.
     * @param res
     *            The directory to search for Components, OR the file to (potentially) import into the Hibernate
     *            configuration.
     * @param filter
     *            The file filter - probably just a Lucee-fied ".cfc" filter
     * @param ormConf
     *            ORM configuration object.
     *
     * @throws PageException
     */
    private static void loadComponents(PageContext pc, HibernateORMEngine engine, Mapping cfclocation,
            List<Component> components, Resource res, ResourceFilter filter, ORMConfiguration ormConf)
            throws PageException {
        if (res == null)
            return;

        if (res.isDirectory()) {
            Resource[] children = res.listResources(filter);

            // first load all files
            for (int i = 0; i < children.length; i++) {
                if (children[i].isFile())
                    loadComponents(pc, engine, cfclocation, components, children[i], filter, ormConf);
            }

            // and then invoke subfiles
            for (int i = 0; i < children.length; i++) {
                if (children[i].isDirectory())
                    loadComponents(pc, engine, cfclocation, components, children[i], filter, ormConf);
            }
        } else if (res.isFile()) {
            if (!HibernateUtil.isApplicationName(res.getName())) {
                try {

                    // MUST still a bad solution
                    PageSource ps = pc.toPageSource(res, null);
                    if (ps == null || ps.getComponentName().indexOf("..") != -1) {
                        PageSource ps2 = null;
                        Resource root = cfclocation.getPhysical();
                        String path = CFMLEngineFactory.getInstance().getResourceUtil().getPathToChild(res, root);
                        if (!Util.isEmpty(path, true)) {
                            ps2 = cfclocation.getPageSource(path);
                        }
                        if (ps2 != null)
                            ps = ps2;
                    }

                    // Page p = ps.loadPage(pc.getConfig());
                    String name = res.getName();
                    name = HibernateUtil.removeExtension(name, name);

                    TemplateUtil tu = CFMLEngineFactory.getInstance().getTemplateUtil();

                    Page p = tu.loadPage(pc, ps, true);
                    if (!(p instanceof InterfacePage)) {
                        Component cfc = tu.loadComponent(pc, p, name, true, true, false, true);
                        if (cfc.isPersistent()) {
                            components.add(cfc);
                        }
                    }
                } catch (PageException e) {
                    if (!ormConf.skipCFCWithError())
                        throw e;
                    // e.printStackTrace();
                }
            }
        }
    }

    /**
     * Create CF mappings for locating persistent entities.
     * <p>
     * Used when importing persistent entities from the configured <code>this.ormsettings.cfclocation</code> array.
     *
     * @param pc
     *            Lucee PageContext
     * @param resources
     *            Array of Resource objects, i.e. a file path
     *
     * @return a Mapping object used to locate a file resource
     */
    public static Mapping[] createFileMappings(PageContext pc, Resource[] resources) {

        Mapping[] mappings = new Mapping[resources.length];
        Config config = pc.getConfig();
        for (int i = 0; i < mappings.length; i++) {
            mappings[i] = CommonUtil.createMapping(config, "/", resources[i].getAbsolutePath());
        }
        return mappings;
    }
}
