module.exports =
    parse: (s) ->
        t = 0
        m = s.match(/^([^\.]+)\.?(.*)$/)
        sixties = m[1].split(':')
        while sixties.length > 0
            t60 = parseInt(sixties.shift(), 10)
            t = (t * 60) + t60
        if m[2]
            t += parseInt("0.#{m[2]}", 10)
        t

    toString: (t) ->
        h = 0
        while t >= 3600
            h++
            t -= 3600
        m = 0
        while t >= 60
            m++
            t -= 60
        s = 0
        while t >= 1
            s++
            t--
        if h > 0
            s1 = "#{h}:#{pad m}:#{pad s}"
        else if m > 0
            s1 = "#{m}:#{pad s}"
        else
            s1 = "#{s}"
        if t > 0
            m = "#{t}".match(/\.(\d{0,1})/)
            s2 = ".#{m[1]}"
        else
            s2 = ""
        "#{s1}#{s2}"


pad = (s, p='0', l=2) ->
    s = "#{s}"
    while s.length < l
        s = "#{p}#{s}"
    s
