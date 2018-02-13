###
    Script that map with Database

    input : Code like SELECT AF
    output: return Country full name
###

module.exports = (robot) ->
   ###  
    robot.http("http://localhost:8083/")
    .header('Accept', 'application/json')
    .get() (err, response, body) ->
      # error checking code here

      data = JSON.parse body
      console.log(data)
       res.send "#{data.passenger} taking midnight train going #{data.destination}"
   ###

   robot.respond /SELECT (.*)/i, (res) ->
     shortCountry=res.match[1]
     geturl = "http://localhost:8083/" + shortCountry
     robot.http(geturl)
        .header('Accept', 'application/json')
        .get() (err, response, body) ->
             data = JSON.parse body
             # console.log(data)             
             if data.recordset.length > 0
                # res.send data.recordset[0].countrydesc 
                fs = require('fs')
                filepath = '.\\File' + '\\' + shortCountry + '.txt'
                fs.writeFile filepath, JSON.stringify(data.recordset[0]), (error) ->
                    if(error)
                        console.log('error in file')
                        res.send 'File is not Created for ' + shortCountry 
                    else    
                        console.log('file created')
                        res.send data.recordset[0].countrydesc + '\nFile is Created for ' + shortCountry 
               
             else
                res.send "No Data Found"   
   

    Conversation = require('hubot-conversation')

    switchboard = new Conversation(robot)

    robot.respond /CREATE/, (msg) ->
            dialog =switchboard.startDialog(msg)
            msg.send ('Sure, Short Name of Country?')
            dialog.addChoice /(.*)/i, (msg2) ->
                # msg2.send 'Short Name : ' + msg2.match[1]            
                shortCountry = msg2.match[1]
                msg.send('Description of Country ?')
                dialog.addChoice /(.*)/i, (msg3) ->
                    longCountry = msg3.match[1]
                    msg3.send 'DATA :' + shortCountry + " " + longCountry