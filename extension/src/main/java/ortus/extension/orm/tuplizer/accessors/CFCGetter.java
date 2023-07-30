package ortus.extension.orm.tuplizer.accessors;

import java.lang.reflect.Member;
import java.lang.reflect.Method;
import java.util.Map;

import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.property.access.spi.Getter;
import org.hibernate.type.Type;
import ortus.extension.orm.HibernateCaster;
import ortus.extension.orm.HibernatePageException;
import ortus.extension.orm.util.CommonUtil;

import lucee.runtime.Component;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Collection.Key;

public class CFCGetter implements Getter {

    private Key key;
    private Type type;

    /**
     * Constructor of the class
     *
     * @param key
     *                   Persistent property name
     * @param type
     *                   Persistent property type
     * @param entityName
     *                   Name of the Hibernate entity to retrieve the value from
     */
    public CFCGetter( String key, Type type, String entityName ) {
        this.key        = CommonUtil.createKey( key );
        this.type       = type;
    }

    @Override
    public Object get( Object trg ) throws HibernateException {
        try {
            Component cfc = CommonUtil.toComponent( trg );

            Object rtn = cfc.getComponentScope().get( key, null );
            return HibernateCaster.toSQL( type, rtn, null );
        } catch ( PageException pe ) {
            throw new HibernatePageException( pe );
        }
    }

    @Override
    @SuppressWarnings("rawtypes")
    public Object getForInsert( Object trg, Map map, SharedSessionContractImplementor ssci ) {
        return get( trg );// MUST better solution? this is from MapGetter
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
    @SuppressWarnings("rawtypes")
    public Class getReturnType() {
        return Object.class;// MUST more concrete?
    }

}