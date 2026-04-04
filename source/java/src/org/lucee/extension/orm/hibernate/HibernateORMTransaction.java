package org.lucee.extension.orm.hibernate;

import java.lang.reflect.Method;
import java.sql.Connection;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.resource.transaction.spi.TransactionStatus;

import lucee.loader.engine.CFMLEngineFactory;
import lucee.runtime.PageContext;
import lucee.runtime.orm.ORMTransaction;

/**
 * Hibernate Transaction wrapper object. Manages begin/commit/rollback of a real Hibernate
 * transaction, mapped from CFML's &lt;cftransaction&gt; block.
 *
 * <p>Lucee core calls these methods in order: begin() → [user code] → commit()/rollback() → end()
 */
public class HibernateORMTransaction implements ORMTransaction {

	// Cached reflection lookup for DatasourceManagerImpl.getIsolation() (Lucee 7.1+).
	private static volatile Method getIsolationMethod;
	private static volatile boolean getIsolationLookedUp;

	private Transaction trans;
	private Session session;
	private boolean doRollback;
	private boolean autoManage;
	private int isolation = Connection.TRANSACTION_NONE;

	/**
	 * Constructor. Does NOT open a Hibernate transaction at this time.
	 *
	 * @param session
	 *            Hibernate session to open a transaction on
	 * @param autoManage
	 *            Should the Transaction be auto-managed
	 */
	public HibernateORMTransaction(Session session, boolean autoManage) {
		this.session = session;
		this.autoManage = autoManage;
	}

	/**
	 * Open a real Hibernate transaction on the current session.
	 *
	 * <p>Flushes pending changes first if autoManage is enabled, then begins a Hibernate transaction.
	 * If the surrounding cftransaction specifies an isolation level, applies it to the JDBC
	 * connection via session.doWork() before any ORM queries execute.
	 */
	@Override
	public void begin() {
		if (autoManage) {
			session.flush();
		}
		trans = session.getTransaction();
		trans.begin();

		isolation = getTransactionIsolation();
		applyIsolation();
	}

	/**
	 * Apply the cached isolation level to the Hibernate JDBC connection via session.doWork().
	 * No-op when isolation is TRANSACTION_NONE (no explicit isolation specified).
	 */
	private void applyIsolation() {
		if (isolation != Connection.TRANSACTION_NONE) {
			session.doWork( conn -> conn.setTransactionIsolation( isolation ) );
		}
	}

	/**
	 * Read the isolation level from the current cftransaction via DatasourceManagerImpl.getIsolation().
	 * Returns TRANSACTION_NONE if not available (no cftransaction, older Lucee without getIsolation()).
	 * The Method is resolved once and cached for the lifetime of the classloader.
	 */
	private int getTransactionIsolation() {
		try {
			if (!getIsolationLookedUp) {
				try {
					PageContext pc = CFMLEngineFactory.getInstance().getThreadPageContext();
					if (pc != null) {
						getIsolationMethod = pc.getDataSourceManager().getClass().getMethod( "getIsolation" );
					}
				}
				catch (NoSuchMethodException e) {
					// older Lucee without getIsolation() — leave method null
				}
				getIsolationLookedUp = true;
			}
			if (getIsolationMethod == null) return Connection.TRANSACTION_NONE;

			PageContext pc = CFMLEngineFactory.getInstance().getThreadPageContext();
			if (pc == null) return Connection.TRANSACTION_NONE;
			return (int) getIsolationMethod.invoke( pc.getDataSourceManager() );
		}
		catch (Exception e) {
			return Connection.TRANSACTION_NONE;
		}
	}

	/**
	 * Commit the current Hibernate transaction.
	 *
	 * <p>Flushes the session to push pending changes to the DB, then commits the transaction.
	 * A new transaction is begun immediately so subsequent ORM operations in the same
	 * cftransaction block remain transactional.
	 *
	 * <p>Skips if rollback has been requested — Lucee core calls commit() via doAfterBody()
	 * even after transactionRollback(), so we must not override the rollback decision.
	 */
	@Override
	public void commit() {
		if (doRollback) return;
		session.flush();
		trans.commit();
		// start a new transaction — Lucee core may continue with more ORM operations
		// in the same cftransaction block after transactionCommit()
		trans = session.getTransaction();
		trans.begin();
		applyIsolation();
	}

	/**
	 * Mark the transaction for rollback.
	 *
	 * Will only execute a rollback on {@link #end()}
	 */
	@Override
	public void rollback() {
		doRollback = true;
	}

	/**
	 * Wrap up the transaction.
	 * <ul>
	 * <li>Will roll back if rollback() was called, and clear the session if autoManage.
	 * <li>Will flush and commit if the transaction is still active.
	 * </ul>
	 */
	@Override
	public void end() {
		if (doRollback) {
			if (trans.getStatus() == TransactionStatus.ACTIVE) {
				trans.rollback();
			}
			if (autoManage) {
				session.clear();
			}
		}
		else if (trans.getStatus() == TransactionStatus.ACTIVE) {
			session.flush();
			trans.commit();
		}
	}

	/**
	 * Retrieve the internal Hibernate transaction
	 *
	 * @return a Hibernate {@link org.hibernate.Transaction} object.
	 */
	public Transaction getTransaction() {
		return trans;
	}
}
