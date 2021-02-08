package org.lucee.extension.orm.hibernate.tuplizer.accessors;

import org.hibernate.property.access.spi.Getter;
import org.hibernate.property.access.spi.PropertyAccess;
import org.hibernate.property.access.spi.PropertyAccessStrategy;
import org.hibernate.property.access.spi.Setter;

public class CFCAccessor implements PropertyAccessStrategy {

	public CFCAccessor() {
	}

	// @Override
	// public Getter getGetter(Class clazz, String propertyName) throws PropertyNotFoundException {
	// return new CFCGetter(propertyName);
	// }
	//
	// /**
	// * {@inheritDoc}
	// */
	// @Override
	// public Setter getSetter(Class clazz, String propertyName) throws PropertyNotFoundException {
	// return new CFCSetter(propertyName);
	// }

	@Override
	public Getter getGetter() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public PropertyAccessStrategy getPropertyAccessStrategy() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Setter getSetter() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public PropertyAccess buildPropertyAccess(Class arg0, String arg1) {
		// TODO Auto-generated method stub
		return null;
	}

}
