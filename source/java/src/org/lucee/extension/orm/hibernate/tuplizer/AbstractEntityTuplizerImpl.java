package org.lucee.extension.orm.hibernate.tuplizer;

import java.io.Serializable;
import java.util.HashMap;

import org.hibernate.EntityMode;
import org.hibernate.EntityNameResolver;
import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SessionFactoryImplementor;
import org.hibernate.engine.spi.SessionImplementor;
import org.hibernate.mapping.PersistentClass;
import org.hibernate.mapping.Property;
import org.hibernate.metamodel.binding.AttributeBinding;
import org.hibernate.metamodel.binding.EntityBinding;
import org.hibernate.property.Getter;
import org.hibernate.property.PropertyAccessor;
import org.hibernate.property.Setter;
import org.hibernate.proxy.ProxyFactory;
import org.hibernate.tuple.Instantiator;
import org.hibernate.tuple.entity.AbstractEntityTuplizer;
import org.hibernate.tuple.entity.EntityMetamodel;
import org.lucee.extension.orm.hibernate.CommonUtil;
import org.lucee.extension.orm.hibernate.HBMCreator;
import org.lucee.extension.orm.hibernate.HibernateCaster;
import org.lucee.extension.orm.hibernate.HibernateUtil;
import org.lucee.extension.orm.hibernate.tuplizer.accessors.CFCAccessor;
import org.lucee.extension.orm.hibernate.tuplizer.proxy.CFCHibernateProxyFactory;

import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.ComponentScope;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Struct;


public class AbstractEntityTuplizerImpl extends AbstractEntityTuplizer {

	private static CFCAccessor accessor=new CFCAccessor();
	
	public AbstractEntityTuplizerImpl(EntityMetamodel entityMetamodel, PersistentClass persistentClass) {
		super(entityMetamodel, persistentClass);
	}

	@Override
	public Serializable getIdentifier(Object entity, SessionImplementor arg1) {
		return toIdentifier(super.getIdentifier(entity, arg1));
	}
	
	@Override
	public Serializable getIdentifier(Object entity) throws HibernateException {
		return toIdentifier(super.getIdentifier(entity));
	}

	private Serializable toIdentifier(Serializable id) {
		if(id instanceof Component) {
			HashMap<String, Object> map = new HashMap<String, Object>();
			Component cfc=(Component) id;
			ComponentScope scope = cfc.getComponentScope();
			lucee.runtime.component.Property[] props = HibernateUtil.getIDProperties(cfc, true,true);
			lucee.runtime.component.Property p;
			String name;
			Object value;
			for(int i=0;i<props.length;i++){
				p=props[i];
				name=p.getName();
				value=scope.get(CommonUtil.createKey(name),null);
				String type=p.getType();
				if(CommonUtil.isAnyType(type)) {
					type="string";
					try {
						Object o=p.getMetaData();
						if(o instanceof Struct) {
							Struct meta=(Struct) o;
							String gen = CommonUtil.toString(meta.get("generator", null),null);
							if(!Util.isEmpty(gen)){
								type=HBMCreator.getDefaultTypeForGenerator(gen, "string");
							}
						}
					}
					catch (Throwable t) {}
				}

				try {
					value=HibernateCaster.toHibernateValue(CFMLEngineFactory.getInstance().getThreadPageContext(), value, type);
				}
				catch (PageException pe) {}

				map.put(name, value);
			}
			return map;
		}
		return id;
	}


	@Override
	protected Instantiator buildInstantiator(PersistentClass persistentClass) {
		return new CFCInstantiator(persistentClass);
	}
	
	/**
	 * return accessors 
	 * @param mappedProperty
	 * @return
	 */
	private PropertyAccessor buildPropertyAccessor(Property mappedProperty) {
		if ( mappedProperty.isBackRef() ) {
			PropertyAccessor ac = mappedProperty.getPropertyAccessor(null);
			if(ac!=null) return ac;
		}
		return accessor;
	}
	private PropertyAccessor buildPropertyAccessor(AttributeBinding ab) {
		return accessor;
	}

	
	@Override
	protected Getter buildPropertyGetter(Property mappedProperty, PersistentClass mappedEntity) {
		return buildPropertyAccessor(mappedProperty).getGetter( null, mappedProperty.getName() );
	}

	@Override
	protected Getter buildPropertyGetter(AttributeBinding ab) {
		return buildPropertyAccessor( ab ).getGetter(null,ab.getAttribute().getName());
	}

	
	@Override
	protected Setter buildPropertySetter(Property mappedProperty, PersistentClass mappedEntity) {
		return buildPropertyAccessor(mappedProperty).getSetter( null, mappedProperty.getName() );
	}
	
	@Override
	protected Setter buildPropertySetter(AttributeBinding ab) {
		return buildPropertyAccessor( ab ).getSetter(null,ab.getAttribute().getName());
	}
	
	@Override
	protected ProxyFactory buildProxyFactory(PersistentClass pc, Getter arg1,Setter arg2) {
		CFCHibernateProxyFactory pf = new CFCHibernateProxyFactory();
		pf.postInstantiate(pc);
		
		return pf;
	}

	@Override
	public String determineConcreteSubclassEntityName(Object entityInstance, SessionFactoryImplementor factory) {
		return CFCEntityNameResolver.INSTANCE.resolveEntityName(entityInstance);
	}

	@Override
	public EntityNameResolver[] getEntityNameResolvers() {
		return new EntityNameResolver[] { CFCEntityNameResolver.INSTANCE };
	}

	@Override
	public Class getConcreteProxyClass() {
		return Component.class;// ????
	}

	@Override
	public Class getMappedClass() {
		return Component.class; // ????
	}

	@Override
	public EntityMode getEntityMode() {
		return EntityMode.MAP;
	}

	@Override
	public boolean isInstrumented() {
		return false; // TODO ???
	}

	@Override
	protected Instantiator buildInstantiator(EntityBinding arg0) {
		// TODO ???
		return null;
	}

	

	@Override
	protected ProxyFactory buildProxyFactory(EntityBinding arg0, Getter arg1, Setter arg2) {
		// TODO ???
		return null;
	}

}
