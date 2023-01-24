import static org.junit.jupiter.api.Assertions.assertEquals;

// extension classes
import org.lucee.extension.orm.hibernate.event.EventListenerIntegrator;

// Lucee stuffs
import lucee.runtime.Component;
import lucee.runtime.ComponentImpl;

// Testing and mocking
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.Mockito;

public class EventListenerIntegratorTest {
    @Test
    public void canInitialize(){
        EventListenerIntegrator integrator = new EventListenerIntegrator();
    }

    @Test
    public void canAddListener(){
        @Mock
        // Component MockEntity = Mockito.mock( Component.class );
        // Mockito.when( MockEntity.get( Object, null ) ).thenReturn( Mockito.Mock( lucee.runtime.type.UDF ) );
        Component MockEntity = new ComponentImpl();
        EventListenerIntegrator integrator = new EventListenerIntegrator();
        integrator.appendEventListenerCFC( MockEntity );
    }
}
