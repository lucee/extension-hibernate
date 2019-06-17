package org.lucee.extension.orm.hibernate.util;

import java.lang.reflect.Method;
import java.nio.charset.Charset;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import lucee.commons.io.res.Resource;
import lucee.loader.engine.CFMLEngineFactory;
import lucee.runtime.exp.PageException;

public class XMLUtil {

	public static InputSource toInputSource(Object obj) throws PageException {
		// FUTURE use interface from loader
		try {
			Class<?> clazz = CFMLEngineFactory.getInstance().getClassUtil().loadClass("lucee.runtime.text.xml.XMLUtil");
			Method method = clazz.getMethod("toInputSource", new Class[] { Object.class });
			return (InputSource) method.invoke(null, new Object[] { obj });
		}
		catch (Exception e) {
			throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
		}
	}

	public static InputSource toInputSource(Resource res, Charset cs) throws PageException {
		// FUTURE use interface from loader
		try {
			Class<?> clazz = CFMLEngineFactory.getInstance().getClassUtil().loadClass("lucee.runtime.text.xml.XMLUtil");
			Method method = clazz.getMethod("toInputSource", new Class[] { Resource.class, Charset.class });
			return (InputSource) method.invoke(null, new Object[] { res, cs });
		}
		catch (Exception e) {
			throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
		}
	}

	public static final Document parse(InputSource xml, InputSource validator, boolean isHtml) throws PageException {
		// FUTURE use interface from loader
		try {
			Class<?> clazz = CFMLEngineFactory.getInstance().getClassUtil().loadClass("lucee.runtime.text.xml.XMLUtil");
			Method method = clazz.getMethod("parse", new Class[] { InputSource.class, InputSource.class, boolean.class });
			return (Document) method.invoke(null, new Object[] { xml, validator, isHtml });
		}
		catch (Exception e) {
			throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
		}
	}

	public static Document newDocument() throws PageException {
		// FUTURE use interface from loader
		try {
			Class<?> clazz = CFMLEngineFactory.getInstance().getClassUtil().loadClass("lucee.runtime.text.xml.XMLUtil");
			Method method = clazz.getMethod("newDocument", new Class[] {});
			return (Document) method.invoke(null, new Object[] {});
		}
		catch (Exception e) {
			throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
		}
	}

	// toString(node, omitXMLDecl, indent, publicId, systemId, encoding);
	public static String toString(NodeList nodeList, boolean omitXMLDecl, boolean indent) throws PageException {
		// FUTURE use interface from loader
		try {
			Class<?> clazz = CFMLEngineFactory.getInstance().getClassUtil().loadClass("lucee.runtime.text.xml.XMLCaster");
			Method method = clazz.getMethod("toString", new Class[] { NodeList.class, boolean.class, boolean.class });
			return (String) method.invoke(null, new Object[] { nodeList, omitXMLDecl, indent });
		}
		catch (Exception e) {
			throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
		}
	}

	// toString(node, omitXMLDecl, indent, publicId, systemId, encoding);
	public static String toString(Node node, boolean omitXMLDecl, boolean indent, String publicId, String systemId, String encoding) throws PageException {
		// FUTURE use interface from loader
		try {
			Class<?> clazz = CFMLEngineFactory.getInstance().getClassUtil().loadClass("lucee.runtime.text.xml.XMLCaster");
			Method method = clazz.getMethod("toString", new Class[] { Node.class, boolean.class, boolean.class, String.class, String.class, String.class });
			return (String) method.invoke(null, new Object[] { node, omitXMLDecl, indent, publicId, systemId, encoding });
		}
		catch (Exception e) {
			throw CFMLEngineFactory.getInstance().getCastUtil().toPageException(e);
		}
	}

	public static Node toNode(Object value) throws PageException {
		if (value instanceof Node) return (Node) value;
		return parse(toInputSource(value), null, false);
	}

	public static Document getDocument(Node node) {
		if (node instanceof Document) return (Document) node;
		return node.getOwnerDocument();
	}

	public static void setFirst(Node parent, Node node) {
		Node first = parent.getFirstChild();
		if (first != null) parent.insertBefore(node, first);
		else parent.appendChild(node);
	}

}
