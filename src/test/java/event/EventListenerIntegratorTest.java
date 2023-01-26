import static org.junit.jupiter.api.Assertions.assertEquals;

// extension classes
import org.lucee.extension.orm.hibernate.event.EventListenerIntegrator;

// Lucee stuffs
import lucee.runtime.Component;

// Testing and mocking
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.Mockito;

public class EventListenerIntegratorTest {
    @Test
    public void canInitialize(){
        EventListenerIntegrator integrator = new EventListenerIntegrator();
    }
}
