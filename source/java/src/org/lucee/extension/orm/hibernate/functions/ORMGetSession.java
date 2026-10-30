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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library. If not, see <http://www.gnu.org/licenses/>.
 *
 **/
package org.lucee.extension.orm.hibernate.functions;

import org.hibernate.Session;
import org.lucee.extension.orm.hibernate.compat.CompatSessionWrapper;
import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.util.ORMUtil;

import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.ext.function.BIF;

public class ORMGetSession extends BIF {

	private static final int	MIN_ARGUMENTS		= 0;
	private static final int	MAX_ARGUMENTS		= 0;

	private static final long	serialVersionUID	= 349899413869883140L;

	public static Object call( PageContext pc ) throws PageException {
		return call( pc, null );
	}

	public static Object call( PageContext pc, String datasource ) throws PageException {
		String dsn = ORMUtil.getDataSource( pc, datasource ).getName();
		Session raw = (Session) ORMUtil.getSession( pc ).getRawSession( dsn );
		return CompatSessionWrapper.wrap( raw );
	}

	@Override
	public Object invoke( PageContext pc, Object[] args ) throws PageException {
		if ( args.length == 0 )
			return call( pc );
		return call( pc, CommonUtil.toString( args[ 0 ] ) );
		// @TODO: @nextMajorRelease Enable this throw in the next major version
		// throw CFMLEngineFactory.getInstance().getExceptionUtil().createFunctionException( pc, "ORMGetSession", MIN_ARGUMENTS, MAX_ARGUMENTS, args.length );
	}
}