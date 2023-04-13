package test.java;

import org.hibernate.Session;
import org.hibernate.engine.spi.SessionDelegatorBaseImpl;
import com.ortussolutions.hibernate.HibernateORMTransaction;

// Testing and mocking
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.Mockito;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertNotNull;

public class HibernateORMTransactionTest {

    @Mock
    private Session MockSession;

    public HibernateORMTransactionTest() {
        MockSession = Mockito.mock(org.hibernate.engine.spi.SessionDelegatorBaseImpl.class);
    }

    @Test
    public void canInitialize() {
        Boolean autoManage = false;
        new HibernateORMTransaction(MockSession, autoManage);
    }
}