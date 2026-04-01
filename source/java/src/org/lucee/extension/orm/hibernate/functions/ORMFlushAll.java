package org.lucee.extension.orm.hibernate.functions;

import org.lucee.extension.orm.hibernate.util.ORMUtil;

import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.ext.function.BIF;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.engine.CFMLEngine;

/**
 * CFML built-in function to flush all open ORM sessions.
 */
public class ORMFlushAll extends BIF {

	private static final int	MIN_ARGUMENTS	= 0;
	private static final int	MAX_ARGUMENTS	= 0;

	public static String call( PageContext pc ) throws PageException {
		ORMUtil.getSession( pc ).flushAll( pc );
		return null;
	}

	@Override
	public Object invoke( PageContext pc, Object[] args ) throws PageException {
		CFMLEngine engine = CFMLEngineFactory.getInstance();

		if ( args.length == 0 )
			return call( pc );

		throw engine.getExceptionUtil().createFunctionException( pc, "ORMFlushAll", MIN_ARGUMENTS, MAX_ARGUMENTS, args.length );
	}
}
