package org.lucee.extension.orm.hibernate.compat;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

import org.hibernate.MappingException;
import org.hibernate.SessionFactory;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.hibernate.persister.collection.CollectionPersister;
import org.hibernate.persister.entity.EntityPersister;

/**
 * Wraps a Hibernate 7 {@link SessionFactory} in a compat proxy that re-exposes
 * the H5.6-era metadata methods removed in Hibernate 7. See
 * {@code h73-sessionfactory-shim-spec.md} for rationale.
 *
 * <p>Routing:
 * <ul>
 *   <li>{@code getDialect()} → {@code SFI.getJdbcServices().getDialect()}</li>
 *   <li>{@code getClassMetadata(name)} → {@code SFI.getMappingMetamodel().findEntityDescriptor(name)}</li>
 *   <li>{@code getCollectionMetadata(role)} → {@code findCollectionDescriptor(role)}; throws
 *       {@link MappingException} for unknown role to match H5.6 semantics
 *       (H7's {@code findCollectionDescriptor} returns null instead).</li>
 *   <li>{@code getEntityPersister(name)} → {@code findEntityDescriptor(name)}; H5 alias for
 *       the same lookup as {@code getClassMetadata}, used by cborm SQLHelper / ORMUtilSupport
 *       and ColdBox legacy ORM helpers. Throws {@link MappingException} for unknown name to
 *       match H5.6 semantics.</li>
 * </ul>
 *
 * <p>Returns the same instance unchanged if it's already a CompatSessionFactory
 * or null — safe to call on any path.
 */
public final class CompatSessionFactoryWrapper {

	private CompatSessionFactoryWrapper() {}

	public static SessionFactory wrap(SessionFactory real) {
		if (real == null || real instanceof CompatSessionFactory) return real;
		// Implement both CompatSessionFactory (legacy method names) and
		// SessionFactoryImplementor (so native H7 calls like getJdbcServices(),
		// getMappingMetamodel() still resolve through the proxy's declared
		// methods — CFML reflection walks declared methods, so anything not on
		// the implemented interfaces is invisible).
		return (SessionFactory) Proxy.newProxyInstance(
				CompatSessionFactory.class.getClassLoader(),
				new Class<?>[] { CompatSessionFactory.class, SessionFactoryImplementor.class },
				new Handler(real));
	}

	/**
	 * Returns the underlying H7 SessionFactory if the input was produced by
	 * {@link #wrap}, otherwise returns the input unchanged. Symmetric counterpart
	 * to {@link #wrap} — useful for Java-side code (tests, future internal
	 * consumers) that has a SessionFactory reference and wants the raw delegate.
	 */
	public static SessionFactory unwrap(SessionFactory sf) {
		if (sf == null || !Proxy.isProxyClass(sf.getClass())) return sf;
		InvocationHandler h = Proxy.getInvocationHandler(sf);
		if (h instanceof Handler) return ((Handler) h).delegate;
		return sf;
	}

	private static final class Handler implements InvocationHandler {

		private final SessionFactory delegate;

		Handler(SessionFactory delegate) {
			this.delegate = delegate;
		}

		@Override
		public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
			String name = method.getName();
			int paramCount = method.getParameterCount();

			if (paramCount == 0 && "getDialect".equals(name)) {
				return ((SessionFactoryImplementor) delegate).getJdbcServices().getDialect();
			}
			if (paramCount == 1 && "getClassMetadata".equals(name) && method.getParameterTypes()[0] == String.class) {
				EntityPersister ep = ((SessionFactoryImplementor) delegate)
						.getMappingMetamodel()
						.findEntityDescriptor((String) args[0]);
				return CompatEntityPersisterWrapper.wrap(ep);
			}
			if (paramCount == 1 && "getCollectionMetadata".equals(name) && method.getParameterTypes()[0] == String.class) {
				String role = (String) args[0];
				CollectionPersister cp = ((SessionFactoryImplementor) delegate)
						.getMappingMetamodel()
						.findCollectionDescriptor(role);
				if (cp == null) {
					throw new MappingException("Could not locate CollectionPersister for role : " + role);
				}
				return cp;
			}
			if (paramCount == 1 && "getEntityPersister".equals(name) && method.getParameterTypes()[0] == String.class) {
				String entityName = (String) args[0];
				EntityPersister ep = ((SessionFactoryImplementor) delegate)
						.getMappingMetamodel()
						.findEntityDescriptor(entityName);
				if (ep == null) {
					throw new MappingException("Unknown entity: " + entityName);
				}
				return CompatEntityPersisterWrapper.wrap(ep);
			}

			// delegate everything else to the real SessionFactory
			return method.invoke(delegate, args);
		}
	}
}
