// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.
const Draw = () => {
    for (let i = 0; i < 10; i++) {
        for (let j = 0; j < 10; j++) {
            let div = document.getElementById(`${i}${j}`);
            div.id = "square";
        }
    }

    let data = document.getElementById("data");

    let gameDiv = document.getElementById(`${data.textContent[0]}${data.textContent[2]}`);
    gameDiv.id = "squares";
    alert("Hello");
};

Draw();