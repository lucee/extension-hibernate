package org.lucee.extension.orm.hibernate.tuplizer.accessors;

import java.lang.reflect.Member;
import java.lang.reflect.Method;
import java.util.Map;

import org.hibernate.HibernateException;
import org.hibernate.SessionFactory;
import org.hibernate.engine.spi.SessionImplementor;
import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.metadata.ClassMetadata;
import org.hibernate.property.access.spi.Getter;
import org.hibernate.type.Type;
import org.lucee.extension.orm.hibernate.HibernateCaster;
import org.lucee.extension.orm.hibernate.HibernateORMEngine;
import org.lucee.extension.orm.hibernate.HibernatePageException;
import org.lucee.extension.orm.hibernate.util.CommonUtil;
import org.lucee.extension.orm.hibernate.util.HibernateUtil;

import lucee.loader.engine.CFMLEngineFactory;
import lucee.runtime.Component;
import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMSession;
import lucee.runtime.type.Collection.Key;

public class CFCGetter implements Getter {

    private Key key;
    private Type type;
    private String entityName;

    /**
     * Constructor of the class
     *
     * @param key
     *            Persistent property name
     * @param type
     *            Persistent property type
     * @param entityName
     *            Name of the Hibernate entity to retrieve the value from
     */
    public CFCGetter(String key, Type type, String entityName) {
        this.key = CommonUtil.createKey(key);
        this.type = type;
        this.entityName = entityName;
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
            SessionFactory sf = (SessionFactory) session.getRawSessionFactory(dsn);
            ClassMetadata metaData = sf.getClassMetadata(name);
            Type type = HibernateUtil.getPropertyType(metaData, key.getString());

            Object rtn = cfc.getComponentScope().get(key, null);
            return HibernateCaster.toSQL(type, rtn, null);
        } catch (PageException pe) {
            throw new HibernatePageException(pe);
        }
    }

    public HibernateORMEngine getHibernateORMEngine() {
        try {
            // TODO better impl
            return HibernateUtil.getORMEngine(CommonUtil.pc());
        } catch (PageException e) {
        }

        return null;
    }

    // was used in previous versions, we keep it just in case
    public Object getForInsert(Object trg, Map map, SessionImplementor si) throws HibernateException {
        return get(trg);// MUST better solution? this is from MapGetter
    }

    @Override
    public Object getForInsert(Object trg, Map map, SharedSessionContractImplementor ssci) {
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