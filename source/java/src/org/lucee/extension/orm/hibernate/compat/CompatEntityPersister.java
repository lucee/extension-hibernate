package org.lucee.extension.orm.hibernate.compat;

import org.hibernate.persister.entity.EntityPersister;

/**
 * Synthetic interface re-declaring the H5.6-era {@link EntityPersister} method
 * overloads that H6/H7 removed but real-world CFML code still calls. The
 * wrapper proxy at {@link CompatEntityPersisterWrapper} implements this
 * interface alongside {@link EntityPersister} so CFML reflection (which walks
 * declared interface methods) sees the legacy signatures.
 *
 * <p>Surface to date:
 * <ul>
 *   <li>{@code getSubclassPropertyName(int)} — int-index property name lookup.
 *       cborm pairs this with {@code findModified(...)} (still public on H7) to
 *       map dirty-property indexes back to names in
 *       {@code BaseORMService.getDirtyPropertyNames}. H7 demoted the method to
 *       {@code protected} on {@code AbstractEntityPersister} as
 *       {@code getSubclassPropertyNameClosure()} — no public int overload
 *       remains.</li>
 * </ul>
 *
 * @see CompatEntityPersisterWrapper
 */
public interface CompatEntityPersister extends EntityPersister {

	/**
	 * H5 alias for {@code getPropertyNames()[i]}. Used by cborm
	 * {@code getDirtyPropertyNames} to resolve the {@code int[]} returned by
	 * {@code findModified(...)} back into property name strings.
	 */
	String getSubclassPropertyName(int i);

}
