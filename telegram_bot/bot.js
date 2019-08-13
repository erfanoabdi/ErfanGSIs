'use strict'

//export GLOBAL_AGENT_HTTP_PROXY=http://localhost:1087
require('global-agent').bootstrap();

const config = require('./config')
const Telegram = require('telegram-node-bot')
const TextCommand = Telegram.TextCommand

var botToken = config.token || process.env.BOT_TOKEN

// Export bot as global variable
global.tg = new Telegram.Telegram(botToken, {
    localization: [require('./localization/En.json')]
})

// Default Controllers
var CallbackController = require("./handlers/callbackQuery.js")

// Exports all handlers
require('fs').readdirSync(__dirname + '/handlers/').forEach(function (file) {
    if (file.match(/\.js$/) !== null && file !== 'index.js') {
        var name = file.replace('.js', '');

        exports[name] = require('./handlers/' + file);
    }
});
// Routes
tg.router

    .when(
        new TextCommand('/start', 'startHandler', 'Display commands menu'),
        new exports["start"]()
    )
    .when(
        new TextCommand('/help', 'helpHandler', 'Display commands menu'),
        new exports["start"]()
    )
    .when(
        new TextCommand('/url2gsi', 'GSIBuilderHandler', ''),
        new exports["gsibuilder"]()
    )
    .callbackQuery(new CallbackController())
