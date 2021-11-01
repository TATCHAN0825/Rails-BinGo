import consumer from "./consumer"

const board = consumer.subscriptions.create("BoardChannel", {
    connected() {
        // Called when the subscription is ready for use on the server
    },

    disconnected() {
        // Called when the subscription has been terminated by the server
    },

    received(data) {
        console.log(data)
        let type = data["type"];
        let user_id = data["user_id"]
        if (type === "update_ready") {
            if (data["ready"]) {
                $(`#user_id${user_id}` + ".ready-check" ).css("color", "green");
            } else {
                $(`#user_id${user_id}` + ".ready-check" ).css("color", "red");

            }
        }
    }
});

document.addEventListener("turbolinks:load", function () {
    let readyButton = $("#ready-button");
    readyButton.on("click", function () {
        if (readyButton.hasClass("green")) {
            readyButton.removeClass("green");
            readyButton.addClass("red");
            board.perform("ready", {ready: true});
        } else {
            readyButton.removeClass("red");
            readyButton.addClass("green");
            board.perform("ready", {ready: false});
        }
    });
});
