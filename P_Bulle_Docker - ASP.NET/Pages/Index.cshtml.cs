using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using MySql.Data.MySqlClient;
using Microsoft.JSInterop;

namespace P_Bulle_Docker.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;

        public IndexModel(ILogger<IndexModel> logger)
        {
            _logger = logger;
        }
    }

    public class Database : PageModel
    {
        private string serverIp;
        private int serverPort;
        private string databaseName;
        private string databasePassword;
        private string databaseUsername;
        private string connectionString;
        public Database(string serverIp, int serverPort, string databaseName, string databasePassword, string databaseUsername)
        {
            this.serverIp = serverIp;
            this.serverPort = serverPort;
            this.databaseName = databaseName;
            this.databasePassword = databasePassword;
            this.databaseUsername = databaseUsername;
            this.connectionString = $"server={serverIp};port={serverPort};database={databaseName};user={databaseUsername};password={databasePassword}";
        }
        public void ConnectionDatabase()
        {
            MySqlConnection conn = new MySqlConnection(this.connectionString);
            try
            {
                Console.WriteLine("Connecting to MySQL...");
                conn.Open();
                Console.WriteLine("Connected to MySQL");
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }

            conn.Close();
        }
    }

    public class Player
    {
        public string SkinColor;
        public byte x;
        public byte y;
        public int score;
        public string direction;
        public bool isModified = false;

        public Player(string skinColor)
        {
            SkinColor = skinColor;
            this.x = 0;
            this.y = 9;
            this.score = 0;
            this.direction = "Right";
        }

        public void Move()
        {
            if(this.direction == "Right")
            {
                if (this.x == 9)
                {
                    this.y -= 1;
                    this.direction = "Left";
                } else {
                    this.x += 1;
                }
            } else {
                if(this.x == 0)
                {
                    this.y -= 1;
                    this.direction = "Right";
                } else {
                    this.x -= 1;
                }
            }
        }

        public byte[] GameEngine()
        {
            Move();
            Console.WriteLine("Wating...");
            Thread.Sleep(1000);
            return new byte[] {this.x, this.y};
        }
    }
}