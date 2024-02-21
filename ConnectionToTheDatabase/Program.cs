using MySql.Data.MySqlClient;

namespace ConnectionToTheDatabase
{
    internal class Program
    {
        public static void ConnectionToTheDatabase()
        {
            string connStr = "server=localhost;user=root;database=db_bulle;port=3306;password=root";
            MySqlConnection conn = new MySqlConnection(connStr);
            try
            {
                Console.WriteLine("Connecting to MySQL...");
                conn.Open();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }

            conn.Close();
        }
        static void Main(string[] args)
        {
            ConnectionToTheDatabase();
        }
    }
}