package org.lucee.extension.orm.hibernate.tuplizer;

import org.hibernate.property.access.spi.PropertyAccess;
import org.hibernate.property.access.spi.PropertyAccessStrategy;

/**
 * Marker {@link PropertyAccessStrategy} for CFC entities. The actual {@link PropertyAccess}
 * instances are built directly by {@link CFCRepresentationStrategy#resolvePropertyAccess} —
 * this class exists only so {@code PropertyAccess#getPropertyAccessStrategy()} has a stable
 * non-null reference. Hibernate never invokes {@link #buildPropertyAccess} for CFC entities.
 */
public class CFCPropertyAccessStrategy implements PropertyAccessStrategy {

	public static final CFCPropertyAccessStrategy INSTANCE = new CFCPropertyAccessStrategy();

	@Override
	public PropertyAccess buildPropertyAccess(Class<?> containerJavaType, String propertyName, boolean setterRequired) {
		throw new UnsupportedOperationException(
				"CFC PropertyAccess is built via CFCRepresentationStrategy.resolvePropertyAccess(Property)");
	}
}
