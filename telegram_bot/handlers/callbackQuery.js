const Telegram = require('telegram-node-bot')
const TelegramBaseCallbackQueryController = Telegram.TelegramBaseCallbackQueryController;
var exec = require('child_process').exec;

class CallbacksController extends TelegramBaseCallbackQueryController {
    /**
     * @param {Scope} $
     */
    handle($) {
        if ($.update.callbackQuery.data) {
            var params = $.update.callbackQuery.data.split("|");
            tg.api.answerCallbackQuery($.update.callbackQuery.id);
            switch (params[0]) {
                case "help":
                    this.handleHelp($, params)
                    break;
            }
        }
    }

    handleHelp($, params) {
        var msg;
        var kb = {
            inline_keyboard: []
        };

        switch (params[1]) {
            case "main":
                kb.inline_keyboard.push(
                        [{
                        text: "Build GSI",
                        callback_data: "help|url2gsi"
                        }]);
                msg = "Commands List"
                break;
            case "url2gsi":
                msg = "/url2gsi URL FirmwareType | Build GSI from provided firmware link. \n"
                break;
        }

        if (params[1] !== "main") {
            kb.inline_keyboard.push([{
                text: "Back",
                callback_data: "help|main"
            }]);
        }

        tg.api.editMessageText(msg, {
            parse_mode: "markdown",
            chat_id: $.message.chat.id,
            reply_markup: JSON.stringify(kb),
            message_id: $.message.messageId
        });
    }
}

module.exports = CallbacksController;
