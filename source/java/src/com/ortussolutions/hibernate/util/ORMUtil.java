/**
 * Copyright (c) 2015, Lucee Association Switzerland. All rights reserved.
 * Copyright (c) 2015, Lucee Assosication Switzerland
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
package com.ortussolutions.hibernate.util;

import java.util.ArrayList;

import lucee.runtime.orm.ORMSession;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
// import lucee.runtime.PageContextImpl;
import lucee.runtime.component.Property;
import lucee.runtime.orm.ORMEngine;
import lucee.runtime.db.DataSource;
// import lucee.runtime.engine.ThreadLocalPageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.type.Struct;
import lucee.loader.util.Util;

public class ORMUtil {

    public static final Key PROPS_FIELDTYPE = CommonUtil.createKey("fieldtype");
    public static final Key PROPS_DATASOURCE = CommonUtil.createKey("datasource");

    public static final String DELIMITER = new String(".");

    public static ORMSession getSession(PageContext pc) throws PageException {
        return getSession(pc, true);
    }

    public static ORMSession getSession(PageContext pc, boolean create) throws PageException {
        return pc.getORMSession(create);
    }

    public static ORMEngine getEngine(PageContext pc) throws PageException {
        return pc.getConfig().getORMEngine(pc);
    }

    /**
     *
     * @param pc
     * @param force
     *            if set to false the engine is on loaded when the configuration has changed
     *
     * @throws PageException
     */
    public static ORMEngine resetEngine(PageContext pc, boolean force) throws PageException {
        ORMEngine e = getEngine(pc);
        e.reload(pc, force);
        return e;
    }

    public static Property[] getIds(Property[] props) {
        ArrayList<Property> ids = new ArrayList<Property>();
        for (int y = 0; y < props.length; y++) {
            String fieldType = CommonUtil.toString(props[y].getDynamicAttributes().get(PROPS_FIELDTYPE, null), null);
            Character delimiterChar = Character.valueOf(DELIMITER.charAt(0));
            if ("id".equalsIgnoreCase(fieldType)
                    || CommonUtil.listFindNoCaseIgnoreEmpty(fieldType, "id", delimiterChar) != -1)
                ids.add(props[y]);
        }

        // no id field defined
        if (ids.size() == 0) {
            String fieldType;
            for (int y = 0; y < props.length; y++) {
                fieldType = CommonUtil.toString(props[y].getDynamicAttributes().get(PROPS_FIELDTYPE, null), null);
                if (Util.isEmpty(fieldType, true) && props[y].getName().equalsIgnoreCase("id")) {
                    ids.add(props[y]);
                    props[y].getDynamicAttributes().setEL(PROPS_FIELDTYPE, "id");
                }
            }
        }

        // still no id field defined
        if (ids.size() == 0 && props.length > 0) {
            String owner = props[0].getOwnerName();
            if (!Util.isEmpty(owner))
                owner = CommonUtil.last(owner, DELIMITER).trim();

            String fieldType;
            if (!Util.isEmpty(owner)) {
                String id = owner + "id";
                for (int y = 0; y < props.length; y++) {
                    fieldType = CommonUtil.toString(props[y].getDynamicAttributes().get(PROPS_FIELDTYPE, null), null);
                    if (Util.isEmpty(fieldType, true) && props[y].getName().equalsIgnoreCase(id)) {
                        ids.add(props[y]);
                        props[y].getDynamicAttributes().setEL(PROPS_FIELDTYPE, "id");
                    }
                }
            }
        }
        return ids.toArray(new Property[ids.size()]);
    }

    public static Object getPropertyValue(Component cfc, String name, Object defaultValue) {
        Property[] props = getProperties(cfc);

        for (int i = 0; i < props.length; i++) {
            if (!props[i].getName().equalsIgnoreCase(name))
                continue;
            return cfc.getComponentScope().get(CommonUtil.createKey(name), null);
        }
        return defaultValue;
    }

    private static Property[] getProperties(Component cfc) {
        return cfc.getProperties(true, true, false, false);
    }

    public static boolean isRelated(Property prop) {
        String fieldType = CommonUtil.toString(prop.getDynamicAttributes().get(PROPS_FIELDTYPE, "column"), "column");
        if (Util.isEmpty(fieldType, true))
            return false;
        fieldType = fieldType.toLowerCase().trim();

        if ("one-to-one".equals(fieldType))
            return true;
        if ("many-to-one".equals(fieldType))
            return true;
        if ("one-to-many".equals(fieldType))
            return true;
        if ("many-to-many".equals(fieldType))
            return true;
        return false;
    }

    public static Struct convertToSimpleMap(String paramsStr) {
        paramsStr = paramsStr.trim();
        if (!CommonUtil.startsWith(paramsStr, '{') || !CommonUtil.endsWith(paramsStr, '}'))
            return null;

        paramsStr = paramsStr.substring(1, paramsStr.length() - 1);
        String items[] = CommonUtil.toStringArray(paramsStr, DELIMITER);

        Struct params = CommonUtil.createStruct();
        String arr$[] = items;
        int index;
        for (int i = 0; i < arr$.length; i++) {
            String pair = arr$[i];
            index = pair.indexOf('=');
            if (index == -1)
                return null;

            params.setEL(CommonUtil.createKey(deleteQuotes(pair.substring(0, index).trim()).trim()),
                    deleteQuotes(pair.substring(index + 1).trim()));
        }

        return params;
    }

    private static String deleteQuotes(String str) {
        if (Util.isEmpty(str, true))
            return "";
        char first = str.charAt(0);
        if ((first == '\'' || first == '"') && CommonUtil.endsWith(str, first))
            return str.substring(1, str.length() - 1);
        return str;
    }

    public static DataSource getDefaultDataSource(PageContext pc) throws PageException {
        // pc = ThreadLocalPageContext.get(pc);
        Object datasource = pc.getApplicationContext().getORMDataSource();

        if (datasource == null) {
            throw ExceptionUtil.createException("missing datasource definition in Application.cfc/cfapplication");
        }
        return datasource instanceof DataSource ? (DataSource) datasource
                : pc.getDataSource(CommonUtil.toString(datasource));
    }

    public static DataSource getDefaultDataSource(PageContext pc, DataSource defaultValue) {
        // pc = ThreadLocalPageContext.get(pc);
        Object datasource = pc.getApplicationContext().getORMDataSource();
        if (datasource == null)
            return defaultValue;
        try {
            return getDefaultDataSource(pc);
        } catch (PageException e) {
            return defaultValue;
        }
    }

    public static DataSource getDataSource(PageContext pc, String dsn, DataSource defaultValue) {
        if (Util.isEmpty(dsn, true))
            return ORMUtil.getDefaultDataSource(pc, defaultValue);
        return pc.getDataSource(dsn.trim(), defaultValue);
    }

    public static DataSource getDataSource(PageContext pc, String dsn) throws PageException {
        if (Util.isEmpty(dsn, true))
            return ORMUtil.getDefaultDataSource(pc);
        return pc.getDataSource(dsn.trim());
    }

    /**
     * if the given component has defined a datasource in the meta data, lucee is returning this datasource, otherwise
     * the default orm datasource is returned
     *
     * @param pc
     *            Lucee PageContext object
     * @param cfc
     *            a Lucee / CFML Component object
     *
     * @return Lucee Datasource object
     */
    public static DataSource getDataSource(PageContext pc, Component cfc, DataSource defaultValue) {
        // pc = ThreadLocalPageContext.get(pc);

        // datasource defined with cfc
        try {
            Struct meta = cfc.getMetaData(pc);
            String datasourceName = CommonUtil.toString(meta.get(PROPS_DATASOURCE, null), null);
            if (!Util.isEmpty(datasourceName, true)) {
                DataSource ds = pc.getDataSource(datasourceName, null);
                if (ds != null)
                    return ds;
            }
        } catch (Throwable t) {
            ExceptionUtil.rethrowIfNecessary(t);
        }

        return getDefaultDataSource(pc, defaultValue);
    }

    /**
     * if the given component has defined a datasource in the meta data, lucee is returning this datasource, otherwise
     * the default orm datasource is returned
     *
     * @param pc
     *            Lucee PageContext object
     * @param cfc
     *            a Lucee / CFML Component object
     *
     * @return Lucee Datasource object
     *
     * @throws PageException
     */
    public static DataSource getDataSource(PageContext pc, Component cfc) throws PageException {
        // pc = ThreadLocalPageContext.get(pc);

        // datasource defined with cfc
        Struct meta = cfc.getMetaData(pc);
        String datasourceName = CommonUtil.toString(meta.get(PROPS_DATASOURCE, null), null);
        if (!Util.isEmpty(datasourceName, true)) {
            return pc.getDataSource(datasourceName);
        }

        return getDefaultDataSource(pc);
    }

    public static String getDataSourceName(PageContext pc, Component cfc) throws PageException {
        // pc = ThreadLocalPageContext.get(pc);

        // datasource defined with cfc
        Struct meta = cfc.getMetaData(pc);
        String datasourceName = CommonUtil.toString(meta.get(PROPS_DATASOURCE, null), null);
        if (!Util.isEmpty(datasourceName, true)) {
            return datasourceName.trim();
        }
        return getDefaultDataSource(pc).getName();
    }

    public static String getDataSourceName(PageContext pc, Component cfc, String defaultValue) {
        // pc = ThreadLocalPageContext.get(pc);

        // datasource defined with cfc
        Struct meta = null;
        try {
            meta = cfc.getMetaData(pc);
            String datasourceName = CommonUtil.toString(meta.get(PROPS_DATASOURCE, null), null);
            if (!Util.isEmpty(datasourceName, true)) {
                return datasourceName.trim();
            }
        } catch (PageException e) {
        }

        DataSource ds = getDefaultDataSource(pc, null);
        if (ds != null)
            return ds.getName();
        return defaultValue;
    }
}