package ortus.extension.orm.mapping;

public final class CFConstants {

    private CFConstants() {
        throw new IllegalStateException( "Utility class; please don't instantiate!" );
    }
    
    /**
     *  @TODO: Move this into some CFConstants class, or somewhere that both HBMCreator and HibernateCaster can reference it.
     * @TODO: For 7.0, Migrate to Map.of() or Map.ofEntries in Java 9+
     */
    public static final class Relationships {
        public static final String ONE_TO_MANY = "one-to-many";
        public static final String MANY_TO_MANY = "many-to-many";
        public static final String MANY_TO_ONE = "many-to-one";
        public static final String ONE_TO_ONE = "one-to-one";

        private Relationships() {
            throw new IllegalStateException( "Utility class; please don't instantiate!" );
        }

        /**
         * Identify whether the given string denotes one of the four main relationship types:
         * - one-to-many
         * - one-to-one
         * - many-to-many
         * - many-to-one
         * 
         * @param fieldType Field type string from a persistent property, like "one-to-many" or "id"
         * @return Boolean
         */
        public static boolean isRelationshipType( String fieldType ){
            return 
                ONE_TO_MANY.equalsIgnoreCase(fieldType) ||
                MANY_TO_MANY.equalsIgnoreCase(fieldType) ||
                MANY_TO_ONE.equalsIgnoreCase(fieldType) ||
                ONE_TO_ONE.equalsIgnoreCase(fieldType);
        }
    }
}
