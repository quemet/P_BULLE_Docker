using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using MySql.Data.MySqlClient;
using Microsoft.JSInterop;
using Microsoft.AspNetCore.Components;

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
        public string serverIp;
        public string serverPort;
        public string databaseName;
        public string databasePassword;
        public string databaseUsername;
        public string connectionString;
        public Database(string serverIp, string serverPort, string databaseName, string databaseUsername, string databasePassword)
        {
            this.serverIp = serverIp;
            this.serverPort = serverPort;
            this.databaseName = databaseName;
            this.databaseUsername = databaseUsername;
            this.databasePassword = databasePassword;
            connectionString = $"Server={this.serverIp};Port={this.serverPort};Database={this.databaseName};user={this.databaseUsername};Password={this.databasePassword};";
        }
        public string ConnectionDatabase()
        {
            using (MySqlConnection connection = new MySqlConnection(connectionString))
            {
                try
                {
                    connection.Open();
                    return "Connected to the database.";
                }
                catch (MySqlException ex)
                {
                    return "Erreur lors de la connexion à la base de données : " + ex;
                }
            }
        }

        public void InsertScore()
        {
            using(MySqlConnection connection = new MySqlConnection(connectionString))
            {
                using(MySqlCommand command = new MySqlCommand())
                {
                    command.CommandText = "INSERT INTO t_player(username, colorSkin, skin) VALUES (@username, @colorskin, @skin)";
                    command.Parameters.AddWithValue("@username", "root");
                    command.Parameters.AddWithValue("@colorskin", "yellow");
                    command.Parameters.AddWithValue("@skin", "");
                    command.ExecuteNonQuery();
                }
            }
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
            x = 0;
            y = 9;
            score = 0;
            direction = "Right";
        }

        public void Move()
        {
            if(direction == "Right")
            {
                if (x == 9)
                {
                    y -= 1;
                    direction = "Left";
                } else {
                    x += 1;
                }
            } else {
                if(x == 0)
                {
                    y -= 1;
                    direction = "Right";
                } else {
                    x -= 1;
                }
            }
        }

        public void GameEngine()
        {
            Move();

            Console.WriteLine("Waiting...");

            Thread.Sleep(1000);
        }
    }
}