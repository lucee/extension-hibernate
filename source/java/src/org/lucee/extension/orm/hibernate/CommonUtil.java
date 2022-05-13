package org.lucee.extension.orm.hibernate;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.Serializable;
import java.io.StringWriter;
import java.io.Writer;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.nio.charset.Charset;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

import org.hibernate.JDBCException;
import org.hibernate.exception.ConstraintViolationException;
import org.lucee.extension.orm.hibernate.util.XMLUtil;
import org.w3c.dom.Document;
import org.w3c.dom.Node;

import lucee.commons.io.res.Resource;
import lucee.commons.lang.types.RefBoolean;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.loader.util.Util;
import lucee.runtime.Component;
import lucee.runtime.Mapping;
import lucee.runtime.PageContext;
import lucee.runtime.component.Property;
import lucee.runtime.config.Config;
import lucee.runtime.db.DataSource;
import lucee.runtime.db.DatasourceConnection;
import lucee.runtime.db.SQL;
import lucee.runtime.db.SQLItem;
import lucee.runtime.exp.PageException;
import lucee.runtime.type.Array;
import lucee.runtime.type.Collection;
import lucee.runtime.type.Collection.Key;
import lucee.runtime.type.Query;
import lucee.runtime.type.Struct;
import lucee.runtime.type.dt.DateTime;
import lucee.runtime.type.scope.Argument;
import lucee.runtime.util.Cast;
import lucee.runtime.util.Creation;
import lucee.runtime.util.DBUtil;
import lucee.runtime.util.Decision;
import lucee.runtime.util.ORMUtil;
import lucee.runtime.util.Operation;

public class CommonUtil {

	public static final Key ENTITY_NAME = CommonUtil.createKey("entityname");
	public static final Key FIELDTYPE = CommonUtil.createKey("fieldtype");
	public static final Key POST_INSERT = CommonUtil.createKey("postInsert");
	public static final Key POST_UPDATE = CommonUtil.createKey("postUpdate");
	public static final Key PRE_DELETE = CommonUtil.createKey("preDelete");
	public static final Key POST_DELETE = CommonUtil.createKey("postDelete");
	public static final Key PRE_LOAD = CommonUtil.createKey("preLoad");
	public static final Key POST_LOAD = CommonUtil.createKey("postLoad");
	public static final Key PRE_UPDATE = CommonUtil.createKey("preUpdate");
	public static final Key PRE_INSERT = CommonUtil.createKey("preInsert");
	public static final Key ON_FLUSH = CommonUtil.createKey("onFlush");
	public static final Key ON_AUTO_FLUSH = CommonUtil.createKey("onAutoFlush");
	public static final Key ON_CLEAR = CommonUtil.createKey("onClear");
	public static final Key ON_DELETE = CommonUtil.createKey("onDelete");
	public static final Key ON_DIRTY_CHECK = CommonUtil.createKey("onDirtyCheck");
	public static final Key ON_EVICT = CommonUtil.createKey("onEvict");

	public static final Key INIT = CommonUtil.createKey("init");
	private static final short INSPECT_UNDEFINED = (short) 4; /* ConfigImpl.INSPECT_UNDEFINED */
	private static final Class<?>[] ZEROC = new Class<?>[] {};
	private static final Object[] ZEROO = new Object[] {};
	private static final Class<?>[] GET_DSCONN = new Class[] { PageContext.class, DataSource.class, String.class, String.class, boolean.class };
	private static final Class<?>[] REL_DSCONN = new Class[] { PageContext.class, DatasourceConnection.class, boolean.class };
	// private static final Class<?>[] GET_CONN = new Class[] { PageContext.class, DataSource.class,
	// String.class, String.class };
	// private static final Class<?>[] REL_CONN = new Class[] { PageContext.class,
	// DatasourceConnection.class };
	// releaseConnection(pageContext, dc);
	private static Charset _charset;

	public static Charset _UTF8;
	// public static Charset ISO88591;
	public static Charset _UTF16BE;
	public static Charset _UTF16LE;

