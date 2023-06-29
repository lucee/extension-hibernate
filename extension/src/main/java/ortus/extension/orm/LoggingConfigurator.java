package ortus.extension.orm;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.PatternLayout;
import ch.qos.logback.classic.spi.Configurator;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.ConsoleAppender;
import ch.qos.logback.core.FileAppender;
import ch.qos.logback.core.encoder.LayoutWrappingEncoder;
import ch.qos.logback.core.spi.ContextAwareBase;
import lucee.runtime.orm.ORMConfiguration;

/**
 * Many thanks to https://stackoverflow.com/questions/65057439/is-it-possible-to-setup-logback-configuration-programmatically
 * https://logback.qos.ch/apidocs/ch/qos/logback/classic/spi/Configurator.html
 * https://logback.qos.ch/manual/configuration.html
 */
public class LoggingConfigurator {
    /**
     * The logger factory (slf4j) or logger context (logback) that we'll be configurating.
     */
    private LoggerContext loggerContext;

    /**
     * Enable logging of all SQL queries and parameters.
     */
    private Boolean enableSQLLogging;

    public LoggingConfigurator(LoggerContext loggerContext, Boolean enableSQLLogging){
        this.loggerContext = loggerContext;
        this.enableSQLLogging = enableSQLLogging;
    }

    public void configure() {

        Logger hibernateLogger = loggerContext.getLogger("org.hibernate");
        hibernateLogger.setLevel(Level.WARN);

        // TODO: In Hibernate 6, this will be `org.hibernate.orm.jdbc.bind`
        Logger sqlLogger = loggerContext.getLogger("org.hibernate.type.descriptor.sql");
        sqlLogger.setLevel(getSQLLogLevel());

        Logger cacheLogger = loggerContext.getLogger("org.hibernate.cache");
        cacheLogger.setLevel(Level.WARN);

        // for some reason, the net.sf.ehcache logs do not go through org.hibernate/org.hibernate.cache.
        Logger ehcacheLogger = loggerContext.getLogger("net.sf.ehcache");
        ehcacheLogger.setLevel(Level.WARN);

    }

    public Level getSQLLogLevel(){
        return Boolean.TRUE.equals(this.enableSQLLogging) ? Level.DEBUG : Level.ERROR;
    }
}