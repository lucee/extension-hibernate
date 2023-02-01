
// extension classes
import org.lucee.extension.orm.hibernate.jdbc.DataSourceConfig;

// Lucee stuffs
// import lucee.runtime.db.DataSource;
// import lucee.runtime.db.DataSourceImpl;
import org.hibernate.cfg.Configuration;

// Testing and mocking
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Disabled;

@Disabled("Weird 'cannot find symbol' error with Lucee Datasource classes")
class DatasourceConfigTest {

    DataSourceConfig dsc;

    // @Test
    // void canInitialize(){
    // dsc = new DataSourceConfig( new DataSourceImpl(), new Configuration() );
    // }

}