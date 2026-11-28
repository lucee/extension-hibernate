package org.lucee.extension.orm.hibernate.event;

import org.hibernate.HibernateException;
import org.hibernate.event.spi.InitializeCollectionEvent;
import org.hibernate.event.spi.InitializeCollectionEventListener;
import org.hibernate.event.spi.LoadEvent;
import org.hibernate.event.spi.LoadEventListener;
import org.lucee.extension.orm.hibernate.HibernatePageException;
import org.lucee.extension.orm.hibernate.util.CommonUtil;

import lucee.runtime.PageContext;
import lucee.runtime.db.DataSourceManager;
import lucee.runtime.exp.PageException;

/**
 * Joins the ORM session to the surrounding {@code transaction{}} before Hibernate runs the SQL of
 * a load or a lazy collection initialization (LDEV-7026).
 *
 * <p>Lucee starts the ORM transaction (and with it {@code HibernateORMTransaction.begin()}) the
 * first time the request's ORM session is looked up inside a {@code transaction{}}. Lucee ORM
 * functions do that before any SQL. Initializing a lazy proxy or collection that was loaded before
 * the block does not: the SELECT runs first, and the ORM session is only looked up while the rows
 * are hydrated, so {@code begin()} ran with the load's ResultSet still open. Looking the session up
 * here moves {@code begin()} in front of the SQL, so the load already runs on the
 * {@code transaction{}}'s connection.
 *
 * <p>Outside a transaction this is one thread-local lookup and a boolean check. Inside, Lucee's
 * {@code DatasourceManager.add()} returns after a map lookup once the session is joined.
 */
public class TransactionJoinListener implements LoadEventListener, InitializeCollectionEventListener {

	private static final long serialVersionUID = 3015583425478913346L;

	@Override
	public void onLoad(LoadEvent event, LoadType loadType) throws HibernateException {
		joinTransaction();
	}

	@Override
	public void onInitializeCollection(InitializeCollectionEvent event) throws HibernateException {
		joinTransaction();
	}

	private static void joinTransaction() {
		PageContext pc = CommonUtil.pc();
		if (pc == null) return;
		DataSourceManager manager = pc.getDataSourceManager();
		if (manager == null || manager.isAutoCommit()) return;
		try {
			// registers the existing session with the DatasourceManager, never creates one
			pc.getORMSession(false);
		}
		catch (PageException pe) {
			throw new HibernatePageException(pe);
		}
	}
}
