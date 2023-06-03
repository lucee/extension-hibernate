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

import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.util.ORMUtil;

import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Array;
import lucee.runtime.ext.function.BIF;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.engine.CFMLEngine;
/**
 * CFML built-in function to retrieve an array of all ORM entity names.
 */
public class EntityNameArray extends BIF {

    public static Array call(PageContext pc) throws PageException {
        return CommonUtil.toArray(
            ORMUtil.getSession(pc).getEntityNames()
        );
    }

    @Override
    public Object invoke(PageContext pc, Object[] args) throws PageException {
        CFMLEngine engine = CFMLEngineFactory.getInstance();

        if (args.length == 0) return call(pc);

        throw engine.getExceptionUtil().createFunctionException(pc, "entityNameArray", 0, 0, args.length);
    }
}