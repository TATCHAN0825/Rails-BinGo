import consumer from "./consumer"

const PHASE_LIST = ["Wait", "Ready", "Game", "End"]

let board;

document.addEventListener("turbolinks:load", function () {
    board = consumer.subscriptions.create({channel: "BoardChannel", board: $('#board-id').html()}, {
        connected() {
            // Called when the subscription is ready for use on the server
        },

        disconnected() {
            // Called when the subscription has been terminated by the server
        },

        received(data) {
            let type = data["type"];
            if (type === "update_ready") {
                let user_id = data["user_id"]
                if (data["ready"]) {
                    $(`#user_id${user_id}` + ".ready-check").css("color", "green");
                } else {
                    $(`#user_id${user_id}` + ".ready-check").css("color", "red");
                }
            } else if (type === "phase_changed") {
                let phase = data["phase"]
                $('#phase').html(PHASE_LIST[phase]);
            } else {
                console.log("unknown data received from server");
                console.log(data);
            }
        }
    });
});

document.addEventListener("turbolinks:load", function () {
    let readyButton = $("#ready-button");
    readyButton.on("click", function () {
        if (readyButton.hasClass("green")) {
            readyButton.removeClass("green");
            readyButton.addClass("red");
            board.perform("ready", {ready: true, boardid: $('#board-id').html()});
        } else {
            readyButton.removeClass("red");
            readyButton.addClass("green");
            board.perform("ready", {ready: false, boardid: $('#board-id').html()});
        }
    });
});
