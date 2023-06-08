import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Disabled;

// extension classes
import ortus.extension.orm.event.EventListenerIntegrator;

// Lucee stuffs
import lucee.runtime.Component;

// Testing and mocking
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.Mockito;

@Disabled
public class EventListenerIntegratorTest {
    @Test
    public void canInitialize() {
        EventListenerIntegrator integrator = new EventListenerIntegrator();
    }
}
