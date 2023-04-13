package com.ortussolutions.hibernate.functions;

import com.ortussolutions.hibernate.util.CommonUtil;
import com.ortussolutions.hibernate.util.ORMUtil;

import lucee.runtime.PageContext;
import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMSession;

public class EntityLoadByPK {
    public static Object call(PageContext pc, String name, Object oID) throws PageException {
        ORMSession session = ORMUtil.getSession(pc);
        String id;
        if (CommonUtil.isBinary(oID))
            id = CommonUtil.toBase64(oID);
        else
            id = CommonUtil.toString(oID);
        return session.load(pc, name, id);
        // FUTURE call instead load(..,..,OBJECT);
    }
}