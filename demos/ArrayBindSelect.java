// run with:
// java -cp $ORACLE_HOME/jdbc/lib/ojdbc5.jar:. Client_id


import java.sql.*;
import oracle.jdbc.OracleConnection;
import java.util.UUID;
import java.util.Arrays;

public class ArrayBindSelect {

    public static void main(String[] args) throws InterruptedException {

        try {
            // get connection and statement
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            Connection conn = DriverManager.getConnection( "jdbc:oracle:thin:@oel6:1521:LIN112", "system","oracle");
            Statement stmt = conn.createStatement();
            
            // set metrics for connection (will be sent to server the next rountrip)
            String[] metrics = new String[OracleConnection.END_TO_END_STATE_INDEX_MAX];
            metrics[OracleConnection.END_TO_END_MODULE_INDEX]="Array Bind Select";
            ((OracleConnection)conn).setEndToEndMetrics(metrics,(short)0);
            
            String[] values = new String[1000];
            Arrays.fill(values, UUID.randomUUID().toString());
            //for (int i=0; i<1000; i++)
            //    values[i] = UUID.randomUUID().toString();

            ArrayDescriptor arrayDescriptor = ArrayDescriptor.createDescriptor("ARRAY_OF_PERSONS", conn);  
            // then obtain an Array filled with the content below  
            String[] content = { "v4" };  
          
            sqlArray = new oracle.sql.ARRAY(arrayDescriptor, (OracleConnection)conn, content); 


            for(int i=1;i<1000000;i++) {
                stmt.setArray(1,values);
                ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM dual WHERE dummy IN (?)");
	          }

            Thread.sleep(1000);
        }
            catch (SQLException e) {
          e.printStackTrace();
        }         
    }
}


