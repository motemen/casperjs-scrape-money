casper = require('casper').create({ verbose: true, logLevel: 'debug' })
xpath  = require('casper').selectXPath
system = require 'system'
fs     = require 'fs'

now = new Date()
lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1)
outFile = fs.open("mufg-#{lastMonth.getFullYear()}-#{(lastMonth.getMonth() + 101).toString().substr(-2)}.tsv", 'w')

system.stderr.write 'id: '
id = system.stdin.readLine()

system.stderr.write 'pass: '
pass = system.stdin.readLine()

casper.start 'https://entry11.bk.mufg.jp/ibg/dfw/APLIN/loginib/login?_TRANID=AA000_001', ->
    @fill 'form[action="/ibg/dfw/APLIN/loginib/login"]', {
        KEIYAKU_NO: id,
        PASSWORD: pass
    }
    @click '[alt="ログイン"]'

casper.then ->
    @click xpath('//a[img[@alt="入出金明細をみる"]]')

casper.then ->
    @waitFor ->
        @exists(xpath('//a[img[@alt="明細をダウンロード"]]'))

casper.then ->
    @evaluate ->
        window.__leaving = true
    @click 'input#last_month'
    @click xpath('//button[img[@alt="照会"]]')
    @waitFor ->
        @evaluate ->
            not window.__leaving

casper.then ->
    details = @evaluate ->
        $('#no_memo table tr')
            .filter(-> $(@).find('td').length == 5)
            .map(-> [ $(@).find('td').map(-> $(@).text()).toArray() ]).toArray()
    details.forEach (detail) ->
        outFile.writeLine(detail.join("\t"))
    outFile.close()

casper.run()
