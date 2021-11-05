import consumer from "./consumer"

const PHASE_LIST = ["Wait", "Ready", "Game", "End"]

let board;
let lotteryIntervalId;
let cards = [];
let myId;

document.addEventListener("turbolinks:load", function () {
    myId = parseInt($("#user-id").html());

    $(".bingo-card").each(function (i, card) {
        cards[i] = [];
        $(card).find(".number").each(function (j, number) {
            let numberClass = $(number).attr("class");
            cards[i][j] = {
                x: /number-x-(\d)/.exec(numberClass)[1],
                y: /number-y-(\d)/.exec(numberClass)[1],
                value: $(number).html()
            };
        });
    });

    console.log("cards:");
    console.log(cards);

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
            } else if (type === "lottery_start") {
                let numbers = data["numbers"];

                let count = 0;
                lotteryIntervalId = setInterval(function () {
                    let number = numbers[count];

                    $("#bingo-number").html(number);

                    count++;

                    if (count >= numbers.length) {
                        count = 0;
                    }
                }, 100);
            } else if (type === "lottery_stop") {
                let result = data["result"];

                console.log("result:");
                console.log(result);

                clearInterval(lotteryIntervalId);
                $("#bingo-number").html(result);

                let histories = $("#histories");
                histories.html(histories.html() + '<button name="button" type="submit" class="btn-floating btn-large waves-effect waves-light red">' + result + '</button>');

                /*cards.forEach(function (numbers) {
                    numbers.forEach(function (number) {
                        if (number["value"] === result) {
                            let x = number["x"];
                            let y = number["y"];

                            $(`.open-x-${x} .open-y-${y}`).removeClass("number-not-open");
                        }
                    });
                });*/

                $(`.open-${result}`).removeClass("number-not-open");

                this.perform("next_user");
            } else if (type === "your_turn") {
                let id = data["id"];
                if (id === myId) {
                    $("#your-turn-message").html("あなたのターン");
                    $("#start-button").removeClass("disabled");
                }
            } else if (type === "error") {
                let message = data["message"];
                let errorMessage = $('#error_message');
                errorMessage.html(message);
                console.log(message);
                setTimeout(function () {
                    errorMessage.html("");
                }, 5000);
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
            readyButton.addClass("disabled");
            board.perform("ready", {ready: true});
        } else {
            readyButton.removeClass("red");
            readyButton.addClass("gray");
            board.perform("ready", {ready: false});
        }
    });

    let startButton = $("#start-button");
    startButton.on("click", function () {
        $("#your-turn-message").html("");
        startButton.addClass("disabled");
        board.perform("lottery_start_request");
    });
});
