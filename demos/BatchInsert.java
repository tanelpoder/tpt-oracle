// run with:
// java -cp $ORACLE_HOME/jdbc/lib/ojdbc8.jar:. BatchInsert

// requires:
// CREATE TABLE t(a NUMBER, b VARCHAR2(150));

// results in these metrics (Starts=10) for a single *batch* execution of the SQL (v$sql.executions=1)
//
// INSERT INTO t SELECT :1 , :2  FROM dual
// 
// --------------------------------------------------------------------------------------------------------
// | Id  | Operation                | Name | Starts | E-Rows | Cost (%CPU)| A-Rows |   A-Time   | Buffers |
// --------------------------------------------------------------------------------------------------------
// |   0 | INSERT STATEMENT         |      |     10 |        |     2 (100)|      0 |00:00:00.01 |      13 |
// |   1 |  LOAD TABLE CONVENTIONAL | T    |     10 |        |            |      0 |00:00:00.01 |      13 |
// |   2 |   FAST DUAL              |      |     10 |      1 |     2   (0)|     10 |00:00:00.01 |       0 |
// --------------------------------------------------------------------------------------------------------


import java.sql.*;
import oracle.jdbc.OracleConnection;

public class BatchInsert {

    public static void main(String[] args) throws InterruptedException {

        try {
            DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
            Connection conn = DriverManager.getConnection( "jdbc:oracle:thin:@linux01:1521:LIN19C", "system","oracle");
            
            String sql = "INSERT INTO t SELECT ?, ? FROM dual";
            PreparedStatement stmt = conn.prepareStatement(sql);

            for(int i=1; i<=10; i++) {
                stmt.setInt(1, i);
                stmt.setString(2, new String("blah"));
                stmt.addBatch(); 
            }

            stmt.executeBatch(); 
            
        } catch (SQLException ex) {
            ex.printStackTrace(); 
        }
    }
}
