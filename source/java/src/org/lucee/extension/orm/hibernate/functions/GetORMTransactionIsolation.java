package org.lucee.extension.orm.hibernate.functions;

import java.sql.Connection;

import org.hibernate.Session;

import lucee.runtime.PageContext;
import lucee.runtime.db.DataSource;
import lucee.runtime.exp.PageException;
import lucee.runtime.ext.function.BIF;
import lucee.runtime.orm.ORMSession;

/**
 * LDEV-6205: Read the JDBC transaction isolation level from the ORM session's connection.
 *
 * Returns the isolation level as a string matching the core getTransactionIsolation() BIF
 * convention: "read_uncommitted", "read_committed", "repeatable_read", "serializable",
 * or "" if no ORM session is active or isolation is TRANSACTION_NONE.
 */
public class GetORMTransactionIsolation extends BIF {

	private static final long serialVersionUID = 1L;

	public static String call( PageContext pc ) {
		try {
			ORMSession ormSession = pc.getORMSession( false );
			if ( ormSession == null ) return "";

			for ( DataSource ds : ormSession.getDataSources() ) {
				Session session = (Session) ormSession.getRawSession( ds.getName() );
				if ( session != null ) {
					int isolation = session.doReturningWork( conn -> conn.getTransactionIsolation() );
					return toIsolationString( isolation );
				}
			}
		}
		catch ( Exception e ) {
			// no ORM session or connection not available
		}
		return "";
	}

	private static String toIsolationString( int isolation ) {
		switch ( isolation ) {
			case Connection.TRANSACTION_READ_UNCOMMITTED:
				return "read_uncommitted";
			case Connection.TRANSACTION_READ_COMMITTED:
				return "read_committed";
			case Connection.TRANSACTION_REPEATABLE_READ:
				return "repeatable_read";
			case Connection.TRANSACTION_SERIALIZABLE:
				return "serializable";
			default:
				return "";
		}
	}

	@Override
	public Object invoke( PageContext pc, Object[] args ) throws PageException {
		return call( pc );
	}
}
