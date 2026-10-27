package org.lucee.extension.orm.hibernate.compat;

import org.hibernate.SessionFactory;
import org.hibernate.dialect.Dialect;
import org.hibernate.persister.collection.CollectionPersister;
import org.hibernate.persister.entity.EntityPersister;

/**
 * Synthetic interface declaring the H5.6-era SessionFactory metadata methods that
 * were removed in Hibernate 7. CFML method resolution walks the runtime class's
 * declared methods, so these signatures must exist on the type returned by
 * {@code ORMGetSessionFactory()} for legacy CFML code (cborm, ColdBox, Slatwall)
 * to keep working without modification.
 *
 * <p>Implementation lives in {@link CompatSessionFactoryWrapper}, which builds a
 * {@code java.lang.reflect.Proxy} routing these methods to the modern H7 APIs.
 *
 * <p>Scope is intentionally narrow:
 * <ul>
 *   <li>{@code getAllClassMetadata()} is omitted — Hibernate 5.6.15 already throws
 *       {@code UnsupportedOperationException} from it, so there's no behaviour to
 *       preserve.</li>
 *   <li>{@code getTypeHelper()} is omitted — zero observed third-party callers.</li>
 * </ul>
 */
public interface CompatSessionFactory extends SessionFactory {

	Dialect getDialect();

	EntityPersister getClassMetadata(String entityName);

	CollectionPersister getCollectionMetadata(String collectionRole);

	EntityPersister getEntityPersister(String entityName);
}
