using MySql.Data.MySqlClient;
using Org.BouncyCastle.Ocsp;

namespace test
{
    [TestClass]
    public class UnitTest1
    {
        public bool UtilToCheckTablesDataIsEmpty(string table)
        {
            MySqlConnection conn = new MySqlConnection("server=db;uid=root;pwd=root;port=3306;database=db_bulle_docker");
            try
            {
                conn.Open();

                MySqlCommand cmd = new MySqlCommand("SELECT * FROM " + table, conn);
                MySqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    try
                    {
                        if (reader.GetString(0).Length > 0)
                        {
                            conn.Close();
                            return true;
                        }
                    }
                    catch
                    {
                        if (reader.GetInt32(0).ToString().Length > 0)
                        {
                            conn.Close();
                            return true;
                        }
                    }
                }

                conn.Close();
                return true;
            } catch
            {
                conn.Close();
                return false;
            }
        }
        public bool UtilToCheckTableIsEmpty(string table)
        {
            MySqlConnection conn = new MySqlConnection("server=db;uid=root;pwd=root;port=3306;database=db_bulle_docker");
            try
            {
                conn.Open();

                bool isOneColumn = false;

                MySqlCommand cmd = new MySqlCommand("SHOW COLUMNS FROM " + table, conn);
                MySqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    if (reader.GetString(0).Length > 0)
                    {
                        isOneColumn = true;
                        break;
                    }
                }

                conn.Close();
                return isOneColumn;
            }
            catch
            {
                conn.Close();
                return false;
            }
        }

        [TestMethod]
        public void TestConnectionToTheServer()
        {
            MySqlConnection conn = new MySqlConnection("server=db;uid=root;pwd=root;port=3306;database=db_bulle_docker");
            try
            {
                conn.Open();

                Assert.AreEqual(true, true, "Connected sucessfully to the database");

                conn.Close();
            } catch(Exception ex) 
            {
                Assert.Fail("Cannot connect to the database \n\n " + ex);
                conn.Close();
            }
        }

        [TestMethod]
        public void TestDatabaseCreated()
        {
            MySqlConnection conn = new MySqlConnection("server=db;uid=root;pwd=root;port=3306;database=db_bulle_docker");
            try
            {
                conn.Open();

                string[] baseDb = new string[] { "information_schema", "mysql", "performance_schema", "sys" };
                bool isNewDatabase = false;

                MySqlCommand cmd = new MySqlCommand("SHOW DATABASES", conn);
                MySqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    bool isDefaultDatabase = baseDb.Contains(reader.GetString(0));

                    if(!isDefaultDatabase)
                    {
                        isNewDatabase = true;
                        break;
                    }
                }

                Assert.IsTrue(isNewDatabase, "A useful database has been created");

                conn.Close();
            } catch(Exception ex)
            {
                Assert.Fail("Cannot connect to the database \n\n " + ex);
                conn.Close();
            }
        }

        [TestMethod]
        public void TestDatabaseIsEmpty() 
        {
            MySqlConnection conn = new MySqlConnection("server=db;uid=root;pwd=root;port=3306;database=db_bulle_docker");
            try
            {
                conn.Open();

                bool isOneTable = false;

                MySqlCommand cmd = new MySqlCommand("SHOW TABLES FROM db_bulle_docker", conn);
                MySqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    if (reader.GetString(0).Length > 0)
                    {
                        isOneTable = true;
                        break;
                    }
                }

                Assert.IsTrue(isOneTable, "Some Table has been created for the application");

                conn.Close();
            } catch(Exception ex)
            {
                Assert.Fail("Cannot connect to the database \n\n " + ex);

                conn.Close();
            }
        }

        [TestMethod]
        public void TestCheckTableIsEmpty() 
        { 
            List<bool> bools = new List<bool>();

            MySqlConnection conn = new MySqlConnection("server=db;uid=root;pwd=root;port=3306;database=db_bulle_docker");
            try
            {
                conn.Open();

                MySqlCommand cmd = new MySqlCommand("SHOW TABLES", conn);
                MySqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    bools.Add(UtilToCheckTableIsEmpty(reader.GetString(0)));
                }

                bool isFalse = bools.Contains(false);

                Assert.IsTrue(!isFalse, "The table is not empty");

                conn.Close();
            } catch(Exception ex)
            {
                Assert.Fail("Cannot connect to the database \n\n " + ex);

                conn.Close();
            }
        }

        [TestMethod]
        public void TestCheckTableDataIsEmpty()
        {
            List<bool> bools = new List<bool>();

            MySqlConnection conn = new MySqlConnection("server=db;uid=root;pwd=root;port=3306;database=db_bulle_docker");
            try
            {
                conn.Open();

                MySqlCommand cmd = new MySqlCommand("SHOW TABLES", conn);
                MySqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    bools.Add(UtilToCheckTablesDataIsEmpty(reader.GetString(0)));
                }

                bool isFalse = bools.Contains(false);

                Assert.IsTrue(!isFalse, "The table contain Data");

                conn.Close();
            }
            catch(Exception ex)
            {
                Assert.Fail("Cannot connect to the database \n\n " + ex);

                conn.Close();
            }
        }

        [TestMethod]
        public void TestMethod1()
        {
            Assert.AreEqual(OperatingSystem.IsWindows(), false, "The operating system is correct");
        }
    }
}