	public static Charset getCharset() {
		if (_charset == null) {
			String strCharset = System.getProperty("file.encoding");
			if (strCharset == null || strCharset.equalsIgnoreCase("MacRoman")) strCharset = "cp1252";

			if (strCharset.equalsIgnoreCase("utf-8")) _charset = UTF8();
			else _charset = toCharset(strCharset);
		}
		return _charset;
	}

	public static Charset UTF8() {
		if (_UTF8 == null) _UTF8 = toCharset("UTF-8");
		return _UTF8;
	}

	private static Charset UTF16LE() {
		if (_UTF16LE == null) _UTF16LE = toCharset("UTF-16LE");
		return _UTF16LE;
	}

	private static Charset UTF16BE() {
		if (_UTF16BE == null) _UTF16BE = toCharset("UTF-16BE");
		return _UTF16BE;
	}

	private static Charset toCharset(String charset) {
		try {
			return CFMLEngineFactory.getInstance().getCastUtil().toCharset(charset);
		}
		catch (PageException pe) {
			throw CFMLEngineFactory.getInstance().getExceptionUtil().createPageRuntimeException(pe);
		}
	}

	private static Cast caster;
	private static Decision decision;
	private static Creation creator;
	private static Operation op;
	private static lucee.runtime.util.XMLUtil xml;
	private static lucee.runtime.util.ListUtil list;
	private static DBUtil db;
	private static ORMUtil orm;
	// private static Method mGetDataSourceManager;
	// private static Method mGetConnection;
	// private static Method mReleaseConnection;

	private static Method mGetDatasourceConnection;
	private static Method mReleaseDatasourceConnection;

	public static Object castTo(PageContext pc, Class trgClass, Object obj) throws PageException {
		return caster().castTo(pc, trgClass, obj);
	}

	public static Array toArray(Object obj) throws PageException {
		return caster().toArray(obj);
	}

	public static Array toArray(Object obj, Array defaultValue) {
		return caster().toArray(obj, defaultValue);
	}

	public static Boolean toBoolean(String str) throws PageException {
		return caster().toBoolean(str);
	}

	public static Boolean toBoolean(String str, Boolean defaultValue) {
		return caster().toBoolean(str, defaultValue);
	}

	public static Boolean toBoolean(Object obj) throws PageException {
		return caster().toBoolean(obj);
	}

	public static Boolean toBoolean(Object obj, Boolean defaultValue) {
		return caster().toBoolean(obj, defaultValue);
	}

	public static Boolean toBooleanValue(String str) throws PageException {
		return caster().toBooleanValue(str);
	}

	public static Boolean toBooleanValue(String str, Boolean defaultValue) {
		return caster().toBooleanValue(str, defaultValue);
	}

	public static boolean toBooleanValue(Object obj) throws PageException {
		return caster().toBooleanValue(obj);
	}

	public static boolean toBooleanValue(Object obj, boolean defaultValue) {
		return caster().toBooleanValue(obj, defaultValue);
	}

	public static Component toComponent(Object obj) throws PageException {
		return caster().toComponent(obj);
	}

	public static Component toComponent(Object obj, Component defaultValue) {
		return caster().toComponent(obj, defaultValue);
	}

	public static Object toList(String[] arr, String delimiter) {
		return list().toList(arr, delimiter);
	}

	public static String toString(Object obj, String defaultValue) {
		return caster().toString(obj, defaultValue);
	}

	public static String toString(Object obj) throws PageException {
		return caster().toString(obj);
	}

	public static String toString(boolean b) {
		return caster().toString(b);
	}

	public static String toString(double d) {
		return caster().toString(d);
	}

	public static String toString(int i) {
		return caster().toString(i);
	}

	public static String toString(long l) {
		return caster().toString(l);
	}

	/**
	 * reads String data from File
	 * 
	 * @param file
	 * @param charset
	 * @return readed string
	 * @throws IOException
	 */
	public static String toString(Resource file, Charset charset) throws IOException {
		Reader r = null;
		try {
			r = getReader(file, charset);
			String str = toString(r);
			return str;
		}
		finally {
			closeEL(r);
		}
	}

	public static String toString(Reader reader) throws IOException {
		StringWriter sw = new StringWriter(512);
		copy(toBufferedReader(reader), sw);
		sw.close();
		return sw.toString();
	}

