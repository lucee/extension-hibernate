package org.lucee.extension.orm.hibernate.functions;

import org.lucee.extension.orm.hibernate.util.ExceptionUtil;

import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.ext.function.BIF;

/**
 * ACF compatibility stub — Hibernate Search is not supported in the Lucee Hibernate extension.
 */
public class ORMIndexPurge extends BIF {

	@Override
	public Object invoke( PageContext pc, Object[] args ) throws PageException {
		throw ExceptionUtil.createException(
			"ORMIndexPurge() is not supported in the Lucee Hibernate extension. Hibernate Search (Lucene-based full-text search) is an ACF-only feature. Consider using Elasticsearch, OpenSearch, or your database's full-text search instead." );
	}
}
