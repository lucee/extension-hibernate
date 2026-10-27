package org.lucee.extension.orm.hibernate.compat;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

import org.hibernate.persister.entity.EntityPersister;

/**
 * Wraps a Hibernate 7 {@link EntityPersister} in a compat proxy that re-exposes
 * the H5.6-era int-index legacy overloads removed in Hibernate 6/7. See
 * {@link CompatEntityPersister} for the H5 surface re-exposed.
 *
 * <p>Returns the input unchanged if it's null or already wrapped.
 */
public final class CompatEntityPersisterWrapper {

	private CompatEntityPersisterWrapper() {}

	public static EntityPersister wrap(EntityPersister real) {
		if (real == null || real instanceof CompatEntityPersister) return real;
		return (EntityPersister) Proxy.newProxyInstance(
				CompatEntityPersister.class.getClassLoader(),
				new Class<?>[] { CompatEntityPersister.class },
				new Handler(real));
	}

	/**
	 * Returns the underlying H7 EntityPersister if the input was produced by
	 * {@link #wrap}, otherwise returns the input unchanged.
	 */
	public static EntityPersister unwrap(EntityPersister ep) {
		if (ep == null || !Proxy.isProxyClass(ep.getClass())) return ep;
		InvocationHandler h = Proxy.getInvocationHandler(ep);
		if (h instanceof Handler) return ((Handler) h).delegate;
		return ep;
	}

	private static final class Handler implements InvocationHandler {

		private final EntityPersister delegate;

		Handler(EntityPersister delegate) {
			this.delegate = delegate;
		}

		@Override
		public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
			// H5 legacy: getSubclassPropertyName(int) → getPropertyNames()[i].
			// H7 made the int overload protected on AbstractEntityPersister.
			if ("getSubclassPropertyName".equals(method.getName())
					&& method.getParameterCount() == 1
					&& method.getParameterTypes()[0] == int.class) {
				int i = (Integer) args[0];
				return delegate.getPropertyNames()[i];
			}
			return method.invoke(delegate, args);
		}
	}
}
