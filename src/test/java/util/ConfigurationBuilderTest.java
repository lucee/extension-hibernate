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
    public void canInitialize(){
        ConfigurationBuilder builder = new ConfigurationBuilder();
    }

    @Test
    public void canBuildConfiguration() throws SQLException, IOException, PageException {
        ConfigurationBuilder builder = new ConfigurationBuilder();

        // @Mock
        ORMConfiguration conf = Mockito.mock( ORMConfiguration.class );
		Mockito.when( conf.logSQL() ).thenReturn( true );
		Mockito.when( conf.secondaryCacheEnabled() ).thenReturn( true );

        // @Mock
        DataSource datasource = Mockito.mock( DataSource.class );
		ConnectionProviderImpl connProvider = Mockito.mock( ConnectionProviderImpl.class );

        Configuration config = builder
            .withEventListener( new EventListenerIntegrator() )
			.withConnectionProvider( connProvider )
            .withDatasource( datasource )
            .withDatasourceCreds( "foo", "myPass123" )
            .withORMConfig( conf )
            .withXMLMappings( "<xml></xml>" )
            .build();

        assertNotNull( config );
        assertEquals( "false", config.getProperty( AvailableSettings.AUTO_CLOSE_SESSION ) );
    }
}

// public class MockORMConfiguration implements ORMConfiguration {

// 	public String hash(){
//         return "";
//     }

// 	/**
// 	 * @return the autogenmap
// 	 */
// 	public boolean autogenmap(){
//         return true;
//     }

// 	/**
// 	 * @return the catalog
// 	 */
// 	public String getCatalog(){
//         return "";
//     }

// 	/**
// 	 * @return the cfcLocation
// 	 */
// 	public Resource[] getCfcLocations(){

//     }

// 	public boolean isDefaultCfcLocation(){

//     }

// 	/**
// 	 * @return the dbCreate
// 	 */
// 	public int getDbCreate(){

//     }

// 	/**
// 	 * @return the dialect
// 	 */
// 	public String getDialect(){
//         return "";
//     }

// 	/**
// 	 * @return the eventHandling
// 	 */
// 	public boolean eventHandling(){
//         return true;
//     }

// 	public String eventHandler(){
//         return "";
//     }

// 	public String namingStrategy(){
//         return "";
//     }

// 	/**
// 	 * @return the flushAtRequestEnd
// 	 */
// 	public boolean flushAtRequestEnd(){
//         return true;
//     }

// 	/**
// 	 * @return the logSQL
// 	 */
// 	public boolean logSQL(){
//         return true;
//     }

// 	/**
// 	 * @return the saveMapping
// 	 */
// 	public boolean saveMapping(){
//         return true;
//     }

// 	/**
// 	 * @return the schema
// 	 */
// 	public String getSchema(){
//         return "";
//     }

// 	/**
// 	 * @return the secondaryCacheEnabled
// 	 */
// 	public boolean secondaryCacheEnabled(){
//         return true;
//     }

// 	/**
// 	 * @return the sqlScript
// 	 */
// 	public Resource getSqlScript(){
//         return "";
//     }

// 	/**
// 	 * @return the useDBForMapping
// 	 */
// 	public boolean useDBForMapping(){
//         return true;
//     }

// 	/**
// 	 * @return the cacheConfig
// 	 */
// 	public Resource getCacheConfig(){

//     }

// 	/**
// 	 * @return the cacheProvider
// 	 */
// 	public String getCacheProvider(){

//     }

// 	/**
// 	 * @return the ormConfig
// 	 */
// 	public Resource getOrmConfig(){

//     }

// 	public boolean skipCFCWithError(){

//     }

// 	public boolean autoManageSession(){

//     }

// 	public Object toStruct(){

//     }
// }