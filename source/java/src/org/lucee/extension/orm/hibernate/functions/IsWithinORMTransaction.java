package org.lucee.extension.orm.hibernate.functions;

import org.hibernate.Session;
import org.hibernate.resource.transaction.spi.TransactionStatus;

import org.lucee.extension.orm.hibernate.HibernateORMSession;
import org.lucee.extension.orm.hibernate.util.HibernateUtil;

import lucee.runtime.PageContext;
import lucee.runtime.db.DataSource;
import lucee.runtime.exp.PageException;
import lucee.runtime.ext.function.BIF;
import lucee.runtime.orm.ORMSession;

/**
 * LDEV-6207: Check whether a Hibernate ORM transaction is currently active.
 *
 * Returns true if any ORM datasource has an active Hibernate transaction.
 * Safe to call without an ORM session — returns false if ORM is not initialised.
 */
public class IsWithinORMTransaction extends BIF {

	private static final long serialVersionUID = 1L;

	public static boolean call( PageContext pc ) {
		try {
			ORMSession ormSession = pc.getORMSession( false );
			if ( ormSession == null ) return false;

			for ( DataSource ds : ormSession.getDataSources() ) {
				Session session = (Session) ormSession.getRawSession( ds.getName() );
				if ( session != null && session.getTransaction().getStatus() == TransactionStatus.ACTIVE ) {
					return true;
				}
			}
		}
		catch ( Exception e ) {
			// no ORM session, ORM not configured, or session closed — not in a transaction
		}
		return false;
	}

	@Override
	public Object invoke( PageContext pc, Object[] args ) throws PageException {
		return call( pc );
	}
}
