package org.lucee.extension.orm.hibernate.compat;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.Map;

import org.hibernate.LockMode;
import org.hibernate.LockOptions;
import org.hibernate.Session;
import org.hibernate.TransientObjectException;
import org.hibernate.engine.spi.SessionImplementor;

/**
 * Wraps a Hibernate 7 {@link Session} in a compat proxy that re-exposes the
 * H5.6-era Session methods removed in H6/H7. See {@code h73-session-shim-spec.md}
 * for the empirical surface (73 methods removed; 32 across 9 families are
 * CFML-relevant).
 *
 * <p>Mirrors {@link CompatSessionFactoryWrapper}'s shape: a {@link Proxy}
 * implementing both {@link CompatSession} (legacy method names) and
 * {@link SessionImplementor} (modern SPI). CFML reflection walks declared
 * methods, so anything not on a declared interface is invisible.
 *
 * <p>Returns the input unchanged if it's null or already a {@link CompatSession}
 * — safe to call on any path.
 *
 * <p>Routing per family:
 * <ul>
 *   <li>{@code save} → {@code persist} then return {@code getIdentifier(entity)}
 *       to preserve the H5 contract of returning the generated id.</li>
 *   <li>{@code update} → {@code merge}. Returns void to match H5 (merge's
 *       managed-copy return value is dropped; callers wanting it should call
 *       {@code merge} directly).</li>
 *   <li>{@code saveOrUpdate} → {@code persist} if {@code getIdentifier(entity)}
 *       is null, else {@code merge}.</li>
 *   <li>{@code delete} → {@code remove}. Entity-name and SPI 4-arg overloads
 *       drop their extra args.</li>
 *   <li>{@code load} → {@code getReference}. {@code LockMode}/{@code LockOptions}
 *       overloads ignore the lock arg (proxy doesn't take a lock; documented
 *       in BREAKING-CHANGES.md). The {@code load(Object, Serializable)}
 *       "load INTO existing object" form has no H7 equivalent and throws
 *       {@link UnsupportedOperationException} with a clear migration message.</li>
 *   <li>{@code refresh} (H5-only forms): translate {@code LockMode} to
 *       {@code LockOptions} and drop the entity-name argument.</li>
 *   <li>{@code createSQLQuery} → {@code createNativeQuery}.</li>
 *   <li>{@code getNamedSQLQuery} → {@code createNamedQuery}.</li>
 * </ul>
 *
 * <p>The {@code get(...)} family is not routed — H7 keeps {@code get(...,Object)}
 * overloads (same name, widened arg type). Lucee dispatch resolves
 * {@code session.get(...)} to those overloads automatically. Verified via
 * {@code tests/compat/sessionApiSurface/getDispatch.cfm}.
 */
public final class CompatSessionWrapper {

	private CompatSessionWrapper() {}

	public static Session wrap(Session real) {
		if (real == null || real instanceof CompatSession) return real;
		return (Session) Proxy.newProxyInstance(
				CompatSession.class.getClassLoader(),
				new Class<?>[] { CompatSession.class, SessionImplementor.class },
				new Handler(real));
	}

	/**
	 * Returns the underlying H7 Session if the input was produced by {@link #wrap},
	 * otherwise returns the input unchanged. Symmetric counterpart to {@link #wrap}.
	 *
	 * <p>CFML callers should usually use the JPA-standard {@code session.unwrap(Class)}
	 * instead — that works through the proxy delegation. This helper is for Java-side
	 * code (tests, future internal consumers) that has a {@link Session} reference and
	 * wants the raw delegate without going through reflection.
	 */
	public static Session unwrap(Session sess) {
		if (sess == null || !Proxy.isProxyClass(sess.getClass())) return sess;
		InvocationHandler h = Proxy.getInvocationHandler(sess);
		if (h instanceof Handler) return ((Handler) h).delegate;
		return sess;
	}

	private static final class Handler implements InvocationHandler {

		private final Session delegate;

		Handler(Session delegate) {
			this.delegate = delegate;
		}

		@Override
		public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
			String name = method.getName();
			int paramCount = method.getParameterCount();
			Class<?>[] pTypes = method.getParameterTypes();

			// --- save → persist + return getIdentifier ---
			if ("save".equals(name)) {
				if (paramCount == 1) {
					delegate.persist(args[0]);
					return delegate.getIdentifier(args[0]);
				}
				if (paramCount == 2 && pTypes[0] == String.class) {
					delegate.persist((String) args[0], args[1]);
					return delegate.getIdentifier(args[1]);
				}
			}

