package org.lucee.extension.orm.hibernate.tuplizer;

import java.util.function.Supplier;

import org.hibernate.mapping.Component;
import org.hibernate.mapping.PersistentClass;
import org.hibernate.metamodel.internal.ManagedTypeRepresentationResolverStandard;
import org.hibernate.metamodel.mapping.EmbeddableMappingType;
import org.hibernate.metamodel.spi.EmbeddableRepresentationStrategy;
import org.hibernate.metamodel.spi.EntityRepresentationStrategy;
import org.hibernate.metamodel.spi.ManagedTypeRepresentationResolver;
import org.hibernate.metamodel.spi.RuntimeModelCreationContext;
import org.hibernate.persister.entity.EntityPersister;

/**
 * Routes all entity-strategy resolution through {@link CFCRepresentationStrategy} so
 * Lucee CFCs are treated as the entity representation. Embeddable resolution is
 * delegated to {@link ManagedTypeRepresentationResolverStandard} (CFML composite keys
 * and embedded components currently rely on Hibernate's default map-based handling).
 */
public class CFCRepresentationResolver implements ManagedTypeRepresentationResolver {

	public static final CFCRepresentationResolver INSTANCE = new CFCRepresentationResolver();

	@Override
	public EntityRepresentationStrategy resolveStrategy(
			PersistentClass bootDescriptor,
			EntityPersister runtimeDescriptor,
			RuntimeModelCreationContext creationContext) {
		return new CFCRepresentationStrategy(bootDescriptor, creationContext);
	}

	@Override
	public EmbeddableRepresentationStrategy resolveStrategy(
			Component bootDescriptor,
			Supplier<EmbeddableMappingType> runtimeDescriptorAccess,
			RuntimeModelCreationContext creationContext) {
		return ManagedTypeRepresentationResolverStandard.INSTANCE.resolveStrategy(
				bootDescriptor, runtimeDescriptorAccess, creationContext);
	}
}
