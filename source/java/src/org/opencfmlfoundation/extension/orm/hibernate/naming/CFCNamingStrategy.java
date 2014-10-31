package org.opencfmlfoundation.extension.orm.hibernate.naming;

import railo.loader.engine.CFMLEngine;
import railo.loader.engine.CFMLEngineFactory;
import railo.runtime.Component;
import railo.runtime.exp.PageException;
import railo.runtime.orm.naming.NamingStrategy;
import railo.runtime.type.UDF;

public class CFCNamingStrategy implements NamingStrategy {
	
	Component cfc;
	
	
	public CFCNamingStrategy(String cfcName) throws PageException{
		this.cfc=CFMLEngineFactory.getInstance().getThreadPageContext().loadComponent(cfcName);
	}
	
	
	public Component getComponent() {
		return cfc;
	}


	@Override
	public String convertTableName(String tableName) {
		return call("getTableName",tableName);
	}

	@Override
	public String convertColumnName(String columnName) {
		return call("getColumnName",columnName);
	}

	private String call(String functionName, String name) {
		Object res = cfc.get(functionName,null);
		if(!(res instanceof UDF)) return name;
		CFMLEngine engine = CFMLEngineFactory.getInstance();
		try {
			return engine.getCastUtil().toString(cfc.call(engine.getThreadPageContext(), functionName, new Object[]{name}));
		} catch (PageException pe) {
			throw engine.getCastUtil().toPageRuntimeException(pe);
		}
	}

	@Override
	public String getType() {
		return "cfc";
	}

}