	public static BufferedReader toBufferedReader(Reader r) {
		if (r instanceof BufferedReader) return (BufferedReader) r;
		return new BufferedReader(r);
	}

	private static final void copy(Reader r, Writer w) throws IOException {
		copy(r, w, 0xffff);
	}

	private static final void copy(Reader r, Writer w, int blockSize) throws IOException {
		char[] buffer = new char[blockSize];
		int len;

		while ((len = r.read(buffer)) != -1)
			w.write(buffer, 0, len);
	}

	public static Reader getReader(Resource res, Charset charset) throws IOException {
		InputStream is = null;
		try {
			is = res.getInputStream();
			boolean markSupported = is.markSupported();
			if (markSupported) is.mark(4);
			int first = is.read();
			int second = is.read();
			// FE FF UTF-16, big-endian
			if (first == 0xFE && second == 0xFF) {
				return _getReader(is, UTF16BE());
			}
			// FF FE UTF-16, little-endian
			if (first == 0xFF && second == 0xFE) {
				return _getReader(is, UTF16LE());
			}

			int third = is.read();
			// EF BB BF UTF-8
			if (first == 0xEF && second == 0xBB && third == 0xBF) {
				// is.reset();
				return _getReader(is, UTF8());
			}

			if (markSupported) {
				is.reset();
				return _getReader(is, charset);
			}
		}
		catch (IOException ioe) {
			closeEL(is);
			throw ioe;
		}

		// when mark not supported return new reader
		closeEL(is);
		is = null;
		try {
			is = res.getInputStream();
		}
		catch (IOException ioe) {
			closeEL(is);
			throw ioe;
		}
		return _getReader(is, charset);
	}

	private static Reader _getReader(InputStream is, Charset cs) {
		if (cs == null) cs = getCharset();
		return new BufferedReader(new InputStreamReader(is, cs));
	}

	public static String[] toStringArray(String list, String delimiter) {
		return list().toStringArray(list().toArray(list, delimiter), ""); // TODO better
	}

	public static Float toFloat(Object obj) throws PageException {
		return caster().toFloat(obj);
	}

	public static Float toFloat(Object obj, Float defaultValue) {
		return caster().toFloat(obj, defaultValue);
	}

	public static float toFloatValue(Object obj) throws PageException {
		return caster().toFloatValue(obj);
	}

	public static float toFloatValue(Object obj, float defaultValue) {
		return caster().toFloatValue(obj, defaultValue);
	}

	public static Double toDouble(Object obj) throws PageException {
		return caster().toDouble(obj);
	}

	public static Double toDouble(Object obj, Double defaultValue) {
		return caster().toDouble(obj, defaultValue);
	}

	public static double toDoubleValue(Object obj) throws PageException {
		return caster().toDoubleValue(obj);
	}

	public static double toDoubleValue(Object obj, double defaultValue) {
		return caster().toDoubleValue(obj, defaultValue);
	}

	public static BigDecimal toBigDecimal(Object obj) throws PageException {
		return caster().toBigDecimal(obj);
	}

	public static BigDecimal toBigDecimal(Object obj, BigDecimal defaultValue) {
		return caster().toBigDecimal(obj, defaultValue);
	}

	public static Short toShort(Object obj) throws PageException {
		return caster().toShort(obj);
	}

	public static Short toShort(Object obj, Short defaultValue) {
		return caster().toShort(obj, defaultValue);
	}

	public static double toShortValue(Object obj) throws PageException {
		return caster().toShortValue(obj);
	}

	public static double toShortValue(Object obj, short defaultValue) {
		return caster().toShortValue(obj, defaultValue);
	}

	public static Integer toInteger(Object obj) throws PageException {
		return caster().toInteger(obj);
	}

	public static Integer toInteger(Object obj, Integer defaultValue) {
		return caster().toInteger(obj, defaultValue);
	}

	public static Long toLong(Object obj) throws PageException {
		return caster().toLong(obj);
	}

	public static Long toLong(Object obj, Long defaultValue) {
		return caster().toLong(obj, defaultValue);
	}

	public static long toLongValue(Object obj) throws PageException {
		return caster().toLongValue(obj);
	}

