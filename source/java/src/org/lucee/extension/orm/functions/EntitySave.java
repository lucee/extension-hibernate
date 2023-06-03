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

import org.lucee.extension.orm.hibernate.util.ORMUtil;

import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMSession;
import lucee.runtime.util.Cast;
import lucee.runtime.ext.function.BIF;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.engine.CFMLEngine;

/**
 * CFML built-in function to persist an entity to the database.
 */
public class EntitySave extends BIF {

    public static String call(PageContext pc, Object obj) throws PageException {
        return call(pc, obj, false);
    }

    public static String call(PageContext pc, Object obj, boolean forceInsert) throws PageException {
        ORMSession session = ORMUtil.getSession(pc);
        session.save(pc, obj, forceInsert);
        return null;
    }

    @Override
    public Object invoke(PageContext pc, Object[] args) throws PageException {
        CFMLEngine engine = CFMLEngineFactory.getInstance();
        Cast cast = engine.getCastUtil();

        if (args.length == 1) return call(pc, args[0]);
        if (args.length == 2) return call(pc, args[0], cast.toBoolean(args[1]));

        throw engine.getExceptionUtil().createFunctionException(pc, "EntitySave", 1, 2, args.length);
    }
}