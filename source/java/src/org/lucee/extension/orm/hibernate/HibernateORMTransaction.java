package org.lucee.extension.orm.hibernate;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.resource.transaction.spi.TransactionStatus;

import lucee.runtime.orm.ORMTransaction;

public class HibernateORMTransaction implements ORMTransaction {

	private Transaction trans;
	private Session session;
	private boolean doRollback;
	private boolean autoManage;

	public HibernateORMTransaction(Session session, boolean autoManage) {
		this.session = session;
		this.autoManage = autoManage;
	}

	@Override
	public void begin() {
		if (autoManage) {
			// FlushM
			// FlushModeType fm = session.getFlushMode();
			// FlushMode hfm = session.getHibernateFlushMode();

			session.flush();
		}
		trans = session.beginTransaction();

	}

	@Override
	public void commit() {
		// do nothing
	}

	@Override
	public void rollback() {
		doRollback = true;
	}

	@Override
	public void end() {
		try {
			if (doRollback) {
				trans.rollback();
				if (autoManage) {
					session.clear();
				}
			}
			else {
				if (trans.getStatus() == TransactionStatus.COMMITTED) {
					trans.commit();
				}
				session.flush();
			}
		}
		finally {
			session.close();
		}

	}
}
