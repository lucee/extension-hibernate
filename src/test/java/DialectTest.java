
import org.lucee.extension.orm.hibernate.Dialect;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Disabled;
import static org.junit.jupiter.api.Assertions.assertEquals;

@Disabled( "Fails because Lucee engine is not initialized")
public class DialectTest {

    Dialect dialect;
    
    @Test
    void canInitialize(){
        dialect = new Dialect();
    }

    @Test
    void canGetDialectStatically(){
        assertEquals( "org.hibernate.dialect.SQLServer2012Dialect", Dialect.getDialect( "SQLServer2012" ) );
    }
}
