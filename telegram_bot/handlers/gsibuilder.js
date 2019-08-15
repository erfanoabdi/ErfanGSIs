const Telegram = require('telegram-node-bot')
const TelegramBaseController = Telegram.TelegramBaseController;
const config = require("../config.js")
var spawn = require('child_process').spawn;
var Queue = require('better-queue');

var q = new Queue(function (input, cb) {

    var $ = input.scope;
    var initialMessage = "Building GSI...";
    $.sendMessage(initialMessage, {
        parse_mode: "markdown",
        reply_to_message_id: $.message.messageId
    }).then(function (msg) {

        var url2gsi = spawn(__dirname + "/../../url2GSI.sh", $.command.arguments);
        url2gsi.stdout.on('data', function (data) {

            var message = data.toString();

            initialMessage = initialMessage + "\n" + message.trim()

            tg.api.editMessageText("`" + initialMessage + "`", {
                parse_mode: "markdown",
                chat_id: msg._chat._id,
                disable_web_page_preview: true,
                message_id: msg._messageId
            });
        });

        url2gsi.stderr.on('data', function (data) {
            console.log('stderr: ' + data.toString());
        });

        url2gsi.on('exit', function (code) {
            $.sendMessage("Job done", {
                parse_mode: "markdown",
                reply_to_message_id: $.message.messageId
            });
            console.log('child process exited with code ' + code.toString());
            cb()
        });
    });
}, {
    concurrent: 1,
    batchSize: 1
})

class GSIBuilderController extends TelegramBaseController {

    url2gsi($) {

        if (!config.gsi_builders.includes($.message.from.id)) {
            $.sendMessage("You don't have access to GSI building", {
                parse_mode: "markdown",
                reply_to_message_id: $.message.messageId
            });
            return
        }

        if (!$.command.success || $.command.arguments.length === 0) {
            $.sendMessage("Usage and help: /url2gsi -h", {
                parse_mode: "markdown",
                reply_to_message_id: $.message.messageId
            });
            return;
        }

        q.push({
            scope: $,
            url: $.command.arguments[0]
        })
        $.sendMessage("Job added to queue", {
            parse_mode: "markdown",
            reply_to_message_id: $.message.messageId
        })
    }

    get routes() {
        return {
            'GSIBuilderHandler': 'url2gsi',
        }
    }
}

module.exports = GSIBuilderController;
