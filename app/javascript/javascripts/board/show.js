/*document.addEventListener("turbolinks:load", function () {
    let numbers = [];

    for (let i = 1; i <= 75; i++) {
        numbers.push(i);
    }

    let count = 0;
    let endCount = Math.floor(Math.random() * 50) + 25;//最低25回(2500ms)、それに最大50回(5000ms)追加
    console.log("end count:");
    console.log(endCount);

    let intervalId = setInterval(function () {
        let number = numbers[Math.floor(Math.random() * numbers.length)];

        $("#bingo-number").html();

        count++;

        if (count >= endCount) {
            clearInterval(intervalId);
        }
    }, 100);
});*/

document.addEventListener("turbolinks:load", function () {
    //TODO 一番下までスクロールする処理無理やりすぎる
    $("#chat-content").scrollTop(10000);
});
