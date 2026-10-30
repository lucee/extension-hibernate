package org.lucee.extension.orm.hibernate.tuplizer;

import java.lang.reflect.Field;

import org.hibernate.boot.MetadataBuilder;
import org.hibernate.boot.registry.StandardServiceRegistry;
import org.hibernate.boot.spi.BootstrapContext;
import org.hibernate.boot.spi.MetadataBuilderInitializer;

/**
 * Hooks Hibernate's {@link MetadataBuilderInitializer} SPI (registered via
 * {@code META-INF/services}) so we can install {@link CFCRepresentationResolver} as the
 * representation strategy selector for entities.
 *
 * Hibernate 7 made BootstrapContextImpl.representationStrategySelector a
 * {@code private final} field with no public hook to override it (hardcoded since
 * 6.0.0.Alpha3). Until Hibernate exposes a service-registry / contributor mechanism,
 * we reflectively replace the field — it's a single boot-time write with zero runtime
 * overhead. See h73-migration-status.md (Stage 3) for the strategic context and the
 * planned codegen replacement.
 */
public class CFCMetadataBuilderInitializer implements MetadataBuilderInitializer {

	private static final String BOOTSTRAP_CONTEXT_FIELD = "bootstrapContext";
	private static final String RESOLVER_FIELD = "representationStrategySelector";

	@Override
	public void contribute(MetadataBuilder metadataBuilder, StandardServiceRegistry serviceRegistry) {
		BootstrapContext bootstrapContext = readBootstrapContext(metadataBuilder);
		swapResolver(bootstrapContext, CFCRepresentationResolver.INSTANCE);
	}

	private static BootstrapContext readBootstrapContext(MetadataBuilder metadataBuilder) {
		try {
			Field f = findField(metadataBuilder.getClass(), BOOTSTRAP_CONTEXT_FIELD);
			f.setAccessible(true);
			return (BootstrapContext) f.get(metadataBuilder);
		}
		catch (Exception e) {
			throw new RuntimeException(
					"Failed to access BootstrapContext on MetadataBuilder [" + metadataBuilder.getClass().getName()
							+ "] — Hibernate internals may have changed; CFC entity representation requires this hook",
					e);
		}
	}

	private static void swapResolver(BootstrapContext bootstrapContext, CFCRepresentationResolver resolver) {
		try {
			Field f = findField(bootstrapContext.getClass(), RESOLVER_FIELD);
			f.setAccessible(true);
			f.set(bootstrapContext, resolver);
		}
		catch (Exception e) {
			throw new RuntimeException(
					"Failed to install CFCRepresentationResolver on BootstrapContext [" + bootstrapContext.getClass().getName()
							+ "] — Hibernate internals may have changed; CFC entity representation requires this hook",
					e);
		}
	}

	private static Field findField(Class<?> cls, String name) throws NoSuchFieldException {
		Class<?> c = cls;
		while (c != null && c != Object.class) {
			try {
				return c.getDeclaredField(name);
			}
			catch (NoSuchFieldException nsfe) {
				c = c.getSuperclass();
			}
		}
		throw new NoSuchFieldException("Field [" + name + "] not found on class [" + cls.getName() + "] or any ancestor");
	}
}
