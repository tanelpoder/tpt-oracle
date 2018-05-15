// run with:
// java -cp $ORACLE_HOME/jdbc/lib/ojdbc5.jar:. Client_id


import java.sql.*;
import oracle.jdbc.OracleConnection;

public class Commit {

    public static void main(String[] args) throws InterruptedException {

        try {
            // get connection and statement
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            Connection conn = DriverManager.getConnection( "jdbc:oracle:thin:@localhost:1521:LIN11G", "system","oracle");
            Statement stmt = conn.createStatement();
            
            // set metrics for connection (will be sent to server the next rountrip)
            String[] metrics = new String[OracleConnection.END_TO_END_STATE_INDEX_MAX];
            metrics[OracleConnection.END_TO_END_MODULE_INDEX]="Committer";
            ((OracleConnection)conn).setEndToEndMetrics(metrics,(short)0);

            for(int i=1;i<1000000;i++) {            
		    ResultSet rs = stmt.executeQuery("UPDATE t SET a=a+1");
		    //autocommit takes care of this conn.commit();
	    }

            Thread.sleep(100);
        }
            catch (SQLException e) {
          e.printStackTrace();
        }         
    }
}
