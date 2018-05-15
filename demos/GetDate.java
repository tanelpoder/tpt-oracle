// run with:
// java -cp $ORACLE_HOME/jdbc/lib/ojdbc6.jar:. GetDate


import java.sql.*;
import oracle.jdbc.OracleConnection;

public class GetDate {

    public static void main(String[] args) throws InterruptedException {

        try {
            // get connection and statement
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            Connection conn = DriverManager.getConnection( "jdbc:oracle:thin:@centos7:1521:LIN121", "system","oracle");
            Statement stmt = conn.createStatement();
            stmt.execute("ALTER SESSION SET time_zone = '-08:00'");

            ResultSet rs = stmt.executeQuery("SELECT d FROM t");

            // print output from v$session. here you should see this java program's session with client identifier set            
            System.out.printf("\n%-10s %-10s %-20s\n", "DATE", "TIME", "TIMESTAMP");
            System.out.println("-------------------------------------------------");
            while (rs.next()) {
                System.out.printf("%-10s %-10s %-20s\n", new Object[] {rs.getDate("D").toString(), rs.getTime("D").toString(), rs.getTimestamp("D").toString()} );
            }
        }
            catch (SQLException e) {
          e.printStackTrace();
        }         
    }
}
