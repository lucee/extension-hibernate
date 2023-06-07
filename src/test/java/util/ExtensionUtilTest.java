package com.ortussolutions.hibernate.util;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;

public class ExtensionUtilTest {

    @Test
    public void canGetHibernateVersion() {
        assertEquals("5.4.29.Final", ExtensionUtil.getHibernateVersion());
    }

    @Disabled("Wont pass outside of a .jar with manifest containing Implementation-Version.")
    @Test
    public void canGetExtensionVersion() {
        assertEquals("5.4.29.27", ExtensionUtil.getExtensionVersion());
    }

    @Test
    public void canGetJVMVersion() {
        // assertNoThrow() does not exist, so we just run it and if it passes, it didn't throw.
        ExtensionUtil.getJVMVersion();
    }
}