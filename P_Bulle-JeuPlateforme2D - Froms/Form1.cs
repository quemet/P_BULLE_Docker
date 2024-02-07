using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Threading;

namespace P_Bulle_JeuPlateforme2D
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        const int WIDTH = 900;
        const int HEIGHT = 600;
        const int CELL_SIZE = 50;

        Player player;

        Block block1;
        Block block2;

        Block block3;
        Block block4;
        Block block5;

        Block block6;

        Label player_label;

        Label block1_label;
        Label block2_label;

        Label block3_label;
        Label block4_label;
        Label block5_label;

        Label block6_label;

        public void ImplementObject(object sender, EventArgs e)
        {
            player = new Player(0, HEIGHT - 2 * CELL_SIZE, CELL_SIZE, "Right", this);

            block1 = new Block(0, HEIGHT - CELL_SIZE, WIDTH - player.size, CELL_SIZE, this);
            block2 = new Block(WIDTH - player.size, HEIGHT - CELL_SIZE, player.size, CELL_SIZE, this);

            block3 = new Block(0, HEIGHT - 5 * CELL_SIZE, player.size, CELL_SIZE, this);
            block4 = new Block(CELL_SIZE, HEIGHT - 5 * CELL_SIZE, WIDTH - 2 * player.size, CELL_SIZE, this);
            block5 = new Block(WIDTH - player.size, HEIGHT - 5 * CELL_SIZE, player.size, CELL_SIZE, this);

            block6 = new Block(0, HEIGHT - 9 * CELL_SIZE, player.size, CELL_SIZE, this);

            player_label = new Label { Size = new Size(player.size, player.size), BackColor = Color.Red, Location = new Point(player.x, player.y)};

            block1_label = new Label { Size = new Size(block1.width, block1.height), BackColor = Color.Black, Location = new Point(block1.x, block1.y)};
            block2_label = new Label { Size = new Size(block2.width, block2.height), BackColor = Color.Blue, Location = new Point(block2.x, block2.y) };

            block3_label = new Label { Size = new Size(block3.width, block3.height), BackColor = Color.Orange, Location = new Point(block3.x, block3.y) };
            block4_label = new Label { Size = new Size(block4.width, block4.height), BackColor = Color.Black, Location = new Point(block4.x, block4.y) };
            block5_label = new Label { Size = new Size(block5.width, block5.height), BackColor = Color.Blue, Location = new Point(block5.x, block5.y) };

            block6_label = new Label { Size = new Size(block6.width, block6.height), BackColor = Color.Orange, Location = new Point(block6.x, block6.y) };

            panel2.Controls.Add(player_label);
            panel2.Controls.Add(block1_label);
            panel2.Controls.Add(block2_label);

            panel2.Controls.Add(block3_label);
            panel2.Controls.Add(block4_label);
            panel2.Controls.Add(block5_label);

            panel2.Controls.Add(block6_label);
        }

        public void Form1_Load(object sender, EventArgs e)
        {
            ImplementObject(sender, e);

            this.KeyDown += this.UserInput;
        }

        public void ShowLabel(object sender, EventArgs e)
        {
            this.player_label.Location = new Point(player.x, player.y);
            panel2.Controls.Add(player_label);
        }

        public void UserInput(object sender, KeyEventArgs e)
        {
            if(player.x == WIDTH - CELL_SIZE - CELL_SIZE)
            {
                player_label.BackColor = Color.Orange;
            } else
            {
                player_label.BackColor = Color.Red;
            }
            switch (e.KeyValue)
            {
                case 32:
                    this.JumpAnimation(sender, e);
                    break;
                case 37:
                    if(player.x >= CELL_SIZE)
                    {
                        player.x -= CELL_SIZE;
                    }
                    break;
                case 39:
                    if(player.x < WIDTH - CELL_SIZE)
                    {
                        player.x += CELL_SIZE;
                    }
                    break;
            }
            this.ShowLabel(sender, e);
        }

        public void JumpAnimation(object sender, EventArgs e)
        {
            Thread.Sleep(200);

            player.x += player.size;
            player.y -= player.size;
            this.player_label.Location = new Point(player.x, player.y);
            panel2.Controls.Add(player_label);
            Thread.Sleep(300);

            player.x += player.size;
            this.player_label.Location = new Point(player.x, player.y);
            panel2.Controls.Add(player_label);
            Thread.Sleep(300);

            player.x += player.size;
            player.y += player.size;
            this.player_label.Location = new Point(player.x, player.y);
            panel2.Controls.Add(player_label);
            Thread.Sleep(300);
        }
    }

    class Player
    {
        public int x;
        public int y;
        public int size;
        public string direction;
        public string skin;
        public Form1 form;

        public Player(int x, int y, int size, string direction, Form1 form, string skin = "")
        {
            this.x = x;
            this.y = y;
            this.size = size;
            this.direction = direction;
            this.skin = skin;
            this.form = form;
        }
    }

    class Block
    {
        public int x;
        public int y;
        public int width;
        public int height;
        public Form1 form;

        public Block(int x, int y, int width, int height, Form1 form)
        {
            this.x = x;
            this.y = y;
            this.width = width;
            this.height = height;
            this.form = form;
        }
    }
}