	public static long toLongValue(Object obj, long defaultValue) {
		return caster().toLongValue(obj, defaultValue);
	}

	public static byte[] toBinary(Object obj) throws PageException {
		return caster().toBinary(obj);
	}

	public static byte[] toBinary(Object obj, byte[] defaultValue) {
		return caster().toBinary(obj, defaultValue);
	}

	public static int toIntValue(Object obj) throws PageException {
		return caster().toIntValue(obj);
	}

	public static int toIntValue(Object obj, int defaultValue) {
		return caster().toIntValue(obj, defaultValue);
	}

	public static Array toArray(Argument arg) {
		Array trg = createArray();
		int[] keys = arg.intKeys();
		for (int i = 0; i < keys.length; i++) {
			trg.setEL(keys[i], arg.get(keys[i], null));
		}
		return trg;
	}

	public static PageException toPageException(Throwable t) {
		PageException pe = caster().toPageException(t);
		if (t instanceof org.hibernate.HibernateException) {
			org.hibernate.HibernateException he = (org.hibernate.HibernateException) t;
			Throwable cause = he.getCause();
			if (cause != null) {
				pe = caster().toPageException(cause);
				ExceptionUtil.setAdditional(pe, CommonUtil.createKey("hibernate exception"), t);
			}
		}
		if (t instanceof JDBCException) {
			JDBCException je = (JDBCException) t;
			ExceptionUtil.setAdditional(pe, CommonUtil.createKey("sql"), je.getSQL());
		}
		if (t instanceof ConstraintViolationException) {
			ConstraintViolationException cve = (ConstraintViolationException) t;
			if (!Util.isEmpty(cve.getConstraintName())) {
				ExceptionUtil.setAdditional(pe, CommonUtil.createKey("constraint name"), cve.getConstraintName());
			}
		}
		return pe;
	}

	public static Serializable toSerializable(Object obj) throws PageException {
		return caster().toSerializable(obj);
	}

	public static Serializable toSerializable(Object obj, Serializable defaultValue) {
		return caster().toSerializable(obj, defaultValue);
	}

	public static Struct toStruct(Object obj) throws PageException {
		return caster().toStruct(obj);
	}

	public static Struct toStruct(Object obj, Struct defaultValue) {
		return caster().toStruct(obj, defaultValue);
	}

	public static SQLItem toSQLItem(Object value, int type) {
		return db().toSQLItem(value, type);
	}

	public static SQL toSQL(String sql, SQLItem[] items) {
		return db().toSQL(sql, items);
	}

	public static Object toSqlType(SQLItem item) throws PageException {
		return db().toSqlType(item);
	}

	public static Object[] toNativeArray(Object obj) throws PageException {
		return caster().toNativeArray(obj);
	}

	public static Key toKey(String str) {
		return caster().toKey(str);
	}

	public static String toTypeName(Object obj) {
		return caster().toTypeName(obj);
	}

	public static Node toXML(Object obj) throws PageException {
		return XMLUtil.toNode(obj);
	}
	/*
	 * public static Node toXML(Object obj, Node defaultValue) { return
	 * caster().toXML(obj,defaultValue); }
	 */

	public static Document toDocument(Resource res, Charset cs) throws PageException {
		return XMLUtil.parse(XMLUtil.toInputSource(res, cs), null, false);
	}

	public static boolean isArray(Object obj) {
		return decision().isArray(obj);
	}

	public static boolean isStruct(Object obj) {
		return decision().isStruct(obj);
	}

	public static boolean isAnyType(String type) {
		return decision().isAnyType(type);
	}

	public static Array createArray() {
		return creator().createArray();
	}

	public static DateTime createDateTime(long time) {
		return creator().createDateTime(time);
	}

	public static Property createProperty(String name, String type) {
		return creator().createProperty(name, type);
	}

	public static Struct createStruct() {
		return creator().createStruct();
	}

	public static Collection.Key createKey(String key) {
		return creator().createKey(key);
	}

	public static Query createQuery(Collection.Key[] columns, int rows, String name) throws PageException {
		return creator().createQuery(columns, rows, name);
	}

	public static Query createQuery(Collection.Key[] columns, String[] types, int rows, String name) throws PageException {
		return creator().createQuery(columns, types, rows, name);
	}

