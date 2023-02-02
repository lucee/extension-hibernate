/**
 *
 * Copyright (c) 2014, the Railo Company Ltd. All rights reserved.
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

import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.util.ORMUtil;

import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMSession;
import lucee.runtime.type.Struct;

public class EntityLoad {

    public static Object call(PageContext pc, String name) throws PageException {

        ORMSession session = ORMUtil.getSession(pc);
        return session.loadAsArray(pc, name, CommonUtil.createStruct());
    }

    public static Object call(PageContext pc, String name, Object idOrFilter) throws PageException {
        return call(pc, name, idOrFilter, Boolean.FALSE);
    }

    public static Object call(PageContext pc, String name, Object idOrFilter, Object uniqueOrOptions)
            throws PageException {
        ORMSession session = ORMUtil.getSession(pc);

        // id
        if (CommonUtil.isSimpleValue(idOrFilter)) {
            // id,unique
            if (CommonUtil.isCastableToBoolean(uniqueOrOptions)) {
                // id,unique=true
                if (CommonUtil.toBooleanValue(uniqueOrOptions))
                    return session.load(pc, name, CommonUtil.toString(idOrFilter));
                // id,unique=false
                return session.loadAsArray(pc, name, CommonUtil.toString(idOrFilter));
            } else if (CommonUtil.isString(uniqueOrOptions)) {
                return session.loadAsArray(pc, name, CommonUtil.toString(idOrFilter),
                        CommonUtil.toString(uniqueOrOptions));
            }

            // id,options
            return session.loadAsArray(pc, name, CommonUtil.toString(idOrFilter));
        }

        // filter,[unique|sortorder]
        if (CommonUtil.isSimpleValue(uniqueOrOptions)) {
            // filter,unique
            if (CommonUtil.isBoolean(uniqueOrOptions)) {
                if (CommonUtil.toBooleanValue(uniqueOrOptions))
                    return session.load(pc, name, CommonUtil.toStruct(idOrFilter));
                return session.loadAsArray(pc, name, CommonUtil.toStruct(idOrFilter));
            }
            // filter,sortorder
            return session.loadAsArray(pc, name, CommonUtil.toStruct(idOrFilter), (Struct) null,
                    CommonUtil.toString(uniqueOrOptions));
        }
        // filter,options
        return session.loadAsArray(pc, name, CommonUtil.toStruct(idOrFilter), CommonUtil.toStruct(uniqueOrOptions));
    }

    public static Object call(PageContext pc, String name, Object filter, Object order, Object options)
            throws PageException {
        ORMSession session = ORMUtil.getSession(pc);
        return session.loadAsArray(pc, name, CommonUtil.toStruct(filter), CommonUtil.toStruct(options),
                CommonUtil.toString(order));
    }
}