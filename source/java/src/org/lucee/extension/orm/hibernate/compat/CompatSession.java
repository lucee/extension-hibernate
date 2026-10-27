package org.lucee.extension.orm.hibernate.compat;

import java.io.Serializable;
import java.util.Map;
import java.util.Set;

import org.hibernate.LockMode;
import org.hibernate.LockOptions;
import org.hibernate.Session;
import org.hibernate.query.NativeQuery;

/**
 * Synthetic interface enumerating the H5.6-era Session methods removed in
 * Hibernate 6/7 that real-world CFML code (cborm, ColdBox, Slatwall, custom
 * apps) still calls. The wrapper proxy at {@link CompatSessionWrapper}
 * implements this interface alongside {@link Session} and
 * {@link org.hibernate.engine.spi.SessionImplementor} so CFML reflection
 * (which walks declared interface methods) sees the legacy method names.
 *
 * <p>Empirical surface: 32 overloads across 9 families per the H5.6 → H7.3
 * reflection diff at {@code tests/compat/sessionApiSurface/}. Of those 9
 * families, 8 are mechanical (declared and routed below); the 9th
 * ({@code createCriteria}) is a plug-in family handled separately via
 * {@code ormSettings.sessionShim}.
 *
 * <p>The {@code get(...)} family is intentionally NOT declared here. H7 keeps
 * the {@code get(...,Object,...)} overloads; Lucee dispatch resolves
 * {@code session.get("Name", id)} to those automatically. Verified via
 * {@code tests/compat/sessionApiSurface/getDispatch.cfm}.
 *
 * @see CompatSessionWrapper
 */
public interface CompatSession extends Session {

	// --- save → persist + return generated id ---
	Serializable save(Object entity);
	Serializable save(String entityName, Object entity);

	// --- update → merge ---
	void update(Object entity);
	void update(String entityName, Object entity);

	// --- saveOrUpdate → persist if transient, else merge ---
	void saveOrUpdate(Object entity);
	void saveOrUpdate(String entityName, Object entity);

	// --- delete → remove (entity-name and SPI overloads drop their extra args) ---
	void delete(Object entity);
	void delete(String entityName, Object entity);
	void delete(String entityName, Object entity, boolean isCascadeDeleteEnabled, Set<Object> transientEntities);

	// --- load — NOT shimmed. Excluded after `gh search code --extension cfc
	//     'session.load('` returned zero real-world CFML callers (2026-04-29).
	//     H7's Session also still has load(Object existingInstance, Object id)
	//     with void return, which interferes with Lucee's overload dispatch when
	//     other load(...) overloads share the same arity. CFML callers needing
	//     the H5 "load by name" semantics should call getReference directly. ---

	// --- refresh: H5-only forms (H7 native overloads pass through unchanged) ---
	void refresh(Object object, LockMode lockMode);
	void refresh(String entityName, Object object);
	void refresh(String entityName, Object object, LockOptions lockOptions);
	void refresh(String entityName, Object object, Map<String, Object> readOnlyProperties);

	// --- createSQLQuery → createNativeQuery ---
	@SuppressWarnings("rawtypes")
	NativeQuery createSQLQuery(String queryString);

	// --- getNamedSQLQuery → createNamedQuery (returns the JPA Query, callers
	//     bind it duck-typed; we declare NativeQuery for the closest H5 shape) ---
	@SuppressWarnings("rawtypes")
	NativeQuery getNamedSQLQuery(String name);
}