	public static Query createQuery(Array names, Array types, int rows, String name) throws PageException {
		Collection.Key[] knames = new Collection.Key[names.size()];
		String[] ktypes = new String[types.size()];
		for (int i = names.size() - 1; i >= 0; i--) {
			knames[i] = caster().toKey(names.getE(i + 1));
			ktypes[i] = caster().toString(types.getE(i + 1));
		}
		return creator().createQuery(knames, ktypes, rows, name);
	}

	public static RefBoolean createRefBoolean() {
		return new RefBooleanImpl();
	}

	public static Key[] keys(Collection coll) {
		if (coll == null) return new Key[0];
		Iterator<Key> it = coll.keyIterator();
		List<Key> rtn = new ArrayList<Key>();
		if (it != null) while (it.hasNext()) {
			rtn.add(it.next());
		}
		return rtn.toArray(new Key[rtn.size()]);
	}

	private static Creation creator() {
		if (creator == null) creator = CFMLEngineFactory.getInstance().getCreationUtil();
		return creator;
	}

	private static Decision decision() {
		if (decision == null) decision = CFMLEngineFactory.getInstance().getDecisionUtil();
		return decision;
	}

	private static Cast caster() {
		if (caster == null) caster = CFMLEngineFactory.getInstance().getCastUtil();
		return caster;
	}

	private static Operation op() {
		if (op == null) op = CFMLEngineFactory.getInstance().getOperatonUtil();
		return op;
	}

	private static lucee.runtime.util.ListUtil list() {
		if (list == null) list = CFMLEngineFactory.getInstance().getListUtil();
		return list;
	}

	private static ORMUtil orm() {
		if (orm == null) orm = CFMLEngineFactory.getInstance().getORMUtil();
		return orm;
	}

	private static DBUtil db() {
		if (db == null) db = CFMLEngineFactory.getInstance().getDBUtil();
		return db;
	}

	/**
	 * represents a SQL Statement with his defined arguments for a prepared statement
	 */
	static class SQLImpl implements SQL {

		private String strSQL;

		/**
		 * Constructor only with SQL String
		 * 
		 * @param strSQL SQL String
		 */
		public SQLImpl(String strSQL) {
			this.strSQL = strSQL;
		}

		public void addItems(SQLItem item) {

		}

		@Override
		public SQLItem[] getItems() {
			return new SQLItem[0];
		}

		@Override
		public int getPosition() {
			return 0;
		}

		@Override
		public void setPosition(int position) {
		}

		@Override
		public String getSQLString() {
			return strSQL;
		}

		@Override
		public void setSQLString(String strSQL) {
			this.strSQL = strSQL;
		}

		@Override
		public String toString() {
			return strSQL;
		}

		@Override
		public String toHashString() {
			return strSQL;
		}
	}

	/**
	 * Integer Type that can be modified
	 */
	public static final class RefBooleanImpl implements RefBoolean {// MUST add interface Castable

		private boolean value;

		public RefBooleanImpl() {
		}

		/**
		 * @param value
		 */
		public RefBooleanImpl(boolean value) {
			this.value = value;
		}

		/**
		 * @param value
		 */
		@Override
		public void setValue(boolean value) {
			this.value = value;
		}

		/**
		 * @return returns value as Boolean Object
		 */
		@Override
		public Boolean toBoolean() {
			return value ? Boolean.TRUE : Boolean.FALSE;
		}

		/**
		 * @return returns value as boolean value
		 */
		@Override
		public boolean toBooleanValue() {
			return value;
		}

		@Override
		public String toString() {
			return value ? "true" : "false";
		}
	}

	public static DataSource getDataSource(PageContext pc, String dsn, DataSource defaultValue) {
		if (Util.isEmpty(dsn, true) || dsn.equals("__default__")) return orm().getDefaultDataSource(pc, defaultValue);
		return pc.getDataSource(dsn.trim(), defaultValue);
	}

	public static DataSource getDataSource(PageContext pc, String name) throws PageException {
		if (Util.isEmpty(name, true)) return orm().getDefaultDataSource(pc);
		return pc.getDataSource(name);
	}

