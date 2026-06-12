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
 * Decorates a {@link ClassLoaderService} with a negative cache around
 * {@link #classForName(String)}.
 *
 * Hibernate's {@code MetamodelImpl.getImplementors(entityName)} calls
 * {@code classForName(entityName)} on every Criteria/HQL load and falls back to the
 * entity-name → CFC mapping when the class can't be loaded. For Lucee CFC entities the
 * class lookup is a perpetual miss → {@link ClassLoadingException} on every call,
 * costing both the per-throw stacktrace construction and contention on the inner
 * {@code AggregatedClassLoader} monitor.
 *
 * The cache stores the original {@code ClassLoadingException} for misses, keyed by
 * class name. On subsequent calls for the same name the cached exception instance is
 * re-thrown so the stacktrace is constructed once per name, not per call.
 *
 * <p><b>Hits are deliberately NOT cached.</b> Hibernate already maintains positive
 * caches downstream ({@code MetamodelImpl.knownValidImports}, {@code implementorsCache});
 * caching resolved {@code Class<?>} objects here would pin them to whichever bundle
 * classloader resolved them. After a Felix bundle refresh (extension hot-swap), the
 * cached {@code Class} survives in memory but its defining loader is disposed,
 * causing downstream Hibernate operations that touch it to fail with
 * "bundle wiring is no longer valid".
 *
 * The cached exception is safe across bundle refresh — re-throwing a frozen exception
 * doesn't invoke methods on any class referenced by its stack trace.
 */
public class CachingClassLoaderService implements ClassLoaderService {

	private final ClassLoaderService delegate;
	private final ConcurrentMap<String, ClassLoadingException> misses = new ConcurrentHashMap<>();

	public CachingClassLoaderService(ClassLoaderService delegate) {
		if (delegate == null) throw new IllegalArgumentException("delegate ClassLoaderService cannot be null");
		this.delegate = delegate;
	}

	@Override
	public <T> Class<T> classForName(String className) {
		ClassLoadingException miss = misses.get(className);
		if (miss != null) throw miss;

		try {
			return delegate.classForName(className);
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
		misses.clear();
		delegate.stop();
	}
}
