/*
 * Firebird Open Source JavaEE Connector - JDBC Driver
 *
 * Distributable under LGPL license.
 * You may obtain a copy of the License at http://www.gnu.org/copyleft/lgpl.html
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * LGPL License for more details.
 *
 * This file was created by members of the firebird development team.
 * All individual contributions remain the Copyright (C) of those
 * individuals.  Contributors to this file are either listed here or
 * can be obtained from a source control history command.
 *
 * All rights reserved.
 */
package org.firebirdsql.repro;

import org.firebirdsql.common.FBJUnit4TestBase;
import org.firebirdsql.common.FBTestProperties;
import org.firebirdsql.gds.ISCConstants;
import org.firebirdsql.gds.TransactionParameterBuffer;
import org.firebirdsql.gds.impl.TransactionParameterBufferImpl;
import org.firebirdsql.gds.ng.FbConnectionProperties;
import org.firebirdsql.gds.ng.FbDatabase;
import org.firebirdsql.gds.ng.FbStatement;
import org.firebirdsql.gds.ng.FbTransaction;
import org.firebirdsql.gds.ng.fields.RowValue;
import org.firebirdsql.gds.ng.wire.FbWireDatabaseFactory;
import org.junit.Test;

import java.sql.SQLException;

import static org.firebirdsql.common.FBTestProperties.DB_PASSWORD;
import static org.firebirdsql.common.FBTestProperties.DB_USER;

/**
 * Tests to reproduce Firebird 3 but with isc_tpb_autocommit
 *
 * @author <a href="mailto:mrotteveel@users.sourceforge.net">Mark Rotteveel</a>
 */
public class TpbAutocommitTest extends FBJUnit4TestBase {

    //@formatter:off
    private static final String CREATE_PROCEDURE =
            "CREATE PROCEDURE testproc1 (IN1 INTEGER, IN2 FLOAT)" +
            "RETURNS (OUT1 VARCHAR(20), " +
            "  OUT2 DOUBLE PRECISION, OUT3 INTEGER) AS " +
            " DECLARE VARIABLE X INTEGER;" +
            "BEGIN" +
            " OUT1 = 'Out String';" +
            " OUT2 = 45;" +
            " OUT3 = IN1;" +
            "END";

    private static final String ADD_COMMENT = "COMMENT ON PROCEDURE testproc1 IS 'Test description'";
    //@formatter:on

    @Test
    public void iscTpbAutocommit_hangsServer() throws SQLException {
        try (FbDatabase db = createDatabaseConnection()) {
            db.attach();

            TransactionParameterBuffer tpb = new TransactionParameterBufferImpl();
            tpb.addArgument(ISCConstants.isc_tpb_read_committed);
            tpb.addArgument(ISCConstants.isc_tpb_rec_version);
            tpb.addArgument(ISCConstants.isc_tpb_write);
            tpb.addArgument(ISCConstants.isc_tpb_wait);
            tpb.addArgument(ISCConstants.isc_tpb_autocommit);
            FbTransaction transaction = db.startTransaction(tpb);
            try {
                FbStatement statement = db.createStatement(transaction);
                statement.prepare(CREATE_PROCEDURE);
                statement.execute(RowValue.EMPTY_ROW_VALUE);
                statement.prepare(ADD_COMMENT);
                statement.execute(RowValue.EMPTY_ROW_VALUE);
            } finally {
                transaction.commit();
            }
        }
    }

    private FbDatabase createDatabaseConnection() throws SQLException {
        return FbWireDatabaseFactory.getInstance().connect(createConnectionProperties());
    }

    private FbConnectionProperties createConnectionProperties() {
        FbConnectionProperties connectionInfo = new FbConnectionProperties();
        connectionInfo.setServerName(FBTestProperties.DB_SERVER_URL);
        connectionInfo.setPortNumber(FBTestProperties.DB_SERVER_PORT);
        connectionInfo.setUser(DB_USER);
        connectionInfo.setPassword(DB_PASSWORD);
        connectionInfo.setDatabaseName(FBTestProperties.getDatabasePath());
        connectionInfo.setEncoding("NONE");
        return connectionInfo;
    }

}