	/*
	 * private static Object getDatasourceManager(PageContext pc) throws PageException { try { if
	 * (mGetDataSourceManager == null || pc.getClass() != mGetDataSourceManager.getDeclaringClass())
	 * mGetDataSourceManager = pc.getClass().getMethod("getDataSourceManager", ZEROC); return
	 * mGetDataSourceManager.invoke(pc, ZEROO); } catch (Exception e) { throw
	 * CFMLEngineFactory.getInstance().getCastUtil().toPageException(e); } }
	 */

	public static DatasourceConnection getDatasourceConnection(PageContext pc, DataSource ds, String user, String pass, boolean transactionSensitive) throws PageException {
		if (transactionSensitive) {
			return pc.getDataSourceManager().getConnection(pc, ds, user, pass);

		}

		DBUtil dbutil = db();
		try {
			if (mGetDatasourceConnection == null || dbutil.getClass() != mGetDatasourceConnection.getDeclaringClass()) {
				mGetDatasourceConnection = dbutil.getClass().getMethod("getDatasourceConnection", GET_DSCONN);
			}
			return (DatasourceConnection) mGetDatasourceConnection.invoke(dbutil, new Object[] { pc, ds, user, pass, false });
		}
		catch (Exception e) {
			throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
		}
		/*
		 * Object manager = getDatasourceManager(pc); try { if (mGetConnection == null || manager.getClass()
		 * != mGetConnection.getDeclaringClass()) { mGetConnection =
		 * manager.getClass().getMethod("getConnection", GET_CONN); } return (DatasourceConnection)
		 * mGetConnection.invoke(manager, new Object[] { pc, ds, user, pass }); } catch (Exception e) {
		 * throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e); }
		 */
	}

	public static void releaseDatasourceConnection(PageContext pc, DatasourceConnection dc, boolean transactionSensitive) throws PageException {
		// print.ds("rel:" + transactionSensitive);
		if (transactionSensitive) {
			pc.getDataSourceManager().releaseConnection(pc, dc);
			return;
		}

		DBUtil dbutil = db();
		try {
			if (mReleaseDatasourceConnection == null || dbutil.getClass() != mReleaseDatasourceConnection.getDeclaringClass()) {
				mReleaseDatasourceConnection = dbutil.getClass().getMethod("releaseDatasourceConnection", REL_DSCONN);
			}
			mReleaseDatasourceConnection.invoke(dbutil, new Object[] { pc, dc, false });
		}
		catch (Exception e) {
			throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
		}

		/*
		 * Object manager = getDatasourceManager(pc); try { if (mReleaseConnection == null ||
		 * manager.getClass() != mReleaseConnection.getDeclaringClass()) { mReleaseConnection =
		 * manager.getClass().getMethod("releaseConnection", REL_CONN); } mReleaseConnection.invoke(manager,
		 * new Object[] { pc, dc }); } catch (Exception e) { throw
		 * CFMLEngineFactory.getInstance().getCastUtil().toPageException(e); }
		 */
	}

	public static Mapping createMapping(Config config, String virtual, String physical) {
		return creator().createMapping(config, virtual, physical, null, INSPECT_UNDEFINED, true, false, false, false, true, true, null, -1, -1);
	}

	public static String last(String list, String delimiter) {
		return list().last(list, delimiter, true);
	}

	public static int listFindNoCaseIgnoreEmpty(String list, String value, char delimiter) {
		return list().findNoCaseIgnoreEmpty(list, value, delimiter);
	}

	public static String[] trimItems(String[] arr) {
		for (int i = 0; i < arr.length; i++) {
			arr[i] = arr[i].trim();
		}
		return arr;
	}

	public static Document getDocument(Node node) {
		return XMLUtil.getDocument(node);
	}

	public static Document newDocument() throws PageException {
		return XMLUtil.newDocument();
	}

	public static void setFirst(Node parent, Node node) {
		XMLUtil.setFirst(parent, node);
	}

	public static Property[] getProperties(Component c, boolean onlyPeristent, boolean includeBaseProperties, boolean preferBaseProperties, boolean inheritedMappedSuperClassOnly) {
		return c.getProperties(onlyPeristent, includeBaseProperties, preferBaseProperties, inheritedMappedSuperClassOnly);
	}

