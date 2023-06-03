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
import lucee.runtime.ext.function.BIF;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.engine.CFMLEngine;

/**
 * Merge a detached or transient entity into the Hibernate session.
 */
public class EntityMerge extends BIF {

    public static Object call(PageContext pc, Object obj) throws PageException {
        ORMSession session = ORMUtil.getSession(pc);
        return session.merge(pc, obj);
    }

    @Override
    public Object invoke(PageContext pc, Object[] args) throws PageException {
        CFMLEngine engine = CFMLEngineFactory.getInstance();

        if (args.length == 1) return call(pc, args[0]);

        throw engine.getExceptionUtil().createFunctionException(pc, "EntityMerge", 1, 1, args.length);
    }
}