###
    Script that map with XLSX

    input : Excel File
    output: query String for the database
###

module.exports = (robot) ->
    robot.respond /(.*)/i, (res) ->
        # console.log (res.match)
        filepath = '.\\xls' + '\\dbQuery.xlsx'
        file=require('xlsjs').readFile(filepath)
        param = res.match[1].replace /^\s+|\s+$/g, ""
        params = []
        
        console.log(param)
        # command_str = file.Strings[0].t
        # query_str = file.Strings[1].t
        # mrg_str = qury_str.replace '{{ref_text}}',res.match[1]
        
        console.log(file.Strings)
        cnt = 0
        while cnt < file.Strings.Count
            # console.log cnt
          
            regex = file.Strings[cnt].t.toLowerCase() + ' '
            strString = res.match[0].toLowerCase()
            # console.log(strString)
            # console.log(regex)
            strCount = strString.search regex
            # console.log strCount

            if strCount == -1
                cnt = cnt + 2
            else
                index = cnt + 1
                # console.log (index)
                query_str= file.Strings[index].t
                break

        # console.log(query_str)
        if query_str == undefined
            res.send 'No Keyword Found'
        else            
            params_index = param.indexOf " "
            console.log(params_index)
            param_str = param.substr params_index
            param_str = param_str.replace /^\s+|\s+$/g, ""
            # console.log(param_str)
            # console.log (param_str.indexOf " ")
            searchResult = param_str.indexOf " "
            if  searchResult > 0
                console.log 1
                def = param_str.split " "
                params = def.filter (x) -> x != (undefined || null || '')
            else   
                console.log 2               
                params[0] = param_str     

            console.log(params)
            shortCountry=params[0]
            # mrg_str = query_str.replace /{{ref_text}}/, params[0]
            mrg_str = makeQuery params, query_str
            console.log 'query : ' + mrg_str
            result =  encodeURIComponent mrg_str           
            # res.send getFunction result
            rtStr = getFunction result
            geturl = "http://localhost:8083/query/" + rtStr
            console.log geturl
            robot.http(geturl)            
            .get() (err, response, body) ->
                # console.log body
                data = JSON.parse body.toString()
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

    getFunction = (Options) ->
          chars = {"'" : "%27", "(" : "%28" ,")" : "%29","*" : "%2A","!" : "%21","~" : "%7E"}
          Options.replace /[~!*()']/g,  (m)  => chars[m]          
    
    makeQuery = (data, changeStr) ->
        console.log 'old : ' + changeStr
        cnt = 0
        
        while cnt < data.length
            if cnt > 0 
                refstr= '{{ref_text' + cnt + '}}'
            else
                refstr= '{{ref_text}}'
            # console.log refstr
            # console.log data[cnt]
            changeStr = changeStr.replace refstr , data[cnt]
            cnt++
        console.log 'new : ' + changeStr
        return changeStr

