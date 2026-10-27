package org.lucee.extension.orm.hibernate.tuplizer;

import org.hibernate.property.access.spi.Getter;
import org.hibernate.property.access.spi.PropertyAccess;
import org.hibernate.property.access.spi.PropertyAccessStrategy;
import org.hibernate.property.access.spi.Setter;

/**
 * Pairs a CFC {@link Getter} and {@link Setter} for a single persistent property.
 */
public class CFCPropertyAccess implements PropertyAccess {

	private final Getter getter;
	private final Setter setter;

	public CFCPropertyAccess(Getter getter, Setter setter) {
		this.getter = getter;
		this.setter = setter;
	}

	@Override
	public PropertyAccessStrategy getPropertyAccessStrategy() {
		return CFCPropertyAccessStrategy.INSTANCE;
	}

	@Override
	public Getter getGetter() {
		return getter;
	}

	@Override
	public Setter getSetter() {
		return setter;
	}
}
