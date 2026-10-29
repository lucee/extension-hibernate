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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.util.ORMUtil;

import lucee.loader.util.Util;
import lucee.runtime.PageContext;
import lucee.runtime.type.Array;
import lucee.runtime.exp.PageException;
import lucee.runtime.ext.function.BIF;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.engine.CFMLEngine;

/**
 * CFML built-in function to flush the current session.
 */
public class ORMFlush extends BIF {

	private static final int	MIN_ARGUMENTS	= 0;
	private static final int	MAX_ARGUMENTS	= 1;

	public static String call( PageContext pc ) throws PageException {
		return call( pc, null );
	}

	public static String call( PageContext pc, String datasource ) throws PageException {
		return call( pc, ( Object ) datasource );
	}

	/**
	 * @param datasources
	 *            a single datasource name, a comma separated list of datasource names or an array of datasource names. Nothing (or only empty
	 *            names) flushes the session of the default datasource.
	 */
	public static String call( PageContext pc, Object datasources ) throws PageException {
		List<String> names = toDatasourceNames( datasources );

		if ( names.isEmpty() )
			ORMUtil.getSession( pc ).flush( pc );
		else {
			// resolve all names first, so an unknown datasource fails before any session is flushed
			for ( String name : names ) {
				CommonUtil.getDataSource( pc, name );
			}
			for ( String name : names ) {
				ORMUtil.getSession( pc ).flush( pc, name );
			}
		}
		return null;
	}

	private static List<String> toDatasourceNames( Object datasources ) throws PageException {
		List<String> names = new ArrayList<String>();
		if ( datasources == null )
			return names;

		if ( CommonUtil.isArray( datasources ) ) {
			Array				arr	= CommonUtil.toArray( datasources );
			Iterator<Object>	it	= arr.valueIterator();
			while ( it.hasNext() ) {
				addName( names, CommonUtil.toString( it.next() ) );
			}
		}
		else {
			for ( String name : CommonUtil.toStringArray( CommonUtil.toString( datasources ), "," ) ) {
				addName( names, name );
			}
		}
		return names;
	}

	private static void addName( List<String> names, String name ) {
		if ( !Util.isEmpty( name, true ) )
			names.add( name.trim() );
	}

	@Override
	public Object invoke( PageContext pc, Object[] args ) throws PageException {
		CFMLEngine engine = CFMLEngineFactory.getInstance();

		if ( args.length == 0 )
			return call( pc );
		if ( args.length == 1 )
			return call( pc, args[ 0 ] );

		throw engine.getExceptionUtil().createFunctionException( pc, "ORMFlush", MIN_ARGUMENTS, MAX_ARGUMENTS, args.length );
	}
}