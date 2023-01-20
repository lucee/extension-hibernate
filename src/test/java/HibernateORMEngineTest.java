package org.lucee.extension.orm.hibernate;

import static org.junit.jupiter.api.Assertions.assertEquals;

// extension classes
import org.lucee.extension.orm.hibernate.HibernateORMEngine;

// Lucee stuffs
import lucee.runtime.Component;
import lucee.runtime.orm.ORMConfiguration;
import lucee.commons.io.res.Resource;
// Testing and mocking
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.Mockito;
import java.io.File;
import org.w3c.dom.Element;

class HibernateORMEngineTest {

    HibernateORMEngine engine = new HibernateORMEngine();

    @Test
    void canInitialize(){
        assertEquals( 0, engine.getMode() );
    }

    // @Test
    // void testSaveMapping() {
    //     @Mock
    //     Resource mapping = Mockito.mock( Resource.class );
    //     Mockito.when( mapping.toString() ).thenReturn( "Person.cfc" );

    //     @Mock
    //     Element xml = Mockito.mock( Element.class );
    //     Mockito.when( xml.toString() ).thenReturn( "<xml></xml>" );

    //     assertNotNull( xml );
    //     assertNotNull( mapping );

    //     engine.saveMapping( xml, mapping );
    //     assertTrue( new File( "person.hbm.xml" ).exists() );
    // }

}