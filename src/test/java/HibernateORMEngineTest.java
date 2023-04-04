package com.ortussolutions.hibernate;

import static org.junit.jupiter.api.Assertions.assertEquals;

// extension classes
import com.ortussolutions.hibernate.HibernateORMEngine;

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
    void canInitialize() {
        assertEquals(0, engine.getMode());
    }

}