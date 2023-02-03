import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.io.IOException;
import java.sql.SQLException;

import org.hibernate.cfg.Configuration;
import org.hibernate.cfg.AvailableSettings;
import org.junit.jupiter.api.Test;
import org.lucee.extension.orm.hibernate.event.EventListenerIntegrator;
import org.lucee.extension.orm.hibernate.jdbc.ConnectionProviderImpl;
import org.lucee.extension.orm.hibernate.util.ConfigurationBuilder;

import org.mockito.Mock;
import org.mockito.Mockito;

import lucee.runtime.exp.PageException;
import lucee.runtime.orm.ORMConfiguration;
import lucee.runtime.db.DataSource;

public class ConfigurationBuilderTest {
    @Test
    public void canInitialize() {
        ConfigurationBuilder builder = new ConfigurationBuilder();
    }

    @Test
    public void canBuildConfiguration() throws SQLException, IOException, PageException {
        ConfigurationBuilder builder = new ConfigurationBuilder();

        // @Mock
        ORMConfiguration conf = Mockito.mock(ORMConfiguration.class);
        Mockito.when(conf.logSQL()).thenReturn(true);
        Mockito.when(conf.secondaryCacheEnabled()).thenReturn(true);

        // @Mock
        DataSource datasource = Mockito.mock(DataSource.class);
        ConnectionProviderImpl connProvider = Mockito.mock(ConnectionProviderImpl.class);

        Configuration config = builder.withEventListener(new EventListenerIntegrator())
                .withConnectionProvider(connProvider).withDatasource(datasource).withDatasourceCreds("foo", "myPass123")
                .withORMConfig(conf).withXMLMappings("<xml></xml>").build();

        assertNotNull(config);
        assertEquals("false", config.getProperty(AvailableSettings.AUTO_CLOSE_SESSION));
    }
}