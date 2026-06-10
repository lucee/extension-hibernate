package org.lucee.extension.orm.hibernate.util;

import java.io.InputStream;
import java.lang.reflect.InvocationHandler;
import java.net.URL;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import org.hibernate.boot.registry.classloading.spi.ClassLoaderService;
import org.hibernate.boot.registry.classloading.spi.ClassLoadingException;

/**
 * Decorates a {@link ClassLoaderService} with a positive + negative cache around
 * {@link #classForName(String)}.
 *
 * Hibernate's {@code MetamodelImpl.getImplementors(entityName)} calls
 * {@code classForName(entityName)} on every Criteria/HQL load and falls back to the
 * entity-name → CFC mapping when the class can't be loaded. For Lucee CFC entities the
 * class lookup is a perpetual miss → {@link ClassLoadingException} on every call,
 * costing both the per-throw stacktrace construction and contention on the inner
 * {@code AggregatedClassLoader} monitor.
 *
 * The cache stores the resolved {@code Class} for hits and the original
 * {@code ClassLoadingException} for misses. On subsequent misses the cached exception
 * instance is re-thrown so the stacktrace is constructed once per name, not per call.
 * Hibernate's downstream behaviour is unchanged: same return value on hit, same
 * exception type on miss → same {@code return new String[]{ className }} fall-back.
 */
public class CachingClassLoaderService implements ClassLoaderService {

	private final ClassLoaderService delegate;
	private final ConcurrentMap<String, Class<?>> hits = new ConcurrentHashMap<>();
	private final ConcurrentMap<String, ClassLoadingException> misses = new ConcurrentHashMap<>();

	public CachingClassLoaderService(ClassLoaderService delegate) {
		if (delegate == null) throw new IllegalArgumentException("delegate ClassLoaderService cannot be null");
		this.delegate = delegate;
	}

	@Override
	@SuppressWarnings("unchecked")
	public <T> Class<T> classForName(String className) {
		Class<?> hit = hits.get(className);
		if (hit != null) return (Class<T>) hit;

		ClassLoadingException miss = misses.get(className);
		if (miss != null) throw miss;

		try {
			Class<T> resolved = delegate.classForName(className);
			hits.put(className, resolved);
			return resolved;
		}
		catch (ClassLoadingException e) {
			misses.putIfAbsent(className, e);
			throw e;
		}
	}

	@Override
	public URL locateResource(String name) {
		return delegate.locateResource(name);
	}

	@Override
	public InputStream locateResourceStream(String name) {
		return delegate.locateResourceStream(name);
	}

	@Override
	public List<URL> locateResources(String name) {
		return delegate.locateResources(name);
	}

	@Override
	public <S> Collection<S> loadJavaServices(Class<S> serviceContract) {
		return delegate.loadJavaServices(serviceContract);
	}

	@Override
	@SuppressWarnings("rawtypes")
	public <T> T generateProxy(InvocationHandler handler, Class... interfaces) {
		return delegate.generateProxy(handler, interfaces);
	}

	@Override
	public Package packageForNameOrNull(String packageName) {
		return delegate.packageForNameOrNull(packageName);
	}

	@Override
	public <T> T workWithClassLoader(Work<T> work) {
		return delegate.workWithClassLoader(work);
	}

	@Override
	public void stop() {
		hits.clear();
		misses.clear();
		delegate.stop();
	}
}
