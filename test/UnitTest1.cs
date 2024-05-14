using MySql.Data.MySqlClient;
using Org.BouncyCastle.Ocsp;

namespace test
{
    [TestClass]
    public class UnitTest1
    {
        public bool UtilToCheckTablesDataIsEmpty(string table)
        {
            try
            {
                MySqlConnection conn = new MySqlConnection("server=localhost;uid=root;password=root;port=6033;database=db_ouvrage");

                conn.Open();

                MySqlCommand cmd = new MySqlCommand("SELECT * FROM " + table, conn);
                MySqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    try
                    {
                        if (reader.GetString(0).Length > 0)
                        {
                            return true;
                        }
                    }
                    catch
                    {
                        if (reader.GetInt32(0).ToString().Length > 0)
                        {
                            return true;
                        }
                    }
                }

                return true;
            } catch
            {
                return false;
            }
        }
        public bool UtilToCheckTableIsEmpty(string table)
        {
            try
            {
                MySqlConnection conn = new MySqlConnection("server=localhost;uid=root;password=root;port=6033;database=db_ouvrage");

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
                return false;
            }
        }

        [TestMethod]
        public void TestConnectionToTheServer()
        {
            try
            {
                MySqlConnection conn = new MySqlConnection("server=localhost;uid=root;pwd=root;port=6033");

                conn.Open();

                Assert.AreEqual(true, true, "Connected sucessfully to the database");
            } catch 
            {
                Assert.Fail("Cannot connect to the database");;
            }
        }

        [TestMethod]
        public void TestDatabaseCreated()
        {
            try
            {
                MySqlConnection conn = new MySqlConnection("server=localhost;uid=root;pwd=root;port=6033");

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
            } catch
            {
                Assert.Fail("Cannot connect to the database");;
            }
        }

        [TestMethod]
        public void TestDatabaseIsEmpty() 
        {
            MySqlConnection conn = new MySqlConnection("server=localhost;uid=root;pwd=root;port=6033");

            try
            {
                conn.Open();

                bool isOneTable = false;

                MySqlCommand cmd = new MySqlCommand("SHOW TABLES FROM db_ouvrage", conn);
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
            } catch
            {
                Assert.Fail("Cannot connect to the database");;
            }
        }

        [TestMethod]
        public void TestCheckTableIsEmpty() 
        { 
            List<bool> bools = new List<bool>();

            MySqlConnection conn = new MySqlConnection("server=localhost;uid=root;password=root;port=6033;database=db_ouvrage");

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
            } catch
            {
                Assert.Fail("Cannot connect to the database");;
            }
        }

        [TestMethod]
        public void TestCheckTableDataIsEmpty()
        {
            List<bool> bools = new List<bool>();

            MySqlConnection conn = new MySqlConnection("server=localhost;uid=root;password=root;port=6033;database=db_ouvrage");

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
            }
            catch
            {
                Assert.Fail("Cannot connect to the database");
            }
        }

        [TestMethod]
        public void TestMethod1()
        {
            Assert.AreEqual(OperatingSystem.IsWindows(), true, "The operating system is correct");
        }
    }
}