	public static void write(Resource res, String string, Charset cs, boolean append) throws IOException {
		if (cs == null) cs = getCharset();

		Writer writer = null;
		try {
			writer = getWriter(res, cs, append);
			writer.write(string);
		}
		finally {
			closeEL(writer);
		}
	}

	public static Writer getWriter(Resource res, Charset charset, boolean append) throws IOException {
		OutputStream os = null;
		try {
			os = res.getOutputStream(append);
		}
		catch (IOException ioe) {
			closeEL(os);
			throw ioe;
		}
		return getWriter(os, charset);
	}

	public static Writer getWriter(OutputStream os, Charset cs) {
		if (cs == null) cs = getCharset();
		return new BufferedWriter(new OutputStreamWriter(os, getCharset()));
	}

	public static BufferedReader toBufferedReader(Resource res, Charset charset) throws IOException {
		return toBufferedReader(getReader(res, (Charset) null));
	}

	public static boolean equalsComplexEL(Object left, Object right) {
		return op().equalsComplexEL(left, right, false, true);
	}

	public static PageContext pc() {
		return CFMLEngineFactory.getInstance().getThreadPageContext();
	}

	public static Config config() {
		return pc().getConfig();
	}

	public static void closeEL(OutputStream os) {
		if (os != null) {
			try {
				os.close();
			}
			catch (Throwable t) {
				if (t instanceof ThreadDeath) throw (ThreadDeath) t;
			}
		}
	}

	public static void closeEL(Writer w) {
		if (w != null) {
			try {
				w.close();
			}
			catch (Throwable t) {
				if (t instanceof ThreadDeath) throw (ThreadDeath) t;
			}
		}
	}

	public static void closeEL(ResultSet rs) {
		if (rs != null) {
			try {
				rs.close();
			}
			catch (Throwable t) {
				if (t instanceof ThreadDeath) throw (ThreadDeath) t;
			}
		}
	}

	public static void closeEL(InputStream is) {
		try {
			if (is != null) is.close();
		}
		catch (Throwable t) {
			if (t instanceof ThreadDeath) throw (ThreadDeath) t;
		}
	}

	public static void closeEL(Reader r) {
		try {
			if (r != null) r.close();
		}
		catch (Throwable t) {
			if (t instanceof ThreadDeath) throw (ThreadDeath) t;
		}
	}

	public static boolean isRelated(Property property) {
		return orm().isRelated(property);
	}

	public static Object convertToSimpleMap(String paramsStr) {
		return orm().convertToSimpleMap(paramsStr);
	}

	public static String getDataSourceName(PageContext pc, Component cfc) throws PageException {
		return orm().getDataSourceName(pc, cfc);
	}

	public static DataSource getDataSource(PageContext pc, Component cfc) throws PageException {
		return orm().getDataSource(pc, cfc);
	}

	public static boolean equals(Component l, Component r) {
		// TODO Auto-generated method stub
		return orm().equals(l, r);
	}

	public static DataSource getDefaultDataSource(PageContext pc) throws PageException {
		return orm().getDefaultDataSource(pc);
	}

	public static Object getPropertyValue(Component cfc, String name, Object defaultValue) {
		return orm().getPropertyValue(cfc, name, defaultValue);
	}

	public static String toString(Node node, boolean omitXMLDecl, boolean indent, String publicId, String systemId, String encoding) throws PageException {
		return XMLUtil.toString(node, omitXMLDecl, indent, publicId, systemId, encoding);
	}

	public static Locale toLocale(String strLocale) throws PageException {
		return caster().toLocale(strLocale);
	}

	public static TimeZone toTimeZone(Object value, Object obj) throws PageException {
		return caster().toTimeZone(obj);
	}

	public static Character toCharacter(Object value) throws PageException {
		return caster().toCharacter(value);
	}

	public static DateTime toDate(Object value, TimeZone timeZone) throws PageException {
		return caster().toDate(value, timeZone);
	}

	public static Calendar toCalendar(DateTime date, TimeZone timeZone, Locale locale) {
		return caster().toCalendar(date.getTime(), timeZone, locale);
	}
}
