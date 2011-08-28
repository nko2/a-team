{ EventEmitter } = require('events')
spawn = require('child_process').spawn
querystring = require('querystring')
path = require('path')
fs = require('fs')

trim = (nam) ->
    return nam.replace(/^\s+|\s+$/g, '')

regExp = new RegExp('\\d{0,}%','i')
# dirty little lock
LOCKS = {}

class Downloader extends EventEmitter

    constructor (@outputDir='../files') ->
        @dl = null
        @lastProgress = null

     # add the Trim function to javascript

    setOutput : (dir) ->
        @outputDir = dir


    getOutput: =>
        return @outputDir

    download: (url, callback) =>
        console.log(@outputDir)
        @outfile = path.join(@outputDir, querystring.escape(url))
        console.log("LOCKS", LOCKS)
        if LOCKS[@outfile]
            @emit("error", 1000)
            return callback("already in progress", null)
        else
            LOCKS[@outfile] = this
        dl = spawn('wget', ['-P ' + @outputDir, '-O', @outfile, url])
        #dl.on 'exit', (code) =>
        #    console.log('child process exited with code ' + code)
        #    callback(code)
        console.log('wget', ['-c', '-P ' + @outputDir, '-O ' + url, url])

        dl.stdout.on 'data', (data) =>
            console.log("stdout", data)

        dl.stderr.on 'data', (data) =>
            data = data.toString('ascii')
            #console.log("stderr", data)

            # extract the progress percentage
            if regExp.test(data)

                progress = data.match(regExp)

                #console.log("data", data, "progre", progress)
                #call only when percentage changed
                if @lastProgress != progress[0]
                    #console.log('progress: ' + progress[0])
                    @lastProgress = lastProgress = progress[0]
                    
                # extract the download speed
                #speed = data.substr(@position + progress[0].length).trim()
                #@speed = speed.substr(0, speed.indexOf('/s') + 2).trim()

                # call the event
                @emit('progress', @lastProgress) #, speed)
        dl.stdin.end()
        dl.on 'exit', (code) =>
            console.log("got exit:" + code)
            delete LOCKS[@outfile]
            if code == 0
                console.log("emit success")
                @emit("success")
            else
                @emit("failed", "error in wget: " + code)
                fs.unlink @outfile

            
    stopDownload = () =>
        console.log('download stopped')
        dl.kill()

exports.Downloader = Downloader