			// --- update → merge (H5 returned void; we discard merge's managed copy) ---
			if ("update".equals(name)) {
				if (paramCount == 1) {
					delegate.merge(args[0]);
					return null;
				}
				if (paramCount == 2 && pTypes[0] == String.class) {
					delegate.merge((String) args[0], args[1]);
					return null;
				}
			}

			// --- saveOrUpdate → persist if transient, else merge ---
			// H7's contains(entity) returns true iff entity is in the persistence
			// context. Transient (newly created) and detached (loaded then evicted)
			// both return false. For the common CFML cases:
			//   - transient with manually-assigned id → persist (works)
			//   - managed entity → merge (no-op-ish, kept for shape compat)
			// Detached entities are rare in CFML (sessions are request-scoped and
			// rarely cleared mid-request); callers wanting reattach-then-update
			// semantics should call merge directly. Documented in BREAKING-CHANGES.md.
			if ("saveOrUpdate".equals(name)) {
				Object entity = paramCount == 1 ? args[0] : args[1];
				if (delegate.contains(entity)) {
					if (paramCount == 1) delegate.merge(entity);
					else delegate.merge((String) args[0], entity);
				} else {
					if (paramCount == 1) delegate.persist(entity);
					else delegate.persist((String) args[0], entity);
				}
				return null;
			}

			// --- delete → remove. All overloads collapse to remove(entity). ---
			if ("delete".equals(name)) {
				Object entity = paramCount == 1 ? args[0] : args[1];
				delegate.remove(entity);
				return null;
			}

			// load(...) is NOT routed — see CompatSession.java for rationale (zero
			// real-world CFML callers, and H7's load(Object, Object) clashes with
			// Lucee dispatch). Native H7 Session.load(Object existingInstance, id)
			// passes through unchanged.

			// --- refresh: H5-only forms. H7 native overloads fall through. ---
			if ("refresh".equals(name)) {
				if (paramCount == 2 && pTypes[0] == Object.class && pTypes[1] == LockMode.class) {
					// H5 refresh(entity, LockMode) → H7 refresh(entity, new LockOptions(LockMode))
					delegate.refresh(args[0], new LockOptions((LockMode) args[1]));
					return null;
				}
				if (paramCount == 2 && pTypes[0] == String.class) {
					// H5 refresh(entityName, entity) → H7 refresh(entity)
					delegate.refresh(args[1]);
					return null;
				}
				if (paramCount == 3 && pTypes[0] == String.class && pTypes[2] == LockOptions.class) {
					// H5 refresh(entityName, entity, LockOptions) → H7 refresh(entity, LockOptions)
					delegate.refresh(args[1], (LockOptions) args[2]);
					return null;
				}
				if (paramCount == 3 && pTypes[0] == String.class && pTypes[2] == Map.class) {
					// H5 refresh(entityName, entity, Map) → H7 refresh(entity, Map)
					@SuppressWarnings("unchecked")
					Map<String, Object> opts = (Map<String, Object>) args[2];
					delegate.refresh(args[1], opts);
					return null;
				}
			}

			// --- createSQLQuery → createNativeQuery ---
			if ("createSQLQuery".equals(name) && paramCount == 1 && pTypes[0] == String.class) {
				return delegate.createNativeQuery((String) args[0]);
			}

			// --- getNamedSQLQuery → createNamedQuery ---
			if ("getNamedSQLQuery".equals(name) && paramCount == 1 && pTypes[0] == String.class) {
				return delegate.createNamedQuery((String) args[0]);
			}

			// Surviving H7 methods + Object.class methods (equals/hashCode/toString) pass through.
			// Unwrap InvocationTargetException so unchecked exceptions propagate as-is
			// (otherwise the Proxy infrastructure wraps the ITE in UndeclaredThrowableException
			// because none of the interface methods declare checked exceptions).
			try {
				return method.invoke(delegate, args);
			} catch (InvocationTargetException ite) {
				Throwable cause = ite.getCause();
				// H5 contract: getEntityName(transient) throws TransientObjectException —
				// cborm ObjectPopulator.getTargetName depends on that exact type to
				// short-circuit transient detection. H7's SessionImpl.getEntityName goes
				// through getEntityEntry and throws IllegalArgumentException instead.
				// Translate so the H5 typed-catch still matches.
				if ("getEntityName".equals(name)
						&& paramCount == 1
						&& cause instanceof IllegalArgumentException) {
					throw new TransientObjectException(cause.getMessage());
				}
				throw cause;
			}
		}
	}
}
