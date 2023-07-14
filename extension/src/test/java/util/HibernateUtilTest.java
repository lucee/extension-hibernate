import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;

import org.junit.jupiter.api.Test;

import org.mockito.Mock;
import org.mockito.Mockito;

import ortus.extension.orm.util.HibernateUtil;

public class HibernateUtilTest {

    @Test
    public void canIdentifyReservedKeywords() {

        assertEquals(true, HibernateUtil.isKeyword("year"));
        assertEquals(true, HibernateUtil.isKeyword("and"));
        assertEquals(true, HibernateUtil.isKeyword("select"));
        assertEquals(false, HibernateUtil.isKeyword("name"));
        assertEquals(false, HibernateUtil.isKeyword("age"));
        assertEquals(false, HibernateUtil.isKeyword("description"));
    }
}