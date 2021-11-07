import consumer from "./consumer"

const PHASE_LIST = ["Wait", "Ready", "Game", "End"]

let board;
let lotteryIntervalId;
let cards = [];
let myId;
let historyNumbers = [];

function checkCardisOpen(index, indexx, indexy) {
    if (indexx === 2 && indexy === 2) {
        return true;//FREE
    }
    var res = false;
    $.each(cards[index], function (index, value) {
        let x = value["x"];
        let y = value["y"];
        let v = value["value"];
        if (indexx === Number(x) && indexy === Number(y)) {
            if ($.inArray(Number(v), historyNumbers) !== -1) {
                res = true;
                return false;
            }
        }
    });
    return res;
}

function checkBingoLine(index) {
    let bingo;

    //縦ライン
    for (let x = 0; x < 5; x++) {
        bingo = true;
        for (let y = 0; y < 5; y++) {
            if (!checkCardisOpen(index, x, y)) {
                bingo = false;
                break;
            }
        }
        if (bingo) {
            return true;
        }
    }

    //横ライン
    for (let y = 0; y < 5; y++) {
        bingo = true;
        for (let x = 0; x < 5; x++) {
            if (!checkCardisOpen(index, x, y)) {
                bingo = false;
                break;
            }
        }
        if (bingo) {
            return true;
        }
    }

    //右斜め
    bingo = true;
    for (let i = 0; i < 5; i++) {
        if (!checkCardisOpen(index, i, i)) {
            bingo = false;
            break;
        }
    }
    if (bingo) {
        return true;
    }

    //左斜め
    bingo = true;
    for (let i = 4; i >= 0; i--) {
        if (!checkCardisOpen(index, i, i)) {
            bingo = false;
            break;
        }
    }
    if (bingo) {
        return true;
    }

    return false;
}

/* */


document.addEventListener("turbolinks:load", function () {
    myId = parseInt($("#user-id").html());

    $(".bingo-card").each(function (i, card) {
        cards[i] = [];
        $(card).find(".number").each(function (j, number) {
            let numberClass = $(number).attr("class");
            cards[i][j] = {
                x: Number(/number-x-(\d)/.exec(numberClass)[1]),
                y: Number(/number-y-(\d)/.exec(numberClass)[1]),
                value: Number($(number).html()),
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
            console.log("received data:");
            console.log(data);

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
                let user = data["user"];
                console.log("result:");
                console.log(result);
                console.log("user:");
                console.log(user);

                clearInterval(lotteryIntervalId);
                $("#bingo-number").html(result);

                let histories = $("#histories");
                histories.html(histories.html() + '<button name="button" type="submit" class="btn-floating btn-large red">' + result + '</button>');

                historyNumbers = [];
                histories.find("button").each(function (index, element) {
                    let number = Number(element.innerHTML);
                    historyNumbers.push(number);
                });

                console.log(historyNumbers);

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

                $.each(cards, function (index) {
                    if (checkBingoLine(index)) {
                        let user = $($(".bingo-card")[index]).data("user-id");
                        board.perform("bingo", {user: user});
                    }
                });

                if (user === myId) {
                    console.log("next user from:" + myId);
                    this.perform("next_user");
                }
            } else if (type === "your_turn") {
                let id = data["id"];

                console.log(`your turn for: ${id}`);
                console.log(`my-id: ${myId}`);

                if (id === myId) {
                    $("#turn-message").html("あなたのターン");
                    $("#start-button").removeClass("disabled");
                }
            } else if (type === "turn") {
                let name = data["name"];

                $("#turn-message").html(name + "のターン");
            } else if (type === "join") {
                let user = data["user"];

                if (user !== myId) {
                    //リロード
                    Turbolinks.visit(location.href);
                }
            } else if (type === "winner") {
                let name = data["name"];
                $("#winner-box").html("かったひと: " + name);
            } else if (type === "close") {
                let seconds = data["seconds"];
                setInterval(function () {
                    seconds--;
                    $("#close-count-box").html("終了まであと" + seconds + "秒");
                }, 1000);
            } else if (type === "closed") {
                Turbolinks.visit($("#back-link").attr("href"));
            } else if (type === "chat") {
                let name = data["name"];
                let message = data["message"];

                let chatContent = $("#chat-content")
                let chatContentUl = chatContent.find("ul");
                chatContentUl.html(chatContentUl.html() + `\n<li>${name}: ${message}</li>`);

                //TODO 一番下までスクロールする処理無理やりすぎる
                chatContent.scrollTop(10000);
            } else if (type === "reload") {
                location.reload();
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
        startButton.addClass("disabled");
        console.log("lottery_start_request");
        board.perform("lottery_start_request");
    });

    $("#chat-send").on("click", function () {
        let chatInput = $("#chat-input");
        if (chatInput.val() === "") {
            return;
        }
        board.perform("chat_send", {message: chatInput.val()});
        chatInput.val("");
    });
});
