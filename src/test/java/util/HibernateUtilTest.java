import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;

import org.junit.jupiter.api.Test;

import org.mockito.Mock;
import org.mockito.Mockito;

import com.ortussolutions.hibernate.util.HibernateUtil;

public class HibernateUtilTest {

    @Test
    public void canInitialize() {
        HibernateUtil util = new HibernateUtil();
    }

    @Test
    public void canIdentifyReservedKeywords(){
        HibernateUtil util = new HibernateUtil();

        assertEquals( true, util.isKeyword( "year" ) );
        assertEquals( true, util.isKeyword( "and" ) );
        assertEquals( true, util.isKeyword( "select" ) );
        assertEquals( false, util.isKeyword( "name" ) );
        assertEquals( false, util.isKeyword( "age" ) );
        assertEquals( false, util.isKeyword( "description" ) );
    }
}