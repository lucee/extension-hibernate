package org.opencfmlfoundation.extension.orm.hibernate.tuplizer.accessors;

import java.lang.reflect.Member;
import java.lang.reflect.Method;
import java.util.Map;

import org.hibernate.HibernateException;
import org.hibernate.SessionFactory;
import org.hibernate.engine.SessionImplementor;
import org.hibernate.metadata.ClassMetadata;
import org.hibernate.property.Getter;
import org.hibernate.type.Type;

import railo.loader.engine.CFMLEngineFactory;
import railo.runtime.Component;
import railo.runtime.PageContext;
import railo.runtime.exp.PageException;
import railo.runtime.orm.ORMSession;
import org.opencfmlfoundation.extension.orm.hibernate.CommonUtil;
import org.opencfmlfoundation.extension.orm.hibernate.HibernateCaster;
import org.opencfmlfoundation.extension.orm.hibernate.HibernateORMEngine;
import org.opencfmlfoundation.extension.orm.hibernate.HibernatePageException;
import org.opencfmlfoundation.extension.orm.hibernate.HibernateUtil;
import railo.runtime.type.Collection;
import railo.runtime.type.Collection.Key;
import railo.runtime.util.ORMUtil;

public class CFCGetter implements Getter {

	private Key key;

	/**
	 * Constructor of the class
	 * @param key
	 */
	public CFCGetter(String key){
		this(CommonUtil.createKey(key));
	}
	
	/**
	 * Constructor of the class
	 * @param engine 
	 * @param key
	 */
	public CFCGetter( Collection.Key key){
		this.key=key;
	}
	
	@Override
	public Object get(Object trg) throws HibernateException {
		try {
			// MUST cache this, perhaps when building xml
			PageContext pc = CommonUtil.pc();
			ORMSession session = pc.getORMSession(true);
			Component cfc = CommonUtil.toComponent(trg);
			String dsn = CFMLEngineFactory.getInstance().getORMUtil().getDataSourceName(pc, cfc);
			String name = HibernateCaster.getEntityName(cfc);
			SessionFactory sf=(SessionFactory) session.getRawSessionFactory(dsn);
			ClassMetadata metaData = sf.getClassMetadata(name);
			Type type = HibernateUtil.getPropertyType(metaData, key.getString());

			Object rtn = cfc.getComponentScope().get(key,null);
			return HibernateCaster.toSQL(type, rtn,null);
		} 
		catch (PageException pe) {
			throw new HibernatePageException(pe);
		}
	}
	

	public HibernateORMEngine getHibernateORMEngine(){
		try {
			// TODO better impl
			return HibernateUtil.getORMEngine(CommonUtil.pc());
		} 
		catch (PageException e) {}
			
		return null;
	}
	

	@Override
	public Object getForInsert(Object trg, Map arg1, SessionImplementor arg2)throws HibernateException {
		return get(trg);// MUST better solution? this is from MapGetter
	}

	@Override
	public Member getMember() {
		return null;
	}

	@Override
	public Method getMethod() {
		return null;
	}

	@Override
	public String getMethodName() {
		return null;// MUST macht es sinn den namen zurueck zu geben?
	}

	@Override
	public Class getReturnType() {
		return Object.class;// MUST more concrete?
	}

}
