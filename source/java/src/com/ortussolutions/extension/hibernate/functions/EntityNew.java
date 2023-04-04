/**
 *
 * Copyright (c) 2015, Lucee Association Switzerland. All rights reserved.
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
 **/
package org.lucee.extension.orm.functions;

import com.ortussolutions.hibernate.util.CommonUtil;
import com.ortussolutions.hibernate.util.ORMUtil;

import java.util.Iterator;
import java.util.Map.Entry;

import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMSession;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.type.Struct;
import lucee.runtime.type.UDF;

public class EntityNew {

    public static Object call(PageContext pc, String name) throws PageException {
        return call(pc, name, null);
    }

    public static Object call(PageContext pc, String name, Struct properties) throws PageException {
        ORMSession session = ORMUtil.getSession(pc);
        if (properties == null)
            return session.create(pc, name);

        Component entity = session.create(pc, name);
        setPropeties(pc, entity, properties, false);
        return entity;

    }

    public static void setPropeties(PageContext pc, Component c, Struct properties, boolean ignoreNotExisting)
            throws PageException {
        if (properties == null)
            return;

        // argumentCollection
        if (properties.size() == 1 && properties.containsKey(CommonUtil.createKey("argumentCollection"))
                && !c.containsKey(CommonUtil.createKey("setArgumentCollection"))) {
            properties = CommonUtil.toStruct(properties.get(CommonUtil.createKey("argumentCollection")));
        }

        Iterator<Entry<Key, Object>> it = properties.entryIterator();
        Entry<Key, Object> e;
        while (it.hasNext()) {
            e = it.next();
            Key funcName = CommonUtil.createKey("set" + e.getKey().getString());
            if (ignoreNotExisting) {
                if (c.get(funcName, null) instanceof UDF)
                    c.call(pc, funcName, new Object[] { e.getValue() });
            } else {
                c.call(pc, funcName, new Object[] { e.getValue() });
            }
        }
    }
}