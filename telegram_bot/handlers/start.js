const Telegram = require('telegram-node-bot')
const TelegramBaseController = Telegram.TelegramBaseController;

class StartController extends TelegramBaseController {

    help($) {
        var kb = {
            inline_keyboard: []
        };

        kb.inline_keyboard.push(
                        [{
                text: "Build GSI",
                callback_data: "help|url2gsi"
                        }]);
        if ($.message.from.id === $.message.chat.id) {
            tg.api.sendMessage($.message.from.id, "Menu", {
                parse_mode: "markdown",
                reply_markup: JSON.stringify(kb),
                reply_to_message_id: $.message.messageId
            });
        }
    }

    get routes() {
        return {
            'startHandler': 'help',
            'helpHandler': 'help'
        }
    }
}

module.exports = StartController;
