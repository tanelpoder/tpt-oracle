// run with:
// java -cp $ORACLE_HOME/jdbc/lib/ojdbc5.jar:. Client_id


import java.sql.*;
import oracle.jdbc.OracleConnection;

public class Client_id {

    public static void main(String[] args) throws InterruptedException {

        try {
            // get connection and statement
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            Connection conn = DriverManager.getConnection( "jdbc:oracle:thin:@localhost:1521:LIN11G", "system","oracle");
            Statement stmt = conn.createStatement();
            
            // set metrics for connection (will be sent to server the next rountrip)
            String[] metrics = new String[OracleConnection.END_TO_END_STATE_INDEX_MAX];
            metrics[OracleConnection.END_TO_END_CLIENTID_INDEX]="Tanel Poder:123";
            ((OracleConnection)conn).setEndToEndMetrics(metrics,(short)0);
            
            // run your SQL code. the client identifier attribute is bundled with this roundtrip and automatically sent to server with this request
            ResultSet rs = stmt.executeQuery("SELECT sid, username, client_identifier FROM v$session WHERE type='USER' AND status='ACTIVE'");

            // print output from v$session. here you should see this java program's session with client identifier set            
            System.out.printf("\n%4s %20s %30s\n", new Object[] {"SID", "USERNAME", "CLIENT_IDENTIFIER"});
            System.out.println("--------------------------------------------------------");
            while (rs.next()) {
                System.out.printf("%4s %20s %30s\n", new Object[] {Integer.toString(rs.getInt("sid")), rs.getString("username"), rs.getString("client_identifier")} );
            }

            // Sleeping for 10 seconds. If you query the client_identifier from another session
            // you'll see that the last client_identifier still remains set (is not automatically cleared
            // upon statement completion)
            Thread.sleep(10000);
        }
            catch (SQLException e) {
          e.printStackTrace();
        }         
    }
}
