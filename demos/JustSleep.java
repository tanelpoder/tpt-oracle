// run with:
// java -cp $ORACLE_HOME/jdbc/lib/ojdbc5.jar:. Client_id


import java.sql.*;
import oracle.jdbc.OracleConnection;

public class JustSleep {

    public static void main(String[] args) throws InterruptedException {

        try {
            // get connection and statement
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            Connection conn = DriverManager.getConnection( "jdbc:oracle:thin:@oel6:1521:LIN112", "system","oracle");
            Statement stmt = conn.createStatement();
            
            // set metrics for connection (will be sent to server the next rountrip)
            String[] metrics = new String[OracleConnection.END_TO_END_STATE_INDEX_MAX];
            metrics[OracleConnection.END_TO_END_CLIENTID_INDEX]="Tanel Poder";
            ((OracleConnection)conn).setEndToEndMetrics(metrics,(short)0);
            
            // run your SQL code. the client identifier attribute is bundled with this roundtrip and automatically sent to server with this request
            ResultSet rs = stmt.executeQuery("BEGIN DBMS_LOCK.SLEEP(9999); END;");
        }
            catch (SQLException e) {
          e.printStackTrace();
        }         
    }
}
