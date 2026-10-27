package org.lucee.extension.orm.hibernate.tuplizer;

import java.util.function.Consumer;

import org.hibernate.EntityNameResolver;
import org.hibernate.HibernateException;
import org.hibernate.bytecode.spi.ReflectionOptimizer;
import org.hibernate.mapping.PersistentClass;
import org.hibernate.mapping.Property;
import org.hibernate.metamodel.RepresentationMode;
import org.hibernate.metamodel.spi.EntityInstantiator;
import org.hibernate.metamodel.spi.EntityRepresentationStrategy;
import org.hibernate.metamodel.spi.RuntimeModelCreationContext;
import org.hibernate.property.access.spi.PropertyAccess;
import org.hibernate.proxy.ProxyFactory;
import org.hibernate.type.Type;
import org.hibernate.type.descriptor.java.JavaType;
import org.lucee.extension.orm.hibernate.SessionFactoryData;
import org.lucee.extension.orm.hibernate.tuplizer.accessors.CFCGetter;
import org.lucee.extension.orm.hibernate.tuplizer.accessors.CFCSetter;
import org.lucee.extension.orm.hibernate.tuplizer.proxy.CFCHibernateProxyFactory;

import lucee.runtime.Component;

/**
 * EntityRepresentationStrategy for CFML components. Replaces the pre-Hibernate-7 tuplizer
 * (AbstractEntityTuplizer) that no longer exists in Hibernate 7.x. Wires up the
 * CFC-specific {@link CFCInstantiator}, {@link CFCHibernateProxyFactory},
 * {@link CFCEntityNameResolver} plus per-property {@link CFCGetter}/{@link CFCSetter}
 * accessors via {@link CFCPropertyAccess}.
 */
public class CFCRepresentationStrategy implements EntityRepresentationStrategy {

	private final String entityName;
	private final JavaType<?> componentJavaType;
	private final ProxyFactory proxyFactory;
	private final EntityInstantiator instantiator;

	public CFCRepresentationStrategy(PersistentClass bootDescriptor, RuntimeModelCreationContext creationContext) {
		this.entityName = bootDescriptor.getEntityName();
		this.componentJavaType = creationContext.getTypeConfiguration().getJavaTypeRegistry().resolveDescriptor(Component.class);

		CFCHibernateProxyFactory pf = new CFCHibernateProxyFactory();
		pf.postInstantiate(bootDescriptor);
		this.proxyFactory = pf;

		SessionFactoryData data = SessionFactoryData.CURRENT_BUILDING.get();
		if (data == null) {
			throw new HibernateException("CFCRepresentationStrategy created outside SessionFactoryData.buildSessionFactory() — entity ["
					+ entityName + "] cannot resolve its CFC template. SessionFactoryData.CURRENT_BUILDING thread-local was not set.");
		}
		this.instantiator = new CFCInstantiator(bootDescriptor, data);
	}

	@Override
	public RepresentationMode getMode() {
		return RepresentationMode.MAP;
	}

	@Override
	public ReflectionOptimizer getReflectionOptimizer() {
		return null;
	}

	@Override
	public JavaType<?> getMappedJavaType() {
		return componentJavaType;
	}

	@Override
	public PropertyAccess resolvePropertyAccess(Property bootAttributeDescriptor) {
		Type type = bootAttributeDescriptor.getValue() != null ? bootAttributeDescriptor.getType() : null;
		String propertyName = bootAttributeDescriptor.getName();
		CFCGetter getter = new CFCGetter(propertyName, type, entityName);
		CFCSetter setter = new CFCSetter(propertyName, type, entityName);
		return new CFCPropertyAccess(getter, setter);
	}

	@Override
	public EntityInstantiator getInstantiator() {
		return instantiator;
	}

	@Override
	public ProxyFactory getProxyFactory() {
		return proxyFactory;
	}

	@Override
	public boolean isBytecodeEnhanced() {
		return false;
	}

	@Override
	public JavaType<?> getProxyJavaType() {
		return componentJavaType;
	}

	@Override
	public JavaType<?> getLoadJavaType() {
		return componentJavaType;
	}

	@Override
	public void visitEntityNameResolvers(Consumer<EntityNameResolver> consumer) {
		consumer.accept(CFCEntityNameResolver.INSTANCE);
	}
